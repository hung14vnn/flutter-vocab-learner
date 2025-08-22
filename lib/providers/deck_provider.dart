import 'package:flutter/foundation.dart';
import '../models/deck.dart';
import '../services/deck_service.dart';

class DeckProvider with ChangeNotifier {
  final DeckService _deckService = DeckService();
  
  List<Deck> _decks = [];
  Deck? _selectedDeck;
  bool _isLoading = false;
  String? _error;

  List<Deck> get decks => _decks;
  Deck? get selectedDeck => _selectedDeck;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all decks for a user
  void getUserDecks(String userId) {
    _deckService.getUserDecks(userId).listen(
      (decks) {
        _decks = decks;
        // Set the first deck as selected if none is selected
        if (_selectedDeck == null && decks.isNotEmpty) {
          _selectedDeck = decks.first;
        }
        // Check if the selected deck still exists in the list
        if (_selectedDeck != null && !decks.any((deck) => deck.id == _selectedDeck!.id)) {
          _selectedDeck = decks.isNotEmpty ? decks.first : null;
        }
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Select a deck
  void selectDeck(Deck? deck) {
    _selectedDeck = deck;
    notifyListeners();
  }

  // Create a new deck
  Future<void> createDeck(Deck deck) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final deckId = await _deckService.createDeck(deck);
      
      // The deck will be automatically added to the list via the stream
      // but we can set it as selected immediately
      final createdDeck = deck.copyWith(id: deckId);
      _selectedDeck = createdDeck;
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a deck
  Future<void> updateDeck(String deckId, Deck deck) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _deckService.updateDeck(deckId, deck);
      
      // Update the selected deck if it's the one being updated
      if (_selectedDeck?.id == deckId) {
        _selectedDeck = deck;
      }
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a deck
  Future<void> deleteDeck(String deckId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _deckService.deleteDeck(deckId);
      
      // If the deleted deck was selected, select another one
      if (_selectedDeck?.id == deckId) {
        _selectedDeck = _decks.where((deck) => deck.id != deckId).isNotEmpty 
            ? _decks.where((deck) => deck.id != deckId).first 
            : null;
      }
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a word to a deck
  Future<void> addWordToDeck(String deckId, String wordId) async {
    try {
      await _deckService.addWordToDeck(deckId, wordId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Remove a word from a deck
  Future<void> removeWordFromDeck(String deckId, String wordId) async {
    try {
      await _deckService.removeWordFromDeck(deckId, wordId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get deck by ID
  Deck? getDeckById(String deckId) {
    try {
      return _decks.firstWhere((deck) => deck.id == deckId);
    } catch (e) {
      return null;
    }
  }

  // Create default deck for new users
  Future<void> createDefaultDeck(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _deckService.createDefaultDeck(userId);
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all data (useful for logout)
  void clear() {
    _decks = [];
    _selectedDeck = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Get deck name by ID (helper method for UI)
  String getDeckName(String? deckId) {
    if (deckId == null) return 'No Deck';
    final deck = getDeckById(deckId);
    return deck?.name ?? 'Unknown Deck';
  }
}
