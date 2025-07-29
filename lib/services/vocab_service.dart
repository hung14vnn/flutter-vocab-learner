import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vocab_word.dart';

class VocabService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'vocab_words';

  // Get all vocabulary words for a specific user
  Stream<List<VocabWord>> getAllWords(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          List<VocabWord> words = snapshot.docs
              .map((doc) => VocabWord.fromFirestore(doc.data(), doc.id))
              .toList();
          // Sort in memory by createdAt descending
          words.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return words;
        });
  }

  // Get words by difficulty for a specific user
  Stream<List<VocabWord>> getWordsByDifficulty(
    String userId,
    String difficulty,
  ) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('difficulty', isEqualTo: difficulty)
        .snapshots()
        .map((snapshot) {
          List<VocabWord> words = snapshot.docs
              .map((doc) => VocabWord.fromFirestore(doc.data(), doc.id))
              .toList();
          // Sort in memory by createdAt descending
          words.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return words;
        });
  }

  // Search words for a specific user
  Future<List<VocabWord>> searchWords(String userId, String query) async {
    try {
      // Note: This is a basic search. For more advanced search,
      // consider using Algolia or similar service
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('word', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('word', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => VocabWord.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search words: $e');
    }
  }

  // Get random words for practice for a specific user
  Future<List<VocabWord>> getRandomWords(String userId, int count) async {
    try {
      // Get random words (simplified approach)
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .limit(count * 2) // Get more than needed
          .get();

      List<VocabWord> words = snapshot.docs
          .map((doc) => VocabWord.fromFirestore(doc.data(), doc.id))
          .toList();

      // Shuffle and take required count
      words.shuffle();
      return words.take(count).toList();
    } catch (e) {
      throw Exception('Failed to get random words: $e');
    }
  }

  // Get word by ID
  Future<VocabWord?> getWordById(String wordId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(wordId)
          .get();

      if (doc.exists && doc.data() != null) {
        return VocabWord.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get word: $e');
    }
  }

  // Get multiple words by their IDs
  Future<List<VocabWord>> getWordsByIds(List<String> wordIds) async {
    try {
      if (wordIds.isEmpty) return [];

      // Firestore 'in' queries are limited to 10 items, so we need to batch
      List<VocabWord> allWords = [];
      
      for (int i = 0; i < wordIds.length; i += 10) {
        int end = (i + 10 < wordIds.length) ? i + 10 : wordIds.length;
        List<String> batch = wordIds.sublist(i, end);
        
        QuerySnapshot snapshot = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        List<VocabWord> batchWords = snapshot.docs
            .map((doc) => VocabWord.fromFirestore(doc.data(), doc.id))
            .toList();
        
        allWords.addAll(batchWords);
      }
      
      return allWords;
    } catch (e) {
      throw Exception('Failed to get words by IDs: $e');
    }
  }

  // Add new word (admin function)
  Future<String> addWord(VocabWord word) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(word.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add word: $e');
    }
  }

  // Update word (admin function)
  Future<void> updateWord(VocabWord word) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(word.id)
          .update(word.toFirestore());
    } catch (e) {
      throw Exception('Failed to update word: $e');
    }
  }

  // Delete word (admin function)
  Future<void> deleteWord(String wordId) async {
    try {
      await _firestore.collection(_collection).doc(wordId).delete();
    } catch (e) {
      throw Exception('Failed to delete word: $e');
    }
  }

  // Get words by part of speech
  Stream<List<VocabWord>> getWordsByPartOfSpeech(String partOfSpeech) {
    return _firestore
        .collection(_collection)
        .where('partOfSpeech', isEqualTo: partOfSpeech)
        .orderBy('word')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VocabWord.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Batch add words (admin function)
  Future<void> batchAddWords(List<VocabWord> words) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (VocabWord word in words) {
        DocumentReference docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, word.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch add words: $e');
    }
  }
}
