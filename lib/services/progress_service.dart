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
  ) async {
    try {
      DateTime now = DateTime.now();
      var progress = await getProgress(userId, sessionId);
      for (var wordId in wordIds) {
        updateWordProgress(userId, wordId.keys.first, wordId.values.first);
      }
      if (progress == null) {
        // Create new progress
        progress = UserProgress(
          id: sessionId,
          userId: userId,
          gameId: 'practice',
          wordIds: wordIds.map((e) => e.keys.first).toList(),
          correctAnswers: wordIds
              .where((e) => e.values.first == true)
              .map((e) => e.keys.first)
              .toList(),
          wrongAnswers: wordIds
              .where((e) => e.values.first == false)
              .map((e) => e.keys.first)
              .toList(),
          totalAttempts: 0,
          lastReviewedAt: now,
          due: now, // Mark as this day's review
          isLearned: wordIds.every((e) => e.values.first),
        );
      } else {
        // Update existing progress
        progress = progress.copyWith(
          wordIds: wordIds.map((e) => e.keys.first).toList(),
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
          isLearned: wordIds.every((e) => e.values.first),
        );
      }

      await updateProgress(progress);
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
          'nextReviewAt',
          isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch,
        )
        .where('isLearned', isEqualTo: false)
        .orderBy('nextReviewAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserProgress.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Get learned words
  Stream<List<UserProgress>> getLearnedWords(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isLearned', isEqualTo: true)
        .orderBy('lastReviewedAt', descending: true)
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

      int totalWords = allProgress.length;
      int learnedWords = allProgress.where((p) => p.isLearned).length;
      int totalAttempts = allProgress.fold(
        0,
        (total, p) => total + p.totalAttempts,
      );
      int totalCorrect = allProgress.fold(
        0,
        (total, p) => total + p.correctAnswers.length,
      );
      double averageAccuracy = totalAttempts > 0
          ? totalCorrect / totalAttempts
          : 0.0;

      return {
        'totalWords': totalWords,
        'learnedWords': learnedWords,
        'totalAttempts': totalAttempts,
        'totalCorrect': totalCorrect,
        'averageAccuracy': averageAccuracy,
        'wordsInProgress': totalWords - learnedWords,
      };
    } catch (e) {
      throw Exception('Failed to get user stats: $e');
    }
  }

  // Calculate next review time using spaced repetition
  DateTime _calculateNextReview(int repetitionLevel, bool isCorrect) {
    if (!isCorrect) {
      // If incorrect, review again in 1 hour
      return DateTime.now().add(const Duration(hours: 1));
    }

    // Spaced repetition intervals (in days)
    List<int> intervals = [1, 2, 3, 5, 7, 14, 30, 60];

    int intervalIndex = repetitionLevel.clamp(0, intervals.length - 1);
    int daysToAdd = intervals[intervalIndex];

    return DateTime.now().add(Duration(days: daysToAdd));
  }

  // Reset word progress (admin function)
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

  Future<void> updateWordProgress(
    String userId,
    String wordId,
    bool isCorrect,
  ) async {
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
}
