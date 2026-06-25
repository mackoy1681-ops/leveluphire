// lib/screens/discuss_hub.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/discuss_provider.dart';
import '../models/discuss_models.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class DiscussHub extends ConsumerStatefulWidget {
  const DiscussHub({super.key});

  @override
  ConsumerState<DiscussHub> createState() => _DiscussHubState();
}

class _DiscussHubState extends ConsumerState<DiscussHub> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(discussProvider.notifier);
      notifier.loadThreads();
      notifier.loadHotThreads();
      notifier.loadUserInteractions();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(discussProvider.notifier).loadThreads();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discussProvider);
    final notifier = ref.read(discussProvider.notifier);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    final threads = state.threads;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          'DiscussHub',
          style: TextStyle(
            color: Color(0xFF1B1F23),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
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
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF65676B), size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF65676B), size: 20),
            onPressed: () => notifier.refresh(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading && threads.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1877F2)),
            )
          : threads.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 64, color: Color(0xFF65676B)),
                      const SizedBox(height: 16),
                      const Text(
                        'No threads yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B1F23),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Be the first to create a thread!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF65676B),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, kRouteCreateThread)
                                .then((_) => notifier.refresh());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1877F2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Create a Thread'),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => notifier.refresh(),
                  color: const Color(0xFF1877F2),
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: threads.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == threads.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF1877F2),
                              ),
                            ),
                          ),
                        );
                      }
                      final thread = threads[index];
                      
                      if (index == 0 && user != null) {
                        return Column(
                          children: [
                            _CreateThreadCard(),
                            _ThreadCard(thread: thread),
                          ],
                        );
                      }
                      
                      return _ThreadCard(thread: thread);
                    },
                  ),
                ),
    );
  }
}

class _CreateThreadCard extends ConsumerWidget {
  const _CreateThreadCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    String displayName = 'User';
    String? avatarUrl;
    
    if (profileAsync.hasValue && profileAsync.value != null) {
      displayName = profileAsync.value!.displayName.isNotEmpty 
          ? profileAsync.value!.displayName 
          : (profileAsync.value!.username.isNotEmpty ? profileAsync.value!.username : 'User');
      avatarUrl = profileAsync.value!.avatarUrl;
    } else if (user != null) {
      displayName = user.email?.split('@').first ?? 'User';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFE4E6EB), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFF0F2F5),
                  backgroundImage: avatarUrl != null
                      ? CachedNetworkImageProvider(avatarUrl!)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, size: 20, color: Color(0xFF65676B))
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1F23),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, kRouteCreateThread)
                    .then((_) => ref.read(discussProvider.notifier).refresh());
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE4E6EB), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'What\'s on your mind?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF65676B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, kRouteCreateThread)
                        .then((_) => ref.read(discussProvider.notifier).refresh());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1877F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadCard extends ConsumerWidget {
  final Thread thread;

  const _ThreadCard({required this.thread});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(discussProvider.notifier);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '$kRouteThreadPrefix/${thread.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: const Color(0xFFE4E6EB), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF0F2F5),
                    backgroundImage: thread.avatarUrl != null
                        ? CachedNetworkImageProvider(thread.avatarUrl!)
                        : null,
                    child: thread.avatarUrl == null
                        ? Icon(
                            thread.isAnonymous ? Icons.person_outline : Icons.person,
                            size: 20,
                            color: const Color(0xFF65676B),
                          )
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
                              thread.displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1B1F23),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTimeAgo(thread.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF65676B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF65676B)),
                    color: const Color(0xFFFFFFFF),
                    itemBuilder: (context) => [
                      if (!thread.isAnonymous)
                        PopupMenuItem(
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Color(0xFF1877F2)),
                              const SizedBox(width: 12),
                              const Text('View Profile', style: TextStyle(color: Color(0xFF1B1F23))),
                            ],
                          ),
                          onTap: () {},
                        ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.flag, size: 16, color: Colors.redAccent),
                            const SizedBox(width: 12),
                            const Text('Report', style: TextStyle(color: Color(0xFF1B1F23))),
                          ],
                        ),
                        onTap: () => _showReportDialog(context, thread.id, 'topic', ref),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                thread.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1F23),
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                thread.content.length > 150
                    ? '${thread.content.substring(0, 150)}...'
                    : thread.content,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF1B1F23),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Like button
                  GestureDetector(
                    onTap: () async {
                      await notifier.toggleLike(thread.id, 'topic');
                      // No full refresh needed: toggleLike already updates local state
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            thread.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: thread.isLiked ? const Color(0xFFE53935) : const Color(0xFF65676B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(thread.likeCount),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: thread.isLiked ? const Color(0xFFE53935) : const Color(0xFF65676B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Comment button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '$kRouteThreadPrefix/${thread.id}');
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 18,
                            color: Color(0xFF65676B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(thread.commentCount),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF65676B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Save button
                  GestureDetector(
                    onTap: () async {
                      await notifier.toggleSave(thread.id);
                      // toggleSave already updates local state
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            thread.isSaved ? Icons.bookmark : Icons.bookmark_border,
                            size: 18,
                            color: thread.isSaved ? const Color(0xFF1877F2) : const Color(0xFF65676B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(thread.saveCount),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: thread.isSaved ? const Color(0xFF1877F2) : const Color(0xFF65676B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Watch button
                  GestureDetector(
                    onTap: () async {
                      await notifier.toggleWatch(thread.id);
                      // toggleWatch already updates local state
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            thread.isWatching ? Icons.visibility : Icons.visibility_off,
                            size: 18,
                            color: thread.isWatching ? const Color(0xFF1877F2) : const Color(0xFF65676B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            thread.isWatching ? 'Watching' : 'Watch',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.normal,
                              color: thread.isWatching ? const Color(0xFF1877F2) : const Color(0xFF65676B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  String _formatNumber(int number) {
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}k';
    return number.toString();
  }

  void _showReportDialog(BuildContext context, String targetId, String targetType, WidgetRef ref) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Report Content',
                style: TextStyle(
                  color: Color(0xFF1B1F23),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please tell us why you are reporting this content:',
                style: TextStyle(color: Color(0xFF65676B), fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 4,
                style: const TextStyle(color: Color(0xFF1B1F23), fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Reason...',
                  hintStyle: const TextStyle(color: Color(0xFF65676B), fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE4E6EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1877F2)),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF65676B))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (reasonController.text.isNotEmpty) {
                          ref.read(discussProvider.notifier).reportContent(
                            targetId: targetId,
                            targetType: targetType,
                            reason: reasonController.text,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report submitted'),
                              backgroundColor: Color(0xFF1877F2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
