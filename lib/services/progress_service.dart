import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vocab_learner/models/vocab_word.dart';
import '../models/user_progress.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'user_progress';
  final String _vocabWordsCollection = 'vocab_words';

  // Get user's progress for all words
  Stream<List<UserProgress>> getUserProgress(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('lastReviewedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserProgress.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<VocabWord> getWord(String wordId) {
    return _firestore.collection(_vocabWordsCollection).doc(wordId).get().then((
      doc,
    ) {
      if (doc.exists) {
        return VocabWord.fromFirestore(doc.data(), doc.id);
      } else {
        throw Exception('Word with ID $wordId does not exist');
      }
    });
  }

  // Get progress
  Future<UserProgress?> getProgress(String userId, String id) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserProgress.fromFirestore(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get word progress: $e');
    }
  }

  // Update or create progress
  Future<void> updateProgress(UserProgress progress) async {
    try {
      // Check if progress exists
      UserProgress? existingProgress = await getProgress(
        progress.userId,
        progress.id,
      );

      if (existingProgress != null) {
        // Update existing progress
        await _firestore
            .collection(_collection)
            .doc(existingProgress.id)
            .update(progress.copyWith(id: existingProgress.id).toFirestore());
      } else {
        // Create new progress
        await _firestore.collection(_collection).add(progress.toFirestore());
      }
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }

  // Record a practice session
  Future<void> recordPracticeSession(
    String sessionId,
    String userId,
    List<Map<String, bool>> wordIds,
    List<String> listOfWords,
    String gameId,
    bool isContinueProgress,
  ) async {
    try {
      if (isContinueProgress) {
        // Continue existing progress
        var progress = await getProgress(userId, sessionId);
        if (progress != null) {
          for (var wordId in wordIds) {
            updateWordProgress(wordId.keys.first, wordId.values.first);
          }
          final correct = progress.correctAnswers
              .followedBy(
                wordIds
                    .where((e) => e.values.first == true)
                    .map((e) => e.keys.first),
              )
              .toList();
          final wrong = progress.wrongAnswers
              .followedBy(
                wordIds
                    .where((e) => e.values.first == false)
                    .map((e) => e.keys.first),
              )
              .toList();

          progress = progress.copyWith(
            correctAnswers: correct,
            wrongAnswers: wrong,
            lastReviewedAt: DateTime.now(),
            isLearned: listOfWords.every(
              (word) => correct.contains(word) || wrong.contains(word),
            ),
          );
        }
      } else {
        DateTime now = DateTime.now();
        var progress = await getProgress(userId, sessionId);
        for (var wordId in wordIds) {
          updateWordProgress(wordId.keys.first, wordId.values.first);
        }
        if (progress == null) {
          // Create new progress
          progress = UserProgress(
            id: sessionId,
            userId: userId,
            gameId: gameId,
            wordIds: listOfWords,
            correctAnswers: wordIds
                .where((e) => e.values.first == true)
                .map((e) => e.keys.first)
                .toList(),
            wrongAnswers: wordIds
                .where((e) => e.values.first == false)
                .map((e) => e.keys.first)
                .toList(),
            totalAttempts: 1,
            lastReviewedAt: now,
            due: now, // Mark as this day's review
            isLearned: listOfWords.every(
              (word) =>
                  wordIds.any((e) => e.keys.first == word && e.values.first),
            ),
          );
        } else {
          // Update existing progress
          progress = progress.copyWith(
            correctAnswers: wordIds
                .where((e) => e.values.first == true)
                .map((e) => e.keys.first)
                .toList(),
            wrongAnswers: wordIds
                .where((e) => e.values.first == false)
                .map((e) => e.keys.first)
                .toList(),
            totalAttempts: progress.totalAttempts + 1,
            lastReviewedAt: now,
            isLearned: listOfWords.every(
              (word) =>
                  wordIds.any((e) => e.keys.first == word && e.values.first),
            ),
          );
        }
        await updateProgress(progress);
      }
    } catch (e) {
      throw Exception('Failed to record practice session: $e');
    }
  }

  // Get words due for review
  Stream<List<UserProgress>> getWordsForReview(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where(
          'due',
          isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch,
        )
        .where('isLearned', isEqualTo: false)
        .orderBy('due')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserProgress.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      List<UserProgress> allProgress = snapshot.docs
          .map((doc) => UserProgress.fromFirestore(doc.data(), doc.id))
          .toList();

      int totalWrong = allProgress.fold(0, (total, p) => total + p.wrongAnswers.length);
      int totalProgressLearned = allProgress.where((p) => p.isLearned).length;

      int totalWordsDistinct = allProgress
          .expand((p) => p.wordIds)
          .toSet()
          .length;
      int totalLearnedWordsDistinct = allProgress
          .where((p) => p.isLearned)
          .expand((p) => p.wordIds)
          .toSet()
          .length;

      int totalCorrect = allProgress.fold(
        0,
        (total, p) => total + p.correctAnswers.length,
      );
      double averageAccuracy = allProgress.isEmpty
          ? 0.0
          : totalCorrect / (totalCorrect + totalWrong);

      return {
        'totalWords': totalWordsDistinct,
        'learnedWords': totalLearnedWordsDistinct,
        'averageAccuracy': averageAccuracy,
        'totalProgressLearned': totalProgressLearned
      };
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  DateTime _calculateNextReview(int repetitionLevel, bool isCorrect) {
    if (!isCorrect) {
      return DateTime.now().add(const Duration(hours: 1));
    }

    List<int> intervals = [1, 2, 3, 5, 7, 14, 30, 60];

    int intervalIndex = repetitionLevel.clamp(0, intervals.length - 1);
    int daysToAdd = intervals[intervalIndex];

    return DateTime.now().add(Duration(days: daysToAdd));
  }

  Future<void> resetWordProgress(String userId, String wordId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('wordId', isEqualTo: wordId)
          .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to reset word progress: $e');
    }
  }

  Future<void> updateWordProgress(String wordId, bool isCorrect) async {
    try {
      var word = await getWord(wordId);
      DateTime nextReview = _calculateNextReview(
        word.repetitionLevel,
        isCorrect,
      );
      VocabWord updatedWord = word.copyWith(
        repetitionLevel: isCorrect ? word.repetitionLevel + 1 : 0,
        due: nextReview,
        state: (word.repetitionLevel >= 7 && isCorrect
            ? WordState.learningState
            : isCorrect
            ? WordState.reviewedState
            : WordState.newWordState),
      );
      await _firestore
          .collection(_vocabWordsCollection)
          .doc(wordId)
          .update(updatedWord.toFirestore());
    } catch (e) {
      throw Exception('Failed to update word progress: $e');
    }
  }

  /// Check if user has today's progress for flashcards
  Future<UserProgress?> getTodayProgress(String userId, String gameId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('gameId', isEqualTo: gameId)
          .where('lastReviewedAt', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
          .where('lastReviewedAt', isLessThanOrEqualTo: endOfDay.millisecondsSinceEpoch)
          .orderBy('lastReviewedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserProgress.fromFirestore(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      // If the compound query fails, try a simpler approach
      try {
        DateTime now = DateTime.now();
        DateTime startOfDay = DateTime(now.year, now.month, now.day);

        QuerySnapshot snapshot = await _firestore
            .collection(_collection)
            .where('userId', isEqualTo: userId)
            .where('gameId', isEqualTo: gameId)
            .orderBy('lastReviewedAt', descending: true)
            .limit(10)
            .get();

        for (QueryDocumentSnapshot doc in snapshot.docs) {
          UserProgress progress = UserProgress.fromFirestore(doc.data(), doc.id);
          if (progress.lastReviewedAt.isAfter(startOfDay)) {
            return progress;
          }
        }
        return null;
      } catch (e) {
        print('Error getting today progress: $e');
        return null;
      }
    }
  }

  /// Create a new daily progress session
  Future<String> createTodayProgress(String userId, List<String> wordIds, String gameId) async {
    try {
      DateTime now = DateTime.now();
      String sessionId = 'daily_${userId}_${now.year}_${now.month}_${now.day}';
      
      UserProgress newProgress = UserProgress(
        id: sessionId,
        userId: userId,
        gameId: gameId,
        wordIds: wordIds,
        correctAnswers: [],
        wrongAnswers: [],
        totalAttempts: 0,
        lastReviewedAt: now,
        due: now,
        isLearned: false,
      );

      await _firestore.collection(_collection).doc(sessionId).set(newProgress.toFirestore());
      return sessionId;
    } catch (e) {
      throw Exception('Failed to create today progress: $e');
    }
  }
}
