import 'dart:math' as math;

class UserModel {
  final String id;
  final String displayName;
  final String username;
  final String bio;
  final String location;
  final String website;
  final String avatarUrl;
  final bool isProfileComplete;
  final int assessmentsTaken;
  final int interviewsCompleted;
  final int resumesCreated;

  const UserModel({
    required this.id,
    this.displayName = '',
    this.username = '',
    this.bio = '',
    this.location = '',
    this.website = '',
    this.avatarUrl = '',
    this.isProfileComplete = false,
    this.assessmentsTaken = 0,
    this.interviewsCompleted = 0,
    this.resumesCreated = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      displayName: map['display_name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      location: map['location'] as String? ?? '',
      website: map['website'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String? ?? '',
      isProfileComplete: map['is_profile_complete'] as bool? ?? false,
      assessmentsTaken: map['assessments_taken'] as int? ?? 0,
      interviewsCompleted: map['interviews_completed'] as int? ?? 0,
      resumesCreated: map['resumes_created'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'username': username,
      'bio': bio,
      'location': location,
      'website': website,
      'avatar_url': avatarUrl,
      'is_profile_complete': isProfileComplete,
      'assessments_taken': assessmentsTaken,
      'interviews_completed': interviewsCompleted,
      'resumes_created': resumesCreated,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? username,
    String? bio,
    String? location,
    String? website,
    String? avatarUrl,
    bool? isProfileComplete,
    int? assessmentsTaken,
    int? interviewsCompleted,
    int? resumesCreated,
  }) {
    return UserModel(
      id: id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      assessmentsTaken: assessmentsTaken ?? this.assessmentsTaken,
      interviewsCompleted: interviewsCompleted ?? this.interviewsCompleted,
      resumesCreated: resumesCreated ?? this.resumesCreated,
    );
  }

  static UserModel empty(String id) => UserModel(id: id);

  /// Handle from display name + 2–3 random letters/digits (`username` must stay unique in DB).
  static String suggestUsername(String displayName) {
    var clean = displayName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    clean = clean.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (clean.isEmpty) clean = 'user';
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = math.Random();
    final len = 2 + r.nextInt(2); // 2 or 3 characters
    final suffix = String.fromCharCodes(
      Iterable.generate(
        len,
        (_) => chars.codeUnitAt(r.nextInt(chars.length)),
      ),
    );
    return '@$clean$suffix';
  }
}
