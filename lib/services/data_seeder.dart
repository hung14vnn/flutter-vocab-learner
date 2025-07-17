import 'package:flutter/material.dart';
import '../models/vocab_word.dart';
import '../services/vocab_service.dart';

class VocabDataSeeder {
  static final VocabService _vocabService = VocabService();

  static final List<Map<String, dynamic>> _sampleWords = [
    {
      'word': 'abundant',
      'definition': 'Existing in large quantities; plentiful',
      'pronunciation': '/əˈbʌndənt/',
      'examples': [
        'The region has abundant natural resources.',
        'There was abundant evidence of his guilt.'
      ],
      'difficulty': 'intermediate',
      'synonyms': ['plentiful', 'copious', 'ample'],
      'partOfSpeech': 'adjective',
    },
    {
      'word': 'benevolent',
      'definition': 'Well meaning and kindly',
      'pronunciation': '/bɪˈnevələnt/',
      'examples': [
        'He was a benevolent dictator.',
        'The organization relies on benevolent donations.'
      ],
      'difficulty': 'advanced',
      'synonyms': ['kind', 'generous', 'charitable'],
      'partOfSpeech': 'adjective',
    },
    {
      'word': 'crucial',
      'definition': 'Extremely important; critical',
      'pronunciation': '/ˈkruːʃəl/',
      'examples': [
        'It is crucial that we arrive on time.',
        'This is a crucial moment in the negotiations.'
      ],
      'difficulty': 'intermediate',
      'synonyms': ['critical', 'vital', 'essential'],
      'partOfSpeech': 'adjective',
    },
    {
      'word': 'diligent',
      'definition': 'Having or showing care and conscientiousness in one\'s work or duties',
      'pronunciation': '/ˈdɪlɪdʒənt/',
      'examples': [
        'She was a diligent student.',
        'His diligent efforts paid off.'
      ],
      'difficulty': 'intermediate',
      'synonyms': ['hardworking', 'industrious', 'careful'],
      'partOfSpeech': 'adjective',
    },
    {
      'word': 'eloquent',
      'definition': 'Fluent or persuasive in speaking or writing',
      'pronunciation': '/ˈeləkwənt/',
      'examples': [
        'She gave an eloquent speech.',
        'His eloquent words moved the audience.'
      ],
      'difficulty': 'advanced',
      'synonyms': ['articulate', 'fluent', 'persuasive'],
      'partOfSpeech': 'adjective',
    },
    {
      'word': 'frivolous',
      'definition': 'Not having any serious purpose or value',
      'pronunciation': '/ˈfrɪvələs/',
      'examples': [
        'She considered his comment frivolous.',
        'The court dismissed the frivolous lawsuit.'
      ],
      'difficulty': 'advanced',
      'synonyms': ['trivial', 'superficial', 'silly'],
      'partOfSpeech': 'adjective',
    },
    {
      'word': 'generous',
      'definition': 'Showing kindness and liberality',
      'pronunciation': '/ˈdʒenərəs/',
      'examples': [
        'She was generous with her time.',
        'He made a generous donation to charity.'
      ],
      'difficulty': 'beginner',
      'synonyms': ['kind', 'giving', 'benevolent'],
      'partOfSpeech': 'adjective',
    },
    {
      'word': 'humble',
      'definition': 'Having or showing a modest or low estimate of one\'s importance',
      'pronunciation': '/ˈhʌmbəl/',
      'examples': [
        'Despite his success, he remained humble.',
        'She came from humble beginnings.'
      ],
      'difficulty': 'beginner',
      'synonyms': ['modest', 'unassuming', 'meek'],
      'partOfSpeech': 'adjective',
    },
    {
      'word': 'innovative',
      'definition': 'Featuring new methods; advanced and original',
      'pronunciation': '/ˈɪnəveɪtɪv/',
      'examples': [
        'The company is known for its innovative products.',
        'She has an innovative approach to teaching.'
      ],
      'difficulty': 'intermediate',
      'synonyms': ['creative', 'original', 'inventive'],
      'partOfSpeech': 'adjective',
    },
    {
      'word': 'jubilant',
      'definition': 'Feeling or expressing great happiness and triumph',
      'pronunciation': '/ˈdʒuːbɪlənt/',
      'examples': [
        'The team was jubilant after their victory.',
        'She felt jubilant about her promotion.'
      ],
      'difficulty': 'advanced',
      'synonyms': ['elated', 'ecstatic', 'overjoyed'],
      'partOfSpeech': 'adjective',
    },
  ];

  static Future<void> seedVocabularyData() async {
    try {
      List<VocabWord> words = _sampleWords.map((wordData) {
        DateTime now = DateTime.now();
        return VocabWord(
          id: '', // Will be assigned by Firestore
          word: wordData['word'],
          definition: wordData['definition'],
          pronunciation: wordData['pronunciation'],
          examples: List<String>.from(wordData['examples']),
          difficulty: wordData['difficulty'],
          synonyms: List<String>.from(wordData['synonyms']),
          partOfSpeech: wordData['partOfSpeech'],
          state: WordState.newWordState,
          due: now.add(Duration(days: 7)), // Set due date 7 days from
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

      await _vocabService.batchAddWords(words);
      debugPrint('Successfully seeded ${words.length} vocabulary words');
    } catch (e) {
      debugPrint('Error seeding vocabulary data: $e');
      rethrow;
    }
  }

  static Future<bool> shouldSeedData() async {
    try {
      // Check if we already have words in the database
      List<VocabWord> existingWords = await _vocabService.getRandomWords(1);
      return existingWords.isEmpty;
    } catch (e) {
      debugPrint('Error checking existing data: $e');
      return false;
    }
  }
}
