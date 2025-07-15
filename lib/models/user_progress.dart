class UserProgress {
  final String id;
  final String userId;
  final String wordId;
  final int correctAnswers;
  final int totalAttempts;
  final DateTime lastReviewedAt;
  final DateTime nextReviewAt;
  final int repetitionLevel; // Spaced repetition level
  final bool isLearned;

  UserProgress({
    required this.id,
    required this.userId,
    required this.wordId,
    this.correctAnswers = 0,
    this.totalAttempts = 0,
    required this.lastReviewedAt,
    required this.nextReviewAt,
    this.repetitionLevel = 0,
    this.isLearned = false,
  });

  factory UserProgress.fromFirestore(Object? data, String id) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return UserProgress(
      id: id,
      userId: map['userId'] ?? '',
      wordId: map['wordId'] ?? '',
      correctAnswers: map['correctAnswers'] ?? 0,
      totalAttempts: map['totalAttempts'] ?? 0,
      lastReviewedAt: DateTime.fromMillisecondsSinceEpoch(map['lastReviewedAt'] ?? 0),
      nextReviewAt: DateTime.fromMillisecondsSinceEpoch(map['nextReviewAt'] ?? 0),
      repetitionLevel: map['repetitionLevel'] ?? 0,
      isLearned: map['isLearned'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'wordId': wordId,
      'correctAnswers': correctAnswers,
      'totalAttempts': totalAttempts,
      'lastReviewedAt': lastReviewedAt.millisecondsSinceEpoch,
      'nextReviewAt': nextReviewAt.millisecondsSinceEpoch,
      'repetitionLevel': repetitionLevel,
      'isLearned': isLearned,
    };
  }

  double get accuracy {
    if (totalAttempts == 0) return 0.0;
    return correctAnswers / totalAttempts;
  }

  UserProgress copyWith({
    String? id,
    String? userId,
    String? wordId,
    int? correctAnswers,
    int? totalAttempts,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    int? repetitionLevel,
    bool? isLearned,
  }) {
    return UserProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      wordId: wordId ?? this.wordId,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      repetitionLevel: repetitionLevel ?? this.repetitionLevel,
      isLearned: isLearned ?? this.isLearned,
    );
  }
}
