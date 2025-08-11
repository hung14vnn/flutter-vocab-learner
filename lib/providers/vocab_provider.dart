import 'package:flutter/foundation.dart';
import '../models/vocab_word.dart';
import '../services/vocab_service.dart';

class VocabProvider with ChangeNotifier {
  final VocabService _vocabService = VocabService();

  List<VocabWord> _allWords = [];
  List<VocabWord> _filteredWords = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedDifficulty = 'all';
  String _selectedPartOfSpeech = 'all';
  String _searchQuery = '';
  String? _currentUserId;
  Set<String> _selectedWordIds = <String>{};
  bool _isSelectionMode = false;

  List<VocabWord> get allWords => _allWords;
  List<VocabWord> get filteredWords => _filteredWords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedDifficulty => _selectedDifficulty;
  String get selectedPartOfSpeech => _selectedPartOfSpeech;
  String get searchQuery => _searchQuery;
  String? get currentUserId =>
      _currentUserId; // Added a getter for currentUserId
  Set<String> get selectedWordIds => _selectedWordIds;
  bool get isSelectionMode => _isSelectionMode;
  int get selectedCount => _selectedWordIds.length;

  VocabProvider();

  void setUserId(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      if (userId != null) {
        _loadAllWords();
      } else {
        _allWords = [];
        _filteredWords = [];
        notifyListeners();
      }
    }
  }

  void _loadAllWords() {
    if (_currentUserId == null) return;

    _setLoading(true);
    _vocabService
        .getAllWords(_currentUserId!)
        .listen(
          (words) {
            _allWords = words;
            _applyFilters();
            _setLoading(false);
          },
          onError: (error) {
            _errorMessage = 'Failed to load vocabulary: $error';
            _setLoading(false);
          },
        );
  }

  void _applyFilters() {
    _filteredWords = _allWords.where((word) {
      bool matchesDifficulty =
          _selectedDifficulty == 'all' ||
          word.difficulty == _selectedDifficulty;

      bool matchesPartOfSpeech =
          _selectedPartOfSpeech == 'all' ||
          word.partOfSpeech == _selectedPartOfSpeech;

      bool matchesSearch =
          _searchQuery.isEmpty ||
          word.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          word.definition.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesDifficulty && matchesPartOfSpeech && matchesSearch;
    }).toList();

    notifyListeners();
  }

  void setDifficultyFilter(String difficulty) {
    _selectedDifficulty = difficulty;
    _applyFilters();
  }

  void setPartOfSpeechFilter(String partOfSpeech) {
    _selectedPartOfSpeech = partOfSpeech;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  Future<List<VocabWord>> getRandomWords(int count) async {
    if (_currentUserId == null) return [];
    try {
      return await _vocabService.getRandomWords(_currentUserId!, count);
    } catch (e) {
      _errorMessage = 'Failed to get random words: $e';
      notifyListeners();
      return [];
    }
  }

  Future<VocabWord?> getWordById(String wordId) async {
    try {
      return await _vocabService.getWordById(wordId);
    } catch (e) {
      _errorMessage = 'Failed to get word: $e';
      notifyListeners();
      return null;
    }
  }

  Future<List<VocabWord>> getWordsByIds(List<String> wordIds) async {
    try {
      return await _vocabService.getWordsByIds(wordIds);
    } catch (e) {
      _errorMessage = 'Failed to get words: $e';
      notifyListeners();
      return [];
    }
  }

  Future<List<VocabWord>> searchWords(String query) async {
    if (_currentUserId == null) return [];
    try {
      return await _vocabService.searchWords(_currentUserId!, query);
    } catch (e) {
      _errorMessage = 'Failed to search words: $e';
      notifyListeners();
      return [];
    }
  }

  // Admin functions
  Future<bool> addWord(VocabWord word) async {
    try {
      await _vocabService.addWord(word);
      // Note: The word will be automatically added to _allWords through the stream listener
      // So we don't need to manually add it to the local list
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add word: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateWord(VocabWord word) async {
    try {
      await _vocabService.updateWord(word);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update word: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWord(String wordId) async {
    try {
      await _vocabService.deleteWord(wordId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete word: $e';
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

  List<String> get availableDifficulties => [
    'all',
    'beginner',
    'intermediate',
    'advanced',
  ];

  List<String> get availablePartsOfSpeech {
    Set<String> partsOfSpeech = {'all'};
    for (var word in _allWords) {
      if (word.partOfSpeech.isNotEmpty) {
        partsOfSpeech.add(word.partOfSpeech);
      }
    }
    return partsOfSpeech.toList();
  }

  // Selection methods
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedWordIds.clear();
    }
    notifyListeners();
  }

  void toggleWordSelection(String wordId) {
    if (_selectedWordIds.contains(wordId)) {
      _selectedWordIds.remove(wordId);
    } else {
      _selectedWordIds.add(wordId);
    }
    
    // If no words are selected, exit selection mode
    if (_selectedWordIds.isEmpty) {
      _isSelectionMode = false;
    }
    
    notifyListeners();
  }

  void selectAllWords() {
    _selectedWordIds = _filteredWords.map((word) => word.id).toSet();
    notifyListeners();
  }

  void clearSelection() {
    _selectedWordIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  bool isWordSelected(String wordId) {
    return _selectedWordIds.contains(wordId);
  }

  // Batch delete selected words
  Future<bool> deleteSelectedWords() async {
    if (_selectedWordIds.isEmpty) return false;
    
    try {
      List<String> wordIdsToDelete = _selectedWordIds.toList();
      
      // Use batch delete for better performance
      await _vocabService.batchDeleteWords(wordIdsToDelete);
      
      // Clear selection after successful deletion
      clearSelection();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete selected words: $e';
      notifyListeners();
      return false;
    }
  }
}
