class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> preferences;
  final int totalWordsLearned;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.preferences = const {},
    this.totalWordsLearned = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
  });

  factory AppUser.fromFirestore(Object? data, String id) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'] ?? 0),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      totalWordsLearned: map['totalWordsLearned'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastStudyDate: map['lastStudyDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastStudyDate'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
      'preferences': preferences,
      'totalWordsLearned': totalWordsLearned,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastStudyDate': lastStudyDate?.millisecondsSinceEpoch,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    int? totalWordsLearned,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }
}
