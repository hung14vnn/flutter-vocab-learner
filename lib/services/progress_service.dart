import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'user_progress';

  // Get user's progress for all words
  Stream<List<UserProgress>> getUserProgress(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('lastReviewedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProgress.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get progress for a specific word
  Future<UserProgress?> getWordProgress(String userId, String wordId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('wordId', isEqualTo: wordId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserProgress.fromFirestore(
            snapshot.docs.first.data(), snapshot.docs.first.id);
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
      UserProgress? existingProgress =
          await getWordProgress(progress.userId, progress.wordId);

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
      String userId, String wordId, bool isCorrect) async {
    try {
      UserProgress? progress = await getWordProgress(userId, wordId);
      
      DateTime now = DateTime.now();
      DateTime nextReview = _calculateNextReview(
          progress?.repetitionLevel ?? 0, isCorrect);

      if (progress == null) {
        // Create new progress
        progress = UserProgress(
          id: '',
          userId: userId,
          wordId: wordId,
          correctAnswers: isCorrect ? 1 : 0,
          totalAttempts: 1,
          lastReviewedAt: now,
          nextReviewAt: nextReview,
          repetitionLevel: isCorrect ? 1 : 0,
          isLearned: false,
        );
      } else {
        // Update existing progress
        int newCorrectAnswers = progress.correctAnswers + (isCorrect ? 1 : 0);
        int newTotalAttempts = progress.totalAttempts + 1;
        int newRepetitionLevel = isCorrect 
            ? progress.repetitionLevel + 1 
            : 0;
        
        // Mark as learned if answered correctly 5 times in a row
        bool isLearned = newRepetitionLevel >= 5;

        progress = progress.copyWith(
          correctAnswers: newCorrectAnswers,
          totalAttempts: newTotalAttempts,
          lastReviewedAt: now,
          nextReviewAt: nextReview,
          repetitionLevel: newRepetitionLevel,
          isLearned: isLearned,
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
        .where('nextReviewAt', isLessThanOrEqualTo: DateTime.now().millisecondsSinceEpoch)
        .where('isLearned', isEqualTo: false)
        .orderBy('nextReviewAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProgress.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get learned words
  Stream<List<UserProgress>> getLearnedWords(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isLearned', isEqualTo: true)
        .orderBy('lastReviewedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProgress.fromFirestore(doc.data(), doc.id))
            .toList());
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
      int totalAttempts = allProgress.fold(0, (total, p) => total + p.totalAttempts);
      int totalCorrect = allProgress.fold(0, (total, p) => total + p.correctAnswers);
      double averageAccuracy = totalAttempts > 0 ? totalCorrect / totalAttempts : 0.0;

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
    List<int> intervals = [1, 3, 7, 14, 30, 90, 180, 365];
    
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
}
