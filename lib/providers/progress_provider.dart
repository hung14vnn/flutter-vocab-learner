import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../services/progress_service.dart';

class ProgressProvider with ChangeNotifier {
  final ProgressService _progressService = ProgressService();
  
  List<UserProgress> _userProgress = [];
  List<UserProgress> _wordsForReview = [];
  List<UserProgress> _learnedWords = [];
  Map<String, dynamic> _userStats = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<UserProgress> get userProgress => _userProgress;
  List<UserProgress> get wordsForReview => _wordsForReview;
  List<UserProgress> get learnedWords => _learnedWords;
  Map<String, dynamic> get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void initializeForUser(String userId) {
    _loadUserProgress(userId);
    _loadWordsForReview(userId);
    _loadLearnedWords(userId);
    _loadUserStats(userId);
  }

  void _loadUserProgress(String userId) {
    _progressService.getUserProgress(userId).listen(
      (progress) {
        _userProgress = progress;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load progress: $error';
        notifyListeners();
      },
    );
  }

  void _loadWordsForReview(String userId) {
    _progressService.getWordsForReview(userId).listen(
      (words) {
        _wordsForReview = words;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load review words: $error';
        notifyListeners();
      },
    );
  }

  void _loadLearnedWords(String userId) {
    _progressService.getLearnedWords(userId).listen(
      (words) {
        _learnedWords = words;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load learned words: $error';
        notifyListeners();
      },
    );
  }

  Future<void> _loadUserStats(String userId) async {
    try {
      _userStats = await _progressService.getUserStats(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load stats: $e';
      notifyListeners();
    }
  }

  Future<UserProgress?> getWordProgress(String userId, String wordId) async {
    try {
      return await _progressService.getWordProgress(userId, wordId);
    } catch (e) {
      _errorMessage = 'Failed to get word progress: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> recordPracticeSession(
      String userId, String wordId, bool isCorrect) async {
    _setLoading(true);
    try {
      await _progressService.recordPracticeSession(userId, wordId, isCorrect);
      // Refresh stats after recording session
      await _loadUserStats(userId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to record practice: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProgress(UserProgress progress) async {
    try {
      await _progressService.updateProgress(progress);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update progress: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetWordProgress(String userId, String wordId) async {
    try {
      await _progressService.resetWordProgress(userId, wordId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to reset progress: $e';
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    _userProgress.clear();
    _wordsForReview.clear();
    _learnedWords.clear();
    _userStats.clear();
    notifyListeners();
  }

  // Helper methods for statistics
  int get totalWordsStudied => _userStats['totalWords'] ?? 0;
  int get wordsLearned => _userStats['learnedWords'] ?? 0;
  int get wordsInProgress => _userStats['wordsInProgress'] ?? 0;
  double get averageAccuracy => _userStats['averageAccuracy'] ?? 0.0;
  int get totalAttempts => _userStats['totalAttempts'] ?? 0;
  int get totalCorrect => _userStats['totalCorrect'] ?? 0;
  
  double get learningProgress {
    if (totalWordsStudied == 0) return 0.0;
    return wordsLearned / totalWordsStudied;
  }

  int get wordsToReview => _wordsForReview.length;
  
  bool hasWordProgress(String wordId) {
    return _userProgress.any((progress) => progress.wordId == wordId);
  }

  UserProgress? getProgressForWord(String wordId) {
    try {
      return _userProgress.firstWhere((progress) => progress.wordId == wordId);
    } catch (e) {
      return null;
    }
  }
}
