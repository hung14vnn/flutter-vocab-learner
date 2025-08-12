class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? language;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> preferences;
  final int totalWordsLearned;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;
  final String? modelVersion;
  final String? modelName;
  final String? apiKey;
  final List<String>? pinnedQuickActions;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.language,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.preferences = const {},
    this.totalWordsLearned = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.modelVersion,
    this.modelName,
    this.apiKey,
    this.pinnedQuickActions,
  });

  factory AppUser.fromFirestore(Object? data, String id) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      language: map['language'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'] ?? 0),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      totalWordsLearned: map['totalWordsLearned'] ?? 0,
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastStudyDate: map['lastStudyDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastStudyDate'])
          : null,
      modelVersion: map['modelVersion'],
      modelName: map['modelName'],
      apiKey: map['apiKey'],
      pinnedQuickActions: map['pinnedQuickActions'] != null
          ? List<String>.from(map['pinnedQuickActions'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'language': language,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
      'preferences': preferences,
      'totalWordsLearned': totalWordsLearned,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastStudyDate': lastStudyDate?.millisecondsSinceEpoch,
      'modelVersion': modelVersion,
      'modelName': modelName,
      'apiKey': apiKey,
      'pinnedQuickActions': pinnedQuickActions,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? language,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    int? totalWordsLearned,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastStudyDate,
    String? modelVersion,
    String? modelName,
    String? apiKey,
    List<String>? pinnedQuickActions,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      modelVersion: modelVersion ?? this.modelVersion,
      modelName: modelName ?? this.modelName,
      apiKey: apiKey ?? this.apiKey,
      pinnedQuickActions: pinnedQuickActions ?? this.pinnedQuickActions,
    );
  }
}
