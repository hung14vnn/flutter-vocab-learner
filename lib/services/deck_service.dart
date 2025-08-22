import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/deck.dart';

class DeckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'decks';

  // Get all decks for a user
  Stream<List<Deck>> getUserDecks(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Deck.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Get a specific deck by ID
  Future<Deck?> getDeck(String deckId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(deckId).get();
      if (doc.exists) {
        return Deck.fromFirestore(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get deck: $e');
    }
  }

  // Create a new deck
  Future<String> createDeck(Deck deck) async {
    try {
      final docRef = await _firestore.collection(_collection).add(deck.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create deck: $e');
    }
  }

  // Update an existing deck
  Future<void> updateDeck(String deckId, Deck deck) async {
    try {
      await _firestore.collection(_collection).doc(deckId).update(deck.toFirestore());
    } catch (e) {
      throw Exception('Failed to update deck: $e');
    }
  }

  // Delete a deck
  Future<void> deleteDeck(String deckId) async {
    try {
      await _firestore.collection(_collection).doc(deckId).delete();
    } catch (e) {
      throw Exception('Failed to delete deck: $e');
    }
  }

  // Add a word to a deck
  Future<void> addWordToDeck(String deckId, String wordId) async {
    try {
      await _firestore.collection(_collection).doc(deckId).update({
        'wordIds': FieldValue.arrayUnion([wordId]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to add word to deck: $e');
    }
  }

  // Remove a word from a deck
  Future<void> removeWordFromDeck(String deckId, String wordId) async {
    try {
      await _firestore.collection(_collection).doc(deckId).update({
        'wordIds': FieldValue.arrayRemove([wordId]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to remove word from deck: $e');
    }
  }

  // Get decks that contain a specific word
  Future<List<Deck>> getDecksContainingWord(String userId, String wordId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('wordIds', arrayContains: wordId)
          .get();
      
      return snapshot.docs
          .map((doc) => Deck.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get decks containing word: $e');
    }
  }

  // Create a default deck for a user
  Future<String> createDefaultDeck(String userId) async {
    final defaultDeck = Deck(
      id: '',
      userId: userId,
      name: 'My Vocabulary',
      description: 'Default vocabulary deck',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: '#2196F3', // Blue color
      icon: '📚', // Book emoji
    );
    
    return await createDeck(defaultDeck);
  }
}
