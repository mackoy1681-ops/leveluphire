// lib/screens/thread_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/discuss_provider.dart';
import '../models/discuss_models.dart';

/// Web deep-link entry point.
/// Allows URLs like `/discuss/thread/<id>` (or `#/discuss/thread/<id>`) to open
/// the thread detail screen directly (including after refresh).
class ThreadDetailByIdScreen extends ConsumerStatefulWidget {
  final String threadId;
  const ThreadDetailByIdScreen({super.key, required this.threadId});

  @override
  ConsumerState<ThreadDetailByIdScreen> createState() => _ThreadDetailByIdScreenState();
}

class _ThreadDetailByIdScreenState extends ConsumerState<ThreadDetailByIdScreen> {
  Future<Thread>? _future;

  @override
  void initState() {
    super.initState();
    _future = _loadThread();
  }

  Future<Thread> _loadThread() async {
    final supabase = Supabase.instance.client;
    final res = await supabase
        .from('discussion_topics')
        .select('''
          *,
          profiles:user_id(display_name, avatar_url, username)
        ''')
        .eq('id', widget.threadId)
        .maybeSingle();

    if (res == null) {
      throw Exception('Thread not found');
    }
    return Thread.fromJson(res);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Thread>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFFFFF),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF1877F2))),
          );
        }

        if (snap.hasError || !snap.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFFFFFFF),
            appBar: AppBar(
              title: const Text('Thread', style: TextStyle(color: Color(0xFF1B1F23))),
              backgroundColor: const Color(0xFFFFFFFF),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1F23)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load thread: ${snap.error}',
                      style: const TextStyle(color: Color(0xFF65676B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => setState(() => _future = _loadThread()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ThreadDetailScreen(thread: snap.data!);
      },
    );
  }
}

class ThreadDetailScreen extends ConsumerStatefulWidget {
  final Thread thread;

  const ThreadDetailScreen({super.key, required this.thread});

  @override
  ConsumerState<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends ConsumerState<ThreadDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Comment> _comments = [];
  bool _isLoadingComments = true;
  String? _replyingToId;
  String? _replyingToName;

  // Local state for save button
  late bool _isSaved;
  late int _saveCount;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.thread.isSaved;
    _saveCount = widget.thread.saveCount;
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('discussion_comments')
          .select('''
            *,
            profiles:user_id(display_name, avatar_url, username)
          ''')
          .eq('topic_id', widget.thread.id)
          .order('created_at', ascending: true);

      final allComments = response.map((json) => Comment.fromJson(json)).toList();
      
      final Map<String, Comment> commentMap = {};
      final List<Comment> topComments = [];
      
      for (var comment in allComments) {
        commentMap[comment.id] = comment;
        comment.replies = [];
      }
      
      for (var comment in allComments) {
        if (comment.parentId == null) {
          topComments.add(comment);
        } else {
          final parent = commentMap[comment.parentId];
          if (parent != null) {
            parent.replies.add(comment);
          }
        }
      }
      
      setState(() {
        _comments = topComments;
        _isLoadingComments = false;
      });
    } catch (e) {
      print('Error loading comments: $e');
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _addComment({String? parentId, String? parentName}) async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      await ref.read(discussProvider.notifier).addComment(
        widget.thread.id,
        content,
        parentId: parentId,
      );

      _commentController.clear();
      setState(() {
        _replyingToId = null;
        _replyingToName = null;
      });
      
      await _loadComments();
      ref.read(discussProvider.notifier).loadThreads(refresh: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Delete Comment', style: TextStyle(color: Color(0xFF1B1F23))),
        content: const Text('Are you sure you want to delete this comment?', style: TextStyle(color: Color(0xFF65676B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF65676B))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(discussProvider.notifier).deleteComment(commentId, widget.thread.id);
      await _loadComments();
      ref.read(discussProvider.notifier).loadThreads(refresh: true);
    }
  }

  void _showDeleteThreadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Delete Thread', style: TextStyle(color: Color(0xFF1B1F23))),
        content: const Text('Are you sure you want to delete this thread? This cannot be undone.', style: TextStyle(color: Color(0xFF65676B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF65676B))),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(discussProvider.notifier).deleteThread(widget.thread.id);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thread deleted'), backgroundColor: Color(0xFF1877F2)),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(String targetId, String targetType) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Report Content', style: TextStyle(color: Color(0xFF1B1F23))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please tell us why you are reporting this content:', style: TextStyle(color: Color(0xFF65676B))),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(color: Color(0xFF1B1F23)),
              decoration: InputDecoration(
                hintText: 'Reason...',
                hintStyle: const TextStyle(color: Color(0xFF65676B)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE4E6EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE4E6EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF1877F2)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF65676B))),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                ref.read(discussProvider.notifier).reportContent(
                  targetId: targetId,
                  targetType: targetType,
                  reason: reasonController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted'), backgroundColor: Color(0xFF1877F2)),
                );
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isOwner = user?.id == widget.thread.userId;
    final notifier = ref.read(discussProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text('Thread', style: TextStyle(color: Color(0xFF1B1F23))),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE4E6EB)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1F23)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Save button with optimistic UI update
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? const Color(0xFF1877F2) : const Color(0xFF65676B),
            ),
            onPressed: () async {
              // Update UI immediately (optimistic)
              setState(() {
                _isSaved = !_isSaved;
                if (_isSaved) {
                  _saveCount++;
                } else {
                  _saveCount--;
                }
              });
              // Update database in background
              await notifier.toggleSave(widget.thread.id);
              // Sync local thread object
              widget.thread.isSaved = _isSaved;
              widget.thread.saveCount = _saveCount;
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF65676B)),
            color: const Color(0xFFFFFFFF),
            itemBuilder: (context) => [
              if (isOwner)
                const PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                      SizedBox(width: 8),
                      Text('Delete Thread', style: TextStyle(color: Color(0xFF1B1F23))),
                    ],
                  ),
                  value: 'delete',
                ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('Report', style: TextStyle(color: Color(0xFF1B1F23))),
                  ],
                ),
                value: 'report',
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteThreadDialog();
              } else if (value == 'report') {
                _showReportDialog(widget.thread.id, 'topic');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFF0F2F5),
                        backgroundImage: widget.thread.avatarUrl != null
                            ? CachedNetworkImageProvider(widget.thread.avatarUrl!)
                            : null,
                        child: widget.thread.avatarUrl == null
                            ? Icon(
                                widget.thread.isAnonymous ? Icons.person_outline : Icons.person,
                                size: 20,
                                color: const Color(0xFF65676B),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.thread.displayName,
                              style: TextStyle(
                                color: widget.thread.isAnonymous ? const Color(0xFF65676B) : const Color(0xFF1B1F23),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatTimeAgo(widget.thread.createdAt),
                              style: const TextStyle(color: Color(0xFF65676B), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    widget.thread.title,
                    style: const TextStyle(
                      color: Color(0xFF1B1F23),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Content
                  Text(
                    widget.thread.content,
                    style: const TextStyle(
                      color: Color(0xFF1B1F23),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Comment count only (likes removed)
                  Text(
                    '${_formatNumber(widget.thread.commentCount)} comments',
                    style: const TextStyle(color: Color(0xFF65676B), fontSize: 13),
                  ),
                  
                  const Divider(color: Color(0xFFE4E6EB), height: 32),
                  
                  // Comments section
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF65676B)),
                      const SizedBox(width: 8),
                      Text(
                        'Comments (${_formatNumber(widget.thread.commentCount)})',
                        style: const TextStyle(color: Color(0xFF1B1F23), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (_isLoadingComments)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF1877F2)))
                  else if (_comments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No comments yet. Be the first to comment!',
                          style: TextStyle(color: Color(0xFF65676B)),
                        ),
                      ),
                    )
                  else
                    ..._comments.map((comment) => _buildCommentTree(comment, notifier)),
                ],
              ),
            ),
          ),
          
          // Reply indicator
          if (_replyingToId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF0F2F5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to $_replyingToName',
                      style: const TextStyle(color: Color(0xFF1877F2), fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Color(0xFF65676B)),
                    onPressed: () {
                      setState(() {
                        _replyingToId = null;
                        _replyingToName = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          
          // Comment input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              border: const Border(top: BorderSide(color: Color(0xFFE4E6EB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Color(0xFF1B1F23)),
                    decoration: InputDecoration(
                      hintText: _replyingToId != null ? 'Write a reply...' : 'Write a comment...',
                      hintStyle: const TextStyle(color: Color(0xFF65676B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F2F5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF1877F2)),
                  onPressed: () => _addComment(
                    parentId: _replyingToId,
                    parentName: _replyingToName,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTree(Comment comment, DiscussNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentItem(comment, notifier),
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Column(
              children: comment.replies.map((reply) => _buildCommentItem(reply, notifier)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentItem(Comment comment, DiscussNotifier notifier) {
    final user = Supabase.instance.client.auth.currentUser;
    final isOwner = user?.id == comment.userId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFF0F2F5),
            backgroundImage: comment.avatarUrl != null
                ? CachedNetworkImageProvider(comment.avatarUrl!)
                : null,
            child: comment.avatarUrl == null
                ? const Icon(Icons.person, size: 14, color: Color(0xFF65676B))
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.displayName,
                      style: const TextStyle(
                        color: Color(0xFF1B1F23),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: const TextStyle(color: Color(0xFF65676B), fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(color: Color(0xFF1B1F23), fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyingToId = comment.id;
                          _replyingToName = comment.displayName;
                        });
                      },
                      child: const Text(
                        'Reply',
                        style: TextStyle(color: Color(0xFF65676B), fontSize: 11),
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _deleteComment(comment.id),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.redAccent, fontSize: 11),
                        ),
                      ),
                    ],
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showReportDialog(comment.id, 'comment'),
                      child: const Text(
                        'Report',
                        style: TextStyle(color: Color(0xFF65676B), fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _formatNumber(int number) {
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}k';
    return number.toString();
  }
}
