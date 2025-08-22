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

  // Get paginated vocabulary words for a specific user
  Future<({List<VocabWord> words, List<DocumentSnapshot> docs})> getWordsPaginated(
    String userId, {
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot snapshot = await query.get();
      List<VocabWord> words = snapshot.docs
          .map((doc) => VocabWord.fromFirestore(doc.data(), doc.id))
          .toList();
      
      return (words: words, docs: snapshot.docs);
    } catch (e) {
      throw Exception('Failed to get paginated words: $e');
    }
  }

  // Get paginated words with filters
  Future<({List<VocabWord> words, List<DocumentSnapshot> docs})> getWordsFilteredPaginated(
    String userId, {
    String? difficulty,
    String? partOfSpeech,
    String? searchQuery,
    String? deckId,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId);

      // Add filters
      if (difficulty != null && difficulty != 'all') {
        query = query.where('difficulty', isEqualTo: difficulty);
      }
      if (partOfSpeech != null && partOfSpeech != 'all') {
        query = query.where('partOfSpeech', isEqualTo: partOfSpeech);
      }
      if (deckId != null && deckId.isNotEmpty) {
        query = query.where('deckId', isEqualTo: deckId);
      }

      // Order and limit
      query = query.orderBy('createdAt', descending: true).limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot snapshot = await query.get();
      List<VocabWord> words = snapshot.docs
          .map((doc) => VocabWord.fromFirestore(doc.data(), doc.id))
          .toList();

      // Apply search filter in memory (since Firestore text search is limited)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        words = words.where((word) {
          return word.word.toLowerCase().contains(searchQuery.toLowerCase()) ||
              word.definition.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }

      return (words: words, docs: snapshot.docs);
    } catch (e) {
      throw Exception('Failed to get filtered paginated words: $e');
    }
  }

  // Get words by page number
  Future<({List<VocabWord> words, int totalCount})> getWordsByPage(
    String userId, {
    String? difficulty,
    String? partOfSpeech,
    String? searchQuery,
    String? deckId,
    int page = 1,
    int itemsPerPage = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId);

      // Add filters
      if (difficulty != null && difficulty != 'all') {
        query = query.where('difficulty', isEqualTo: difficulty);
      }
      if (partOfSpeech != null && partOfSpeech != 'all') {
        query = query.where('partOfSpeech', isEqualTo: partOfSpeech);
      }
      if (deckId != null && deckId.isNotEmpty) {
        query = query.where('deckId', isEqualTo: deckId);
      }

      // Get total count first for filters
      int totalCount = 0;
      if (searchQuery == null || searchQuery.isEmpty) {
        // Can count directly if no search query
        AggregateQuerySnapshot countSnapshot = await query.count().get();
        totalCount = countSnapshot.count ?? 0;
      } else {
        // Need to fetch all and filter for search queries
        QuerySnapshot allSnapshot = await query.get();
        List<VocabWord> allWords = allSnapshot.docs
            .map((doc) => VocabWord.fromFirestore(doc.data(), doc.id))
            .toList();
        
        allWords = allWords.where((word) {
          return word.word.toLowerCase().contains(searchQuery.toLowerCase()) ||
              word.definition.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
        
        totalCount = allWords.length;
      }

      // Get paginated results
      Query paginatedQuery = query
          .orderBy('createdAt', descending: true)
          .limit(itemsPerPage);

      // Get the document to start after
      if (page > 1) {
        QuerySnapshot previousPage = await query
            .orderBy('createdAt', descending: true)
            .limit((page - 1) * itemsPerPage)
            .get();
        
        if (previousPage.docs.isNotEmpty) {
          DocumentSnapshot lastDoc = previousPage.docs.last;
          paginatedQuery = paginatedQuery.startAfter([lastDoc.data()]);
        }
      }

      QuerySnapshot snapshot = await paginatedQuery.get();
      List<VocabWord> words = snapshot.docs
          .map((doc) => VocabWord.fromFirestore(doc.data(), doc.id))
          .toList();

      // Apply search filter in memory if needed
      if (searchQuery != null && searchQuery.isNotEmpty) {
        words = words.where((word) {
          return word.word.toLowerCase().contains(searchQuery.toLowerCase()) ||
              word.definition.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }

      return (words: words, totalCount: totalCount);
    } catch (e) {
      throw Exception('Failed to get words by page: $e');
    }
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

  // Batch delete words (admin function)
  Future<void> batchDeleteWords(List<String> wordIds) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (String wordId in wordIds) {
        DocumentReference docRef = _firestore.collection(_collection).doc(wordId);
        batch.delete(docRef);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch delete words: $e');
    }
  }
}
