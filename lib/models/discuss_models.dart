// lib/models/discuss_models.dart
class Thread {
  final String id;
  final String userId;
  final String title;
  final String content;
  final bool isAnonymous;
  int likeCount;      // ← REMOVED final
  int commentCount;   // ← REMOVED final
  int saveCount;      // ← REMOVED final
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? profile;
  
  // UI state
  bool isFollowingAuthor;
  bool isSaved;
  bool isLiked;
  bool isWatching;

  Thread({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.isAnonymous,
    required this.likeCount,
    required this.commentCount,
    required this.saveCount,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
    this.isFollowingAuthor = false,
    this.isSaved = false,
    this.isLiked = false,
    this.isWatching = false,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      isAnonymous: json['is_anonymous'] ?? false,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      saveCount: json['save_count'] ?? 0,
      viewCount: json['view_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      profile: json['profiles'],
    );
  }

  String get displayName {
    if (isAnonymous) return 'Anonymous';
    return profile?['display_name'] ?? profile?['username'] ?? 'User';
  }

  String? get avatarUrl {
    if (isAnonymous) return null;
    return profile?['avatar_url'];
  }
}

class Comment {
  final String id;
  final String topicId;
  final String userId;
  final String? parentId;
  final String content;
  int likeCount;      // ← REMOVED final
  final DateTime createdAt;
  final Map<String, dynamic>? profile;
  List<Comment> replies;
  
  // UI state
  bool isLiked;

  Comment({
    required this.id,
    required this.topicId,
    required this.userId,
    this.parentId,
    required this.content,
    required this.likeCount,
    required this.createdAt,
    this.profile,
    this.replies = const [],
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      topicId: json['topic_id'],
      userId: json['user_id'],
      parentId: json['parent_id'],
      content: json['content'],
      likeCount: json['like_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      profile: json['profiles'],
    );
  }

  String get displayName => profile?['display_name'] ?? profile?['username'] ?? 'User';
  String? get avatarUrl => profile?['avatar_url'];
}