class UserProgress {
  final String id;
  final String userId;
  final String gameId;
  final List<String> wordIds;
  final List<String> wrongAnswers;
  final List<String> correctAnswers;
  final int totalAttempts;
  final DateTime lastReviewedAt;
  final DateTime due;
  final bool isLearned;

  UserProgress({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.wordIds,
    this.wrongAnswers = const [],
    this.correctAnswers = const [],
    this.totalAttempts = 0,
    required this.lastReviewedAt,
    required this.due,
    this.isLearned = false,
  });

  factory UserProgress.fromFirestore(Object? data, String id) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return UserProgress(
      id: id,
      userId: map['userId'] ?? '',
      gameId: map['gameId'] ?? '',
      wordIds: List<String>.from(map['wordIds'] ?? []),
      correctAnswers: List<String>.from(map['correctAnswers'] ?? []),
      wrongAnswers: List<String>.from(map['wrongAnswers'] ?? []),
      totalAttempts: map['totalAttempts'] ?? 0,
      lastReviewedAt: DateTime.fromMillisecondsSinceEpoch(map['lastReviewedAt'] ?? 0),
      due: DateTime.fromMillisecondsSinceEpoch(map['due'] ?? 0),
      isLearned: map['isLearned'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'gameId': gameId,
      'wordIds': wordIds,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'totalAttempts': totalAttempts,
      'lastReviewedAt': lastReviewedAt.millisecondsSinceEpoch,
      'due': due.millisecondsSinceEpoch,
      'isLearned': isLearned,
    };
  }

  double get accuracy {
    //if (totalAttempts == 0) return 0.0;
    return (correctAnswers.length / wordIds.length).clamp(0.0, 1.0);
  }
  String get toJSONString {
    return 'UserProgress(id: $id, userId: $userId, gameId: $gameId, wordIds: $wordIds, correctAnswers: $correctAnswers, wrongAnswers: $wrongAnswers, totalAttempts: $totalAttempts, lastReviewedAt: $lastReviewedAt, due: $due, isLearned: $isLearned)';
  }

  UserProgress copyWith({
    String? id,
    String? userId,
    String? gameId,
    List<String>? wordIds,
    List<String>? wrongAnswers,
    List<String>? correctAnswers,
    int? totalAttempts,
    DateTime? lastReviewedAt,
    DateTime? due,
    int? repetitionLevel,
    bool? isLearned,
  }) {
    return UserProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameId: gameId ?? this.gameId,
      wordIds: wordIds ?? this.wordIds,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      due: due ?? this.due,
      isLearned: isLearned ?? this.isLearned,
    );
  }
}
