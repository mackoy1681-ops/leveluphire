// lib/screens/thread_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/discuss_provider.dart';
import '../models/discuss_models.dart';
import '../utils/constants.dart';
import 'likes_popup.dart';

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

  @override
  void initState() {
    super.initState();
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
      
      // Build comment tree
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
      
      // Update thread comment count in local state
      ref.read(discussProvider.notifier).loadThreads(refresh: true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e'), backgroundColor: kError),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurface,
        title: const Text('Delete Comment', style: TextStyle(color: kPrimaryText)),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kSecondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: kError)),
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
        backgroundColor: kSurface,
        title: const Text('Delete Thread', style: TextStyle(color: kPrimaryText)),
        content: const Text('Are you sure you want to delete this thread? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kSecondaryText)),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(discussProvider.notifier).deleteThread(widget.thread.id);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to feed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thread deleted'), backgroundColor: kSuccess),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: kError)),
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
        backgroundColor: kSurface,
        title: const Text('Report Content', style: TextStyle(color: kPrimaryText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please tell us why you are reporting this content:', style: TextStyle(color: kSecondaryText)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(color: kPrimaryText),
              decoration: InputDecoration(
                hintText: 'Reason...',
                hintStyle: const TextStyle(color: kSecondaryText),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusInput)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kRadiusInput),
                  borderSide: const BorderSide(color: kBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kRadiusInput),
                  borderSide: const BorderSide(color: kAccentBlue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kSecondaryText)),
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
                  const SnackBar(content: Text('Report submitted'), backgroundColor: kSuccess),
                );
              }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.red)),
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
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Thread', style: TextStyle(color: kPrimaryText)),
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Follow button
          IconButton(
            icon: Icon(
              widget.thread.isFollowingAuthor ? Icons.notifications : Icons.notifications_none,
              color: widget.thread.isFollowingAuthor ? kAccentBlue : kSecondaryText,
            ),
            onPressed: () => notifier.toggleFollow('user', widget.thread.userId),
          ),
          // Save button
          IconButton(
            icon: Icon(
              widget.thread.isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: widget.thread.isSaved ? Colors.green : kSecondaryText,
            ),
            onPressed: () => notifier.toggleSave(widget.thread.id),
          ),
          // Menu
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz, color: kSecondaryText),
            itemBuilder: (context) => [
              if (isOwner)
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, size: 16, color: kError),
                      SizedBox(width: 8),
                      Text('Delete Thread'),
                    ],
                  ),
                  onTap: _showDeleteThreadDialog,
                ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Report'),
                  ],
                ),
                onTap: () => _showReportDialog(widget.thread.id, 'topic'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Thread content
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
                        backgroundColor: kBorderColor,
                        backgroundImage: widget.thread.avatarUrl != null
                            ? CachedNetworkImageProvider(widget.thread.avatarUrl!)
                            : null,
                        child: widget.thread.avatarUrl == null
                            ? Icon(
                                widget.thread.isAnonymous ? Icons.person_outline : Icons.person,
                                size: 20,
                                color: kSecondaryText,
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
                                color: widget.thread.isAnonymous ? kSecondaryText : kPrimaryText,
                                fontSize: kFontBase,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatTimeAgo(widget.thread.createdAt),
                              style: const TextStyle(color: kSecondaryText, fontSize: 12),
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
                      color: kPrimaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Content
                  Text(
                    widget.thread.content,
                    style: const TextStyle(
                      color: kPrimaryText,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Stats row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: kSurface,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => LikesPopup(
                              targetId: widget.thread.id,
                              targetType: 'topic',
                            ),
                          );
                        },
                        child: Text(
                          '${_formatNumber(widget.thread.likeCount)} likes',
                          style: const TextStyle(color: kSecondaryText, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_formatNumber(widget.thread.commentCount)} comments',
                        style: const TextStyle(color: kSecondaryText, fontSize: 13),
                      ),
                    ],
                  ),
                  
                  const Divider(color: kBorderColor, height: 32),
                  
                  // Comments section
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 18, color: kSecondaryText),
                      const SizedBox(width: 8),
                      Text(
                        'Comments (${_formatNumber(widget.thread.commentCount)})',
                        style: const TextStyle(color: kPrimaryText, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (_isLoadingComments)
                    const Center(child: CircularProgressIndicator(color: kAccentBlue))
                  else if (_comments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No comments yet. Be the first to comment!',
                          style: TextStyle(color: kSecondaryText),
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
              color: kSurface,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to $_replyingToName',
                      style: const TextStyle(color: kAccentBlue, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: kSecondaryText),
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
              color: kSurface,
              border: Border(top: BorderSide(color: kBorderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: kPrimaryText),
                    decoration: InputDecoration(
                      hintText: _replyingToId != null ? 'Write a reply...' : 'Write a comment...',
                      hintStyle: const TextStyle(color: kSecondaryText),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kRadiusPill),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: kBackground,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: kAccentBlue),
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
            backgroundColor: kBorderColor,
            backgroundImage: comment.avatarUrl != null
                ? CachedNetworkImageProvider(comment.avatarUrl!)
                : null,
            child: comment.avatarUrl == null
                ? const Icon(Icons.person, size: 14, color: kSecondaryText)
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
                        color: kPrimaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: const TextStyle(color: kSecondaryText, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(color: kPrimaryText, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => notifier.toggleLike(comment.id, 'comment'),
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                            size: 14,
                            color: comment.isLiked ? Colors.blue : kSecondaryText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(comment.likeCount),
                            style: TextStyle(
                              color: comment.isLiked ? Colors.blue : kSecondaryText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        style: TextStyle(color: kSecondaryText, fontSize: 11),
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _deleteComment(comment.id),
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: kError, fontSize: 11),
                        ),
                      ),
                    ],
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => _showReportDialog(comment.id, 'comment'),
                      child: const Text(
                        'Report',
                        style: TextStyle(color: kSecondaryText, fontSize: 11),
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