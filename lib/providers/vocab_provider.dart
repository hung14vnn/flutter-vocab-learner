import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocab_word.dart';
import '../services/vocab_service.dart';

class VocabProvider with ChangeNotifier {
  final VocabService _vocabService = VocabService();

  List<VocabWord> _allWords = [];
  List<VocabWord> _filteredWords = [];
  bool _isLoading = false;
  bool _isFirstLoading = true;
  bool _isSearching = false;
  String? _errorMessage;
  String _selectedDifficulty = 'all';
  String _selectedPartOfSpeech = 'all';
  String _selectedState = 'all';
  String _selectedTag = 'all';
  String _selectedDeckId = ''; // Empty string means 'all'
  String _searchQuery = '';
  DateTime? _createdAfter;
  DateTime? _createdBefore;
  String? _currentUserId;
  Set<String> _selectedWordIds = <String>{};
  bool _isSelectionMode = false;
  bool _isCompactMode = false;
  
  // Pagination state
  bool _isPaginationEnabled = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  DocumentSnapshot? _lastDocument;
  
  // Page-based pagination state
  int _currentPage = 1;
  int _itemsPerPage = 20;
  int _totalItems = 0;
  final List<int> _availablePageSizes = [10, 20, 50, 100];

  List<VocabWord> get allWords => _allWords;
  List<VocabWord> get filteredWords => _filteredWords;
  bool get isLoading => _isLoading;
  bool get isFirstLoading => _isFirstLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get selectedDifficulty => _selectedDifficulty;
  String get selectedPartOfSpeech => _selectedPartOfSpeech;
  String get selectedState => _selectedState;
  String get selectedTag => _selectedTag;
  String get selectedDeckId => _selectedDeckId;
  String get searchQuery => _searchQuery;
  DateTime? get createdAfter => _createdAfter;
  DateTime? get createdBefore => _createdBefore;
  String? get currentUserId =>
      _currentUserId; // Added a getter for currentUserId
  Set<String> get selectedWordIds => _selectedWordIds;
  bool get isSelectionMode => _isSelectionMode;
  bool get isCompactMode => _isCompactMode;
  bool get isPaginationEnabled => _isPaginationEnabled;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalItems => _totalItems;
  List<int> get availablePageSizes => _availablePageSizes;
  int get totalPages => (_totalItems / _itemsPerPage).ceil();
  int get selectedCount => _selectedWordIds.length;

  VocabProvider();

  void setUserId(String? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      if (userId != null) {
        if (_isPaginationEnabled) {
          _loadWordsPageBased();
        } else {
          _loadWordsPaginated(reset: true);
        }
      } else {
        _allWords = [];
        _filteredWords = [];
        _resetPaginationState();
        notifyListeners();
      }
    }
  }

  void _resetPaginationState() {
    _lastDocument = null;
    _hasMoreData = true;
    _isLoadingMore = false;
    _currentPage = 1;
    _totalItems = 0;
  }

  Future<void> _loadWordsPaginated({bool reset = false}) async {
    if (_currentUserId == null) return;

    if (reset) {
      _resetPaginationState();
      _allWords = [];
      _filteredWords = [];
      // Don't show loading for infinite mode
      if (_isPaginationEnabled) {
        _setLoading(true);
      }
    } else {
      if (_isLoadingMore || !_hasMoreData) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final result = await _vocabService.getWordsFilteredPaginated(
        _currentUserId!,
        difficulty: _selectedDifficulty,
        partOfSpeech: _selectedPartOfSpeech,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        deckId: _selectedDeckId.isEmpty ? null : _selectedDeckId,
        limit: _itemsPerPage,
        lastDocument: _lastDocument,
      );

      if (reset) {
        _allWords = result.words;
      } else {
        _allWords.addAll(result.words);
      }

      if (result.docs.isNotEmpty) {
        _lastDocument = result.docs.last;
      }

      _hasMoreData = result.words.length == _itemsPerPage;
      _filteredWords = List.from(_allWords);
      
      if (reset) {
        if (_isPaginationEnabled) {
          _setLoading(false);
        } else {
          // For infinite mode, just set first loading to false without showing loading
          if (_isFirstLoading) {
            _isFirstLoading = false;
          }
        }
        _setSearching(false);
      } else {
        _isLoadingMore = false;
      }
      
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Failed to load vocabulary: $error';
      if (reset) {
        if (_isPaginationEnabled) {
          _setLoading(false);
        } else {
          // For infinite mode, just set first loading to false without showing loading
          if (_isFirstLoading) {
            _isFirstLoading = false;
          }
        }
        _setSearching(false);
      } else {
        _isLoadingMore = false;
      }
      notifyListeners();
    }
  }

  Future<void> _loadWordsPageBased() async {
    if (_currentUserId == null) return;

    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _vocabService.getWordsByPage(
        _currentUserId!,
        difficulty: _selectedDifficulty,
        partOfSpeech: _selectedPartOfSpeech,
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        deckId: _selectedDeckId.isEmpty ? null : _selectedDeckId,
        page: _currentPage,
        itemsPerPage: _itemsPerPage,
      );

      _allWords = result.words;
      _filteredWords = List.from(_allWords);
      _totalItems = result.totalCount;
      
      _setLoading(false);
      _setSearching(false);
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Failed to load vocabulary: $error';
      _setLoading(false);
      _setSearching(false);
      notifyListeners();
    }
  }

  void setDifficultyFilter(String difficulty) {
    _selectedDifficulty = difficulty;
    _currentPage = 1; // Reset to first page when filtering
    _setSearching(true);
    if (_isPaginationEnabled) {
      _loadWordsPageBased();
    } else {
      _loadWordsPaginated(reset: true);
    }
  }

  void setPartOfSpeechFilter(String partOfSpeech) {
    _selectedPartOfSpeech = partOfSpeech;
    _currentPage = 1; // Reset to first page when filtering
    _setSearching(true);
    if (_isPaginationEnabled) {
      _loadWordsPageBased();
    } else {
      _loadWordsPaginated(reset: true);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1; // Reset to first page when searching
    _setSearching(true);
    if (_isPaginationEnabled) {
      _loadWordsPageBased();
    } else {
      _loadWordsPaginated(reset: true);
    }
  }

  void setStateFilter(String state) {
    _selectedState = state;
    _currentPage = 1; // Reset to first page when filtering
    _setSearching(true);
    if (_isPaginationEnabled) {
      _loadWordsPageBased();
    } else {
      _loadWordsPaginated(reset: true);
    }
  }

  void setTagFilter(String tag) {
    _selectedTag = tag;
    _currentPage = 1; // Reset to first page when filtering
    _setSearching(true);
    if (_isPaginationEnabled) {
      _loadWordsPageBased();
    } else {
      _loadWordsPaginated(reset: true);
    }
  }

  void setDeckFilter(String deckId) {
    _selectedDeckId = deckId;
    _currentPage = 1; // Reset to first page when filtering
    _setSearching(true);
    if (_isPaginationEnabled) {
      _loadWordsPageBased();
    } else {
      _loadWordsPaginated(reset: true);
    }
  }

  void setDateRangeFilter(DateTime? after, DateTime? before) {
    _createdAfter = after;
    _createdBefore = before;
    _currentPage = 1; // Reset to first page when filtering
    if (_isPaginationEnabled) {
      _loadWordsPageBased();
    } else {
      _loadWordsPaginated(reset: true);
    }
  }

  void clearAllFilters() {
    _selectedDifficulty = 'all';
    _selectedPartOfSpeech = 'all';
    _selectedState = 'all';
    _selectedTag = 'all';
    _selectedDeckId = '';
    _searchQuery = '';
    _createdAfter = null;
    _createdBefore = null;
    _currentPage = 1;
    if (_isPaginationEnabled) {
      _loadWordsPageBased();
    } else {
      _loadWordsPaginated(reset: true);
    }
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
    if (!value && _isFirstLoading) {
      _isFirstLoading = false;
    }
    notifyListeners();
  }

  void _setSearching(bool value) {
    _isSearching = value;
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

  List<String> get availableStates => [
    'all',
    'new',
    'learning',
    'reviewed',
    'mastered',
  ];

  List<String> get availableTags {
    Set<String> tags = {'all'};
    for (var word in _allWords) {
      tags.addAll(word.tags);
    }
    return tags.toList();
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

  // Toggle compact mode
  void toggleCompactMode() {
    _isCompactMode = !_isCompactMode;
    notifyListeners();
  }

  // Toggle pagination mode
  void togglePaginationMode() {
    _isPaginationEnabled = !_isPaginationEnabled;
    _resetPaginationState();
    if (_currentUserId != null) {
      if (_isPaginationEnabled) {
        _loadWordsPageBased();
      } else {
        // For infinite mode, load without showing loading
        _loadWordsPaginated(reset: true);
      }
    }
  }

  // Load more data for infinite scroll pagination
  Future<void> loadMoreWords() async {
    if (!_isPaginationEnabled && _hasMoreData && !_isLoadingMore) {
      await _loadWordsPaginated();
    }
  }

  // Page navigation methods
  void goToPage(int page) {
    if (page >= 1 && page <= totalPages && page != _currentPage) {
      _currentPage = page;
      _loadWordsPageBased();
    }
  }

  void goToNextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      _loadWordsPageBased();
    }
  }

  void goToPreviousPage() {
    if (_currentPage > 1) {
      _currentPage--;
      _loadWordsPageBased();
    }
  }

  void goToFirstPage() {
    if (_currentPage != 1) {
      _currentPage = 1;
      _loadWordsPageBased();
    }
  }

  void goToLastPage() {
    if (_currentPage != totalPages && totalPages > 0) {
      _currentPage = totalPages;
      _loadWordsPageBased();
    }
  }

  // Items per page control
  void setItemsPerPage(int itemsPerPage) {
    if (_availablePageSizes.contains(itemsPerPage) && itemsPerPage != _itemsPerPage) {
      _itemsPerPage = itemsPerPage;
      _currentPage = 1; // Reset to first page when changing page size
      if (_isPaginationEnabled) {
        _loadWordsPageBased();
      }
    }
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
