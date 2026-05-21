// lib/providers/discuss_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/discuss_models.dart';

final discussProvider = StateNotifierProvider<DiscussNotifier, DiscussState>((ref) {
  return DiscussNotifier();
});

class DiscussState {
  final List<Thread> threads;
  final List<Thread> hotThreads;
  final Set<String> shownHotIds;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentPage;
  final Set<String> followedUsers;
  final Set<String> savedThreads;
  final Set<String> likedThreads;
  final Set<String> watchedThreads;
  final Map<String, Set<String>> likedComments;

  DiscussState({
    this.threads = const [],
    this.hotThreads = const [],
    this.shownHotIds = const {},
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 0,
    this.followedUsers = const {},
    this.savedThreads = const {},
    this.likedThreads = const {},
    this.watchedThreads = const {},
    this.likedComments = const {},
  });

  DiscussState copyWith({
    List<Thread>? threads,
    List<Thread>? hotThreads,
    Set<String>? shownHotIds,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentPage,
    Set<String>? followedUsers,
    Set<String>? savedThreads,
    Set<String>? likedThreads,
    Set<String>? watchedThreads,
    Map<String, Set<String>>? likedComments,
  }) {
    return DiscussState(
      threads: threads ?? this.threads,
      hotThreads: hotThreads ?? this.hotThreads,
      shownHotIds: shownHotIds ?? this.shownHotIds,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      followedUsers: followedUsers ?? this.followedUsers,
      savedThreads: savedThreads ?? this.savedThreads,
      likedThreads: likedThreads ?? this.likedThreads,
      watchedThreads: watchedThreads ?? this.watchedThreads,
      likedComments: likedComments ?? this.likedComments,
    );
  }
}

// Helper to create a fresh Thread copy with updated fields
Thread _copyThread(
  Thread t, {
  int? likeCount,
  int? commentCount,
  int? saveCount,
  bool? isLiked,
  bool? isSaved,
  bool? isWatching,
  bool? isFollowingAuthor,
}) {
  return Thread(
    id: t.id,
    userId: t.userId,
    title: t.title,
    content: t.content,
    isAnonymous: t.isAnonymous,
    likeCount: likeCount ?? t.likeCount,
    commentCount: commentCount ?? t.commentCount,
    saveCount: saveCount ?? t.saveCount,
    viewCount: t.viewCount,
    createdAt: t.createdAt,
    updatedAt: t.updatedAt,
    profile: t.profile,
    isFollowingAuthor: isFollowingAuthor ?? t.isFollowingAuthor,
    isSaved: isSaved ?? t.isSaved,
    isLiked: isLiked ?? t.isLiked,
    isWatching: isWatching ?? t.isWatching,
  );
}

class DiscussNotifier extends StateNotifier<DiscussState> {
  DiscussNotifier() : super(DiscussState()) {
    loadHotThreads();
    loadThreads();
    Future.delayed(Duration(milliseconds: 500), () {
      loadUserInteractions();
    });
  }

  final _supabase = Supabase.instance.client;

  Future<void> loadUserInteractions() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final followsRes = await _supabase
          .from('discussion_follows')
          .select('follow_id')
          .eq('user_id', user.id)
          .eq('follow_type', 'user');

      final followed = followsRes.map((f) => f['follow_id'] as String).toSet();

      final savesRes = await _supabase
          .from('discussion_saves')
          .select('topic_id')
          .eq('user_id', user.id);

      final saved = savesRes.map((s) => s['topic_id'] as String).toSet();

      final likesRes = await _supabase
          .from('discussion_likes')
          .select('target_id')
          .eq('user_id', user.id)
          .eq('target_type', 'topic');

      final liked = likesRes.map((l) => l['target_id'] as String).toSet();

      final watchesRes = await _supabase
          .from('discussion_watches')
          .select('topic_id')
          .eq('user_id', user.id);

      final watched = watchesRes.map((w) => w['topic_id'] as String).toSet();

      // Update state sets first
      state = state.copyWith(
        followedUsers: followed,
        savedThreads: saved,
        likedThreads: liked,
        watchedThreads: watched,
      );

      // Now create fresh Thread copies with updated UI state
      final updatedThreads = state.threads.map((t) {
        return _copyThread(
          t,
          isFollowingAuthor: followed.contains(t.userId),
          isSaved: saved.contains(t.id),
          isLiked: liked.contains(t.id),
          isWatching: watched.contains(t.id),
        );
      }).toList();

      state = state.copyWith(threads: updatedThreads);

    } catch (e) {
      print('Error loading user interactions: $e');
    }
  }

  Future<void> loadHotThreads() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7)).toIso8601String();

      final response = await _supabase
          .from('discussion_topics')
          .select('''
            *,
            profiles:user_id(display_name, avatar_url, username)
          ''')
          .gte('created_at', sevenDaysAgo)
          .order('like_count', ascending: false)
          .limit(20);

      final threads = response.map((json) => Thread.fromJson(json)).toList();

      final scoredThreads = threads.map((t) {
        final engagementScore = (t.likeCount * 2) + (t.commentCount * 3) + (t.saveCount * 1);
        return (thread: t, score: engagementScore);
      }).toList();

      scoredThreads.sort((a, b) => b.score.compareTo(a.score));

      state = state.copyWith(
        hotThreads: scoredThreads.map((s) => s.thread).toList(),
      );
    } catch (e) {
      print('Error loading hot threads: $e');
    }
  }

  Future<void> loadThreads({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = _supabase.auth.currentUser;
      final page = refresh ? 0 : state.currentPage;
      final offset = page * 20;

      final query = _supabase
          .from('discussion_topics')
          .select('''
            *,
            profiles:user_id(display_name, avatar_url, username)
          ''')
          .order('created_at', ascending: false)
          .range(offset, offset + 19);

      final response = await query;

      // Create fresh Thread objects, don't mutate
      final newThreads = response.map((json) {
        final t = Thread.fromJson(json);
        if (user != null) {
          return _copyThread(
            t,
            isFollowingAuthor: state.followedUsers.contains(t.userId),
            isSaved: state.savedThreads.contains(t.id),
            isLiked: state.likedThreads.contains(t.id),
            isWatching: state.watchedThreads.contains(t.id),
          );
        }
        return t;
      }).toList();

      final allThreads = refresh ? newThreads : [...state.threads, ...newThreads];

      state = state.copyWith(
        threads: allThreads,
        hasMore: newThreads.length == 20,
        currentPage: refresh ? 1 : page + 1,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  List<Thread> getMixedFeed() {
    final List<Thread> mixed = [];
    final Set<String> usedHotIds = {...state.shownHotIds};
    final List<Thread> availableHot = state.hotThreads
        .where((t) => !usedHotIds.contains(t.id))
        .toList();

    final List<Thread> newThreads = [...state.threads];

    int hotIndex = 0;
    int newIndex = 0;
    int position = 1;

    while (newIndex < newThreads.length) {
      if ((position == 1 || position % 5 == 0) && hotIndex < availableHot.length) {
        final hot = availableHot[hotIndex];
        mixed.add(hot);
        usedHotIds.add(hot.id);
        hotIndex++;
      } else {
        final thread = newThreads[newIndex];
        if (!usedHotIds.contains(thread.id)) {
          mixed.add(thread);
        }
        newIndex++;
      }
      position++;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      state = state.copyWith(shownHotIds: usedHotIds);
    });

    return mixed;
  }

  Future<void> createThread({
    required String title,
    required String content,
    required bool isAnonymous,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    try {
      await _supabase.from('discussion_topics').insert({
        'user_id': user.id,
        'title': title,
        'content': content,
        'is_anonymous': isAnonymous,
      });

      await loadThreads(refresh: true);
      await loadHotThreads();
    } catch (e) {
      throw Exception('Failed to create thread: $e');
    }
  }

  Future<void> toggleLike(String targetId, String targetType) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Check database for true current state
    final existingLike = await _supabase
        .from('discussion_likes')
        .select()
        .eq('user_id', user.id)
        .eq('target_id', targetId)
        .eq('target_type', targetType)
        .maybeSingle();

    final currentlyLiked = existingLike != null;

    try {
      if (currentlyLiked) {
        // UNLIKE
        await _supabase
            .from('discussion_likes')
            .delete()
            .eq('user_id', user.id)
            .eq('target_id', targetId)
            .eq('target_type', targetType);

        if (targetType == 'topic') {
          final newLiked = Set<String>.from(state.likedThreads)..remove(targetId);
          state = state.copyWith(likedThreads: newLiked);

          final updatedThreads = state.threads.map((t) {
            if (t.id == targetId) {
              // ✅ Create a NEW Thread instance instead of mutating
              return _copyThread(t, likeCount: t.likeCount - 1, isLiked: false);
            }
            return t;
          }).toList();
          state = state.copyWith(threads: updatedThreads);
        }
      } else {
        // LIKE
        await _supabase.from('discussion_likes').insert({
          'user_id': user.id,
          'target_id': targetId,
          'target_type': targetType,
        });

        if (targetType == 'topic') {
          final newLiked = Set<String>.from(state.likedThreads)..add(targetId);
          state = state.copyWith(likedThreads: newLiked);

          final updatedThreads = state.threads.map((t) {
            if (t.id == targetId) {
              // ✅ Create a NEW Thread instance instead of mutating
              return _copyThread(t, likeCount: t.likeCount + 1, isLiked: true);
            }
            return t;
          }).toList();
          state = state.copyWith(threads: updatedThreads);
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  Future<void> toggleSave(String topicId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Check database for true current state
    final existingSave = await _supabase
        .from('discussion_saves')
        .select()
        .eq('user_id', user.id)
        .eq('topic_id', topicId)
        .maybeSingle();

    final currentlySaved = existingSave != null;

    try {
      if (currentlySaved) {
        await _supabase
            .from('discussion_saves')
            .delete()
            .eq('user_id', user.id)
            .eq('topic_id', topicId);

        final newSaved = Set<String>.from(state.savedThreads)..remove(topicId);
        state = state.copyWith(savedThreads: newSaved);

        final updatedThreads = state.threads.map((t) {
          if (t.id == topicId) {
            // ✅ Create a NEW Thread instance instead of mutating
            return _copyThread(t, saveCount: t.saveCount - 1, isSaved: false);
          }
          return t;
        }).toList();
        state = state.copyWith(threads: updatedThreads);
      } else {
        await _supabase.from('discussion_saves').insert({
          'user_id': user.id,
          'topic_id': topicId,
        });

        final newSaved = Set<String>.from(state.savedThreads)..add(topicId);
        state = state.copyWith(savedThreads: newSaved);

        final updatedThreads = state.threads.map((t) {
          if (t.id == topicId) {
            // ✅ Create a NEW Thread instance instead of mutating
            return _copyThread(t, saveCount: t.saveCount + 1, isSaved: true);
          }
          return t;
        }).toList();
        state = state.copyWith(threads: updatedThreads);
      }
    } catch (e) {
      print('Error toggling save: $e');
    }
  }

  Future<void> toggleWatch(String topicId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Check database for true current state
    final existingWatch = await _supabase
        .from('discussion_watches')
        .select()
        .eq('user_id', user.id)
        .eq('topic_id', topicId)
        .maybeSingle();

    final currentlyWatching = existingWatch != null;

    try {
      if (currentlyWatching) {
        await _supabase
            .from('discussion_watches')
            .delete()
            .eq('user_id', user.id)
            .eq('topic_id', topicId);

        final newWatched = Set<String>.from(state.watchedThreads)..remove(topicId);
        state = state.copyWith(watchedThreads: newWatched);

        final updatedThreads = state.threads.map((t) {
          if (t.id == topicId) {
            // ✅ Create a NEW Thread instance instead of mutating
            return _copyThread(t, isWatching: false);
          }
          return t;
        }).toList();
        state = state.copyWith(threads: updatedThreads);
      } else {
        await _supabase.from('discussion_watches').insert({
          'user_id': user.id,
          'topic_id': topicId,
        });

        final newWatched = Set<String>.from(state.watchedThreads)..add(topicId);
        state = state.copyWith(watchedThreads: newWatched);

        final updatedThreads = state.threads.map((t) {
          if (t.id == topicId) {
            // ✅ Create a NEW Thread instance instead of mutating
            return _copyThread(t, isWatching: true);
          }
          return t;
        }).toList();
        state = state.copyWith(threads: updatedThreads);
      }
    } catch (e) {
      print('Error toggling watch: $e');
    }
  }

  Future<void> toggleFollow(String followType, String followId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final isFollowing = state.followedUsers.contains(followId);

    try {
      if (isFollowing) {
        await _supabase
            .from('discussion_follows')
            .delete()
            .eq('user_id', user.id)
            .eq('follow_type', followType)
            .eq('follow_id', followId);

        final newFollowed = Set<String>.from(state.followedUsers)..remove(followId);
        state = state.copyWith(followedUsers: newFollowed);

        final updatedThreads = state.threads.map((t) {
          if (t.userId == followId) {
            // ✅ Create a NEW Thread instance instead of mutating
            return _copyThread(t, isFollowingAuthor: false);
          }
          return t;
        }).toList();
        state = state.copyWith(threads: updatedThreads);
      } else {
        await _supabase.from('discussion_follows').insert({
          'user_id': user.id,
          'follow_type': followType,
          'follow_id': followId,
        });

        final newFollowed = Set<String>.from(state.followedUsers)..add(followId);
        state = state.copyWith(followedUsers: newFollowed);

        final updatedThreads = state.threads.map((t) {
          if (t.userId == followId) {
            // ✅ Create a NEW Thread instance instead of mutating
            return _copyThread(t, isFollowingAuthor: true);
          }
          return t;
        }).toList();
        state = state.copyWith(threads: updatedThreads);
      }
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }

  Future<void> addComment(String topicId, String content, {String? parentId}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    try {
      await _supabase.from('discussion_comments').insert({
        'topic_id': topicId,
        'user_id': user.id,
        'content': content,
        'parent_id': parentId,
      });

      await _supabase.rpc('increment_comment_count', params: {'topic_id': topicId});

      await loadThreads(refresh: true);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> deleteComment(String commentId, String topicId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase
          .from('discussion_comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', user.id);

      await _supabase.rpc('decrement_comment_count', params: {'topic_id': topicId});

      await loadThreads(refresh: true);
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }

  Future<void> deleteThread(String threadId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase
          .from('discussion_topics')
          .delete()
          .eq('id', threadId)
          .eq('user_id', user.id);

      await loadThreads(refresh: true);
      await loadHotThreads();
    } catch (e) {
      print('Error deleting thread: $e');
    }
  }

  Future<void> reportContent({
    required String targetId,
    required String targetType,
    required String reason,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('discussion_reports').insert({
        'user_id': user.id,
        'target_id': targetId,
        'target_type': targetType,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error reporting content: $e');
    }
  }

  void refresh() {
    loadThreads(refresh: true);
    loadHotThreads();
    loadUserInteractions();
  }
}