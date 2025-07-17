import 'package:flutter/foundation.dart';

class AIService {
  // You can use different AI services here
  // For demonstration, I'll show how to integrate with OpenAI or a similar service
  // Replace with your preferred AI service API

  // Alternative: Use a free AI service or local model
  // For now, I'll create a mock implementation that generates realistic examples

  /// Generates example sentences for a given word and its definition
  static Future<List<String>> generateExampleSentences({
    required String word,
    required String definition,
    String? partOfSpeech,
    int count = 3,
  }) async {
    try {
      // For now, using a mock implementation
      // In production, you would call an actual AI service
      return await _generateMockExamples(word, definition, partOfSpeech, count);

      // Uncomment below to use OpenAI API (requires API key)
      // return await _generateWithOpenAI(word, definition, partOfSpeech, count);
    } catch (e) {
      debugPrint('Error generating examples: $e');
      return _getFallbackExamples(word, partOfSpeech);
    }
  }

  /// Mock implementation that generates realistic example sentences
  static Future<List<String>> _generateMockExamples(
    String word,
    String definition,
    String? partOfSpeech,
    int count,
  ) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final examples = <String>[];
    final lowerWord = word.toLowerCase();
    final capitalWord = word[0].toUpperCase() + word.substring(1).toLowerCase();

    // Generate contextual examples based on part of speech and definition keywords
    switch (partOfSpeech?.toLowerCase()) {
      case 'adjective':
        if (definition.toLowerCase().contains('good') ||
            definition.toLowerCase().contains('positive') ||
            definition.toLowerCase().contains('excellent')) {
          examples.addAll([
            'The ${lowerWord} performance exceeded all expectations.',
            'She has a ${lowerWord} attitude that inspires others.',
            'His ${lowerWord} work ethic is truly admirable.',
            'The team delivered ${lowerWord} results this quarter.',
            'We need more ${lowerWord} solutions like this one.',
          ]);
        } else if (definition.toLowerCase().contains('large') ||
            definition.toLowerCase().contains('big') ||
            definition.toLowerCase().contains('abundant')) {
          examples.addAll([
            'The company has ${lowerWord} resources at its disposal.',
            'There was ${lowerWord} evidence supporting the theory.',
            'The ${lowerWord} crowd gathered in the square.',
            'She received ${lowerWord} support from her colleagues.',
            'The harvest was ${lowerWord} this year.',
          ]);
        } else if (definition.toLowerCase().contains('kind') ||
            definition.toLowerCase().contains('generous') ||
            definition.toLowerCase().contains('caring')) {
          examples.addAll([
            'The ${lowerWord} stranger helped her find her way.',
            'His ${lowerWord} gesture touched everyone\'s hearts.',
            'She is known for her ${lowerWord} nature.',
            'The ${lowerWord} donation made a huge difference.',
            'Their ${lowerWord} hospitality was overwhelming.',
          ]);
        } else {
          examples.addAll([
            'The ${lowerWord} approach proved to be very effective.',
            'She has a ${lowerWord} personality that everyone admires.',
            'His ${lowerWord} behavior impressed the entire team.',
            'The results were more ${lowerWord} than expected.',
            'We need a ${lowerWord} solution to this problem.',
          ]);
        }
        break;

      case 'noun':
        if (definition.toLowerCase().contains('person') ||
            definition.toLowerCase().contains('people')) {
          examples.addAll([
            'The ${lowerWord} arrived early for the meeting.',
            'She is a respected ${lowerWord} in her field.',
            'Every ${lowerWord} deserves equal opportunities.',
            'The ${lowerWord} shared valuable insights.',
            'He consulted with the ${lowerWord} before deciding.',
          ]);
        } else if (definition.toLowerCase().contains('feeling') ||
            definition.toLowerCase().contains('emotion')) {
          examples.addAll([
            'A sense of ${lowerWord} filled the room.',
            'She couldn\'t hide her ${lowerWord} any longer.',
            'His ${lowerWord} was evident in his voice.',
            'The ${lowerWord} overwhelmed her completely.',
            'They expressed their ${lowerWord} openly.',
          ]);
        } else {
          examples.addAll([
            'The ${lowerWord} was clearly visible from here.',
            'She showed great ${lowerWord} in her work.',
            'His ${lowerWord} made a significant difference.',
            'The ${lowerWord} of this situation is remarkable.',
            'We discussed the ${lowerWord} in detail.',
          ]);
        }
        break;

      case 'verb':
        if (definition.toLowerCase().contains('make') ||
            definition.toLowerCase().contains('create') ||
            definition.toLowerCase().contains('build')) {
          examples.addAll([
            'They will ${lowerWord} a new strategy for next year.',
            'She ${lowerWord}s beautiful art from recycled materials.',
            'The team ${lowerWord}ed an innovative solution.',
            'We should ${lowerWord} better relationships with clients.',
            'He ${lowerWord}s opportunities wherever he goes.',
          ]);
        } else if (definition.toLowerCase().contains('move') ||
            definition.toLowerCase().contains('go') ||
            definition.toLowerCase().contains('travel')) {
          examples.addAll([
            'They will ${lowerWord} to the new location tomorrow.',
            'She ${lowerWord}s gracefully across the stage.',
            'The convoy ${lowerWord}ed through the mountain pass.',
            'We must ${lowerWord} quickly to avoid delays.',
            'He ${lowerWord}s between cities for work.',
          ]);
        } else {
          examples.addAll([
            'They ${lowerWord} the project successfully.',
            'She will ${lowerWord} the task tomorrow.',
            'He decided to ${lowerWord} a new approach.',
            'We should ${lowerWord} this opportunity.',
            'The team ${lowerWord}s every challenge.',
          ]);
        }
        break;

      case 'adverb':
        examples.addAll([
          'She ${lowerWord} completed the assignment.',
          'He spoke ${lowerWord} to the audience.',
          'They ${lowerWord} resolved the conflict.',
          'The plan was ${lowerWord} executed.',
          'She ${lowerWord} explained the concept.',
        ]);
        break;

      default:
        examples.addAll([
          '${capitalWord} is an important concept to understand.',
          'The meaning of "${lowerWord}" became clear through context.',
          'She used "${lowerWord}" correctly in her essay.',
          'Students should practice using "${lowerWord}" in sentences.',
          'Understanding "${lowerWord}" helps improve vocabulary.',
        ]);
    }

    // Shuffle and return requested count
    examples.shuffle();
    return examples.take(count).toList();
  }

  /// Fallback examples when AI service fails
  static List<String> _getFallbackExamples(String word, String? partOfSpeech) {
    return [
      'The word "$word" is used in many contexts.',
      'Understanding "$word" helps improve communication.',
      'She used "$word" effectively in her presentation.',
    ];
  }

  /// Validates and improves existing example sentences
  static Future<List<String>> improveExampleSentences({
    required String word,
    required List<String> existingExamples,
    required String definition,
  }) async {
    try {
      // Mock implementation for improving examples
      await Future.delayed(const Duration(milliseconds: 300));

      final improved = <String>[];
      for (final example in existingExamples) {
        if (example.toLowerCase().contains(word.toLowerCase())) {
          improved.add(example);
        } else {
          // Try to improve the example by incorporating the word better
          improved.add(
            example.replaceFirst('.', ', which shows the word "$word".'),
          );
        }
      }

      return improved;
    } catch (e) {
      debugPrint('Error improving examples: $e');
      return existingExamples;
    }
  }

  /// Generates context-aware synonyms
  static Future<List<String>> generateSynonyms({
    required String word,
    required String definition,
    String? partOfSpeech,
    int count = 5,
  }) async {
    try {
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));

      final synonyms = <String>[];
      final lowerDef = definition.toLowerCase();

      // Generate synonyms based on definition keywords and part of speech
      switch (partOfSpeech?.toLowerCase()) {
        case 'adjective':
          if (lowerDef.contains('good') ||
              lowerDef.contains('positive') ||
              lowerDef.contains('excellent') ||
              lowerDef.contains('great')) {
            synonyms.addAll([
              'excellent',
              'outstanding',
              'remarkable',
              'impressive',
              'superb',
              'wonderful',
              'fantastic',
              'exceptional',
            ]);
          } else if (lowerDef.contains('bad') ||
              lowerDef.contains('negative') ||
              lowerDef.contains('poor') ||
              lowerDef.contains('awful')) {
            synonyms.addAll([
              'poor',
              'terrible',
              'awful',
              'dreadful',
              'horrible',
              'inadequate',
              'unsatisfactory',
              'disappointing',
            ]);
          } else if (lowerDef.contains('big') ||
              lowerDef.contains('large') ||
              lowerDef.contains('huge') ||
              lowerDef.contains('abundant')) {
            synonyms.addAll([
              'enormous',
              'massive',
              'huge',
              'gigantic',
              'substantial',
              'vast',
              'immense',
              'colossal',
            ]);
          } else if (lowerDef.contains('small') ||
              lowerDef.contains('little') ||
              lowerDef.contains('tiny')) {
            synonyms.addAll([
              'tiny',
              'minute',
              'minuscule',
              'petite',
              'compact',
              'diminutive',
              'microscopic',
            ]);
          } else if (lowerDef.contains('fast') ||
              lowerDef.contains('quick') ||
              lowerDef.contains('speed')) {
            synonyms.addAll([
              'rapid',
              'swift',
              'speedy',
              'hasty',
              'brisk',
              'prompt',
              'expeditious',
            ]);
          } else if (lowerDef.contains('beautiful') ||
              lowerDef.contains('attractive') ||
              lowerDef.contains('pretty')) {
            synonyms.addAll([
              'gorgeous',
              'stunning',
              'lovely',
              'attractive',
              'elegant',
              'graceful',
              'charming',
            ]);
          } else if (lowerDef.contains('smart') ||
              lowerDef.contains('intelligent') ||
              lowerDef.contains('clever')) {
            synonyms.addAll([
              'intelligent',
              'brilliant',
              'clever',
              'wise',
              'bright',
              'sharp',
              'astute',
            ]);
          } else if (lowerDef.contains('happy') ||
              lowerDef.contains('joy') ||
              lowerDef.contains('glad')) {
            synonyms.addAll([
              'joyful',
              'cheerful',
              'delighted',
              'pleased',
              'content',
              'elated',
              'ecstatic',
            ]);
          } else {
            synonyms.addAll([
              'similar',
              'comparable',
              'equivalent',
              'related',
              'corresponding',
            ]);
          }
          break;

        case 'verb':
          if (lowerDef.contains('make') ||
              lowerDef.contains('create') ||
              lowerDef.contains('build') ||
              lowerDef.contains('construct')) {
            synonyms.addAll([
              'construct',
              'build',
              'form',
              'develop',
              'establish',
              'fabricate',
              'manufacture',
              'assemble',
            ]);
          } else if (lowerDef.contains('help') ||
              lowerDef.contains('assist') ||
              lowerDef.contains('support')) {
            synonyms.addAll([
              'aid',
              'support',
              'facilitate',
              'enable',
              'contribute',
              'cooperate',
              'collaborate',
            ]);
          } else if (lowerDef.contains('say') ||
              lowerDef.contains('speak') ||
              lowerDef.contains('tell') ||
              lowerDef.contains('talk')) {
            synonyms.addAll([
              'express',
              'communicate',
              'articulate',
              'declare',
              'announce',
              'state',
              'mention',
            ]);
          } else if (lowerDef.contains('move') ||
              lowerDef.contains('go') ||
              lowerDef.contains('travel')) {
            synonyms.addAll([
              'travel',
              'journey',
              'proceed',
              'advance',
              'migrate',
              'relocate',
              'transport',
            ]);
          } else if (lowerDef.contains('think') ||
              lowerDef.contains('consider') ||
              lowerDef.contains('ponder')) {
            synonyms.addAll([
              'consider',
              'contemplate',
              'reflect',
              'ponder',
              'deliberate',
              'meditate',
              'analyze',
            ]);
          } else {
            synonyms.addAll([
              'perform',
              'execute',
              'accomplish',
              'achieve',
              'complete',
            ]);
          }
          break;

        case 'noun':
          if (lowerDef.contains('person') ||
              lowerDef.contains('people') ||
              lowerDef.contains('individual')) {
            synonyms.addAll([
              'individual',
              'being',
              'character',
              'figure',
              'personality',
              'citizen',
              'human',
            ]);
          } else if (lowerDef.contains('place') ||
              lowerDef.contains('location') ||
              lowerDef.contains('area')) {
            synonyms.addAll([
              'location',
              'site',
              'spot',
              'area',
              'region',
              'zone',
              'territory',
            ]);
          } else if (lowerDef.contains('thing') ||
              lowerDef.contains('object') ||
              lowerDef.contains('item')) {
            synonyms.addAll([
              'object',
              'item',
              'article',
              'element',
              'component',
              'entity',
              'substance',
            ]);
          } else if (lowerDef.contains('idea') ||
              lowerDef.contains('concept') ||
              lowerDef.contains('thought')) {
            synonyms.addAll([
              'concept',
              'notion',
              'thought',
              'principle',
              'theory',
              'belief',
              'philosophy',
            ]);
          } else {
            synonyms.addAll([
              'element',
              'aspect',
              'feature',
              'component',
              'factor',
            ]);
          }
          break;

        case 'adverb':
          if (lowerDef.contains('quickly') ||
              lowerDef.contains('fast') ||
              lowerDef.contains('rapidly')) {
            synonyms.addAll([
              'rapidly',
              'swiftly',
              'speedily',
              'hastily',
              'promptly',
              'briskly',
            ]);
          } else if (lowerDef.contains('slowly') ||
              lowerDef.contains('gradually')) {
            synonyms.addAll([
              'gradually',
              'steadily',
              'deliberately',
              'carefully',
              'gently',
            ]);
          } else {
            synonyms.addAll([
              'similarly',
              'likewise',
              'correspondingly',
              'equally',
              'comparably',
            ]);
          }
          break;

        default:
          synonyms.addAll([
            'similar',
            'related',
            'comparable',
            'equivalent',
            'corresponding',
            'analogous',
            'parallel',
          ]);
      }

      // Remove duplicates and shuffle
      final uniqueSynonyms = synonyms.toSet().toList();
      uniqueSynonyms.shuffle();
      return uniqueSynonyms.take(count).toList();
    } catch (e) {
      debugPrint('Error generating synonyms: $e');
      return ['similar', 'related', 'comparable'];
    }
  }

  /// Comprehensive word analysis - generates definition, examples, synonyms, and more
  static Future<WordAnalysis> analyzeWord({
    required String word,
    String? partOfSpeech,
  }) async {
    try {
      // Simulate API delay for realistic experience
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate definition based on word patterns and common knowledge
      final definition = _generateDefinition(word, partOfSpeech);

      // Generate examples using the definition
      final examples = await _generateMockExamples(
        word,
        definition,
        partOfSpeech,
        3,
      );

      // Generate synonyms
      final synonyms = await generateSynonyms(
        word: word,
        definition: definition,
        partOfSpeech: partOfSpeech,
        count: 5,
      );

      // Generate pronunciation
      final pronunciation = _generatePronunciation(word);

      // Determine difficulty
      final difficulty = _determineDifficulty(word, definition);

      return WordAnalysis(
        word: word,
        definition: definition,
        pronunciation: pronunciation,
        examples: examples,
        synonyms: synonyms,
        partOfSpeech: partOfSpeech ?? _detectPartOfSpeech(word),
        difficulty: difficulty,
      );
    } catch (e) {
      debugPrint('Error analyzing word: $e');
      return WordAnalysis.fallback(word, partOfSpeech);
    }
  }

  /// Generate definition based on word patterns and common knowledge
  static String _generateDefinition(String word, String? partOfSpeech) {
    final lowerWord = word.toLowerCase();

    // Common word patterns and their typical definitions
    if (lowerWord.endsWith('able') || lowerWord.endsWith('ible')) {
      return 'Capable of being ${lowerWord.replaceAll(RegExp(r'(able|ible)$'), '')}ed or having the quality of being ${lowerWord.replaceAll(RegExp(r'(able|ible)$'), '')}';
    } else if (lowerWord.endsWith('ful')) {
      return 'Full of or characterized by ${lowerWord.replaceAll('ful', '')}';
    } else if (lowerWord.endsWith('less')) {
      return 'Without or lacking ${lowerWord.replaceAll('less', '')}';
    } else if (lowerWord.endsWith('ness')) {
      return 'The quality or state of being ${lowerWord.replaceAll('ness', '')}';
    } else if (lowerWord.endsWith('tion') || lowerWord.endsWith('sion')) {
      return 'The act or process of ${lowerWord.replaceAll(RegExp(r'(tion|sion)$'), '')}ing';
    } else if (lowerWord.endsWith('ly') &&
        partOfSpeech?.toLowerCase() == 'adverb') {
      return 'In a ${lowerWord.replaceAll('ly', '')} manner';
    } else if (lowerWord.endsWith('er') || lowerWord.endsWith('or')) {
      return 'A person who ${lowerWord.replaceAll(RegExp(r'(er|or)$'), '')}s';
    } else if (lowerWord.endsWith('ing') &&
        partOfSpeech?.toLowerCase() == 'verb') {
      return 'The action of ${lowerWord.replaceAll('ing', '')}';
    }

    // Common words definitions
    final commonWords = {
      'abandon': 'To give up completely or leave behind',
      'brilliant': 'Extremely intelligent, talented, or impressive',
      'curious': 'Eager to learn or know something',
      'delicate': 'Fragile, requiring careful handling',
      'elaborate': 'Detailed and complicated in design',
      'fantastic': 'Extraordinarily good or attractive',
      'generous': 'Showing kindness and liberality',
      'humble': 'Having a modest opinion of oneself',
      'innovative': 'Featuring new methods; advanced and original',
      'magnificent': 'Extremely beautiful, elaborate, or impressive',
      'opportunity': 'A chance for progress or advancement',
      'perseverance': 'Persistence in doing something despite difficulty',
      'remarkable': 'Worthy of attention; striking',
      'tremendous': 'Very great in amount, scale, or intensity',
      'understand': 'To comprehend the meaning or importance of something',
      'vocabulary': 'The body of words used in a particular language',
      'wonderful': 'Inspiring delight, pleasure, or admiration',
    };

    if (commonWords.containsKey(lowerWord)) {
      return commonWords[lowerWord]!;
    }

    // Fallback based on part of speech
    switch (partOfSpeech?.toLowerCase()) {
      case 'adjective':
        return 'A descriptive word that modifies or describes a noun';
      case 'noun':
        return 'A person, place, thing, or concept';
      case 'verb':
        return 'An action word that describes what someone or something does';
      case 'adverb':
        return 'A word that modifies a verb, adjective, or other adverb';
      default:
        return 'A word in the English language with specific meaning and usage';
    }
  }

  /// Generate pronunciation guide
  static String _generatePronunciation(String word) {
    // This is a simplified pronunciation generator
    // In a real app, you'd use a pronunciation API or dictionary
    final lowerWord = word.toLowerCase();

    // Common pronunciation patterns
    final pronunciations = {
      'abandon': '/əˈbændən/',
      'brilliant': '/ˈbrɪljənt/',
      'curious': '/ˈkjʊriəs/',
      'delicate': '/ˈdelɪkət/',
      'elaborate': '/ɪˈlæbərət/',
      'fantastic': '/fænˈtæstɪk/',
      'generous': '/ˈdʒenərəs/',
      'humble': '/ˈhʌmbəl/',
      'innovative': '/ˈɪnəveɪtɪv/',
      'magnificent': '/mægˈnɪfɪsənt/',
      'opportunity': '/ˌɑpərˈtunəti/',
      'perseverance': '/ˌpɜrsəˈvɪrəns/',
      'remarkable': '/rɪˈmɑrkəbəl/',
      'tremendous': '/trɪˈmendəs/',
      'understand': '/ˌʌndərˈstænd/',
      'vocabulary': '/voʊˈkæbjəˌleri/',
      'wonderful': '/ˈwʌndərfəl/',
    };

    if (pronunciations.containsKey(lowerWord)) {
      return pronunciations[lowerWord]!;
    }

    // Simple fallback - create basic pronunciation
    return '/${lowerWord}/';
  }

  /// Detect part of speech based on word patterns
  static String _detectPartOfSpeech(String word) {
    final lowerWord = word.toLowerCase();

    // Common patterns for different parts of speech
    if (lowerWord.endsWith('ly')) return 'adverb';
    if (lowerWord.endsWith('tion') ||
        lowerWord.endsWith('sion') ||
        lowerWord.endsWith('ness') ||
        lowerWord.endsWith('ment'))
      return 'noun';
    if (lowerWord.endsWith('able') ||
        lowerWord.endsWith('ible') ||
        lowerWord.endsWith('ful') ||
        lowerWord.endsWith('less'))
      return 'adjective';
    if (lowerWord.endsWith('ed') || lowerWord.endsWith('ing')) return 'verb';

    // Default fallback
    return 'noun';
  }

  /// Determine difficulty level
  static String _determineDifficulty(String word, String definition) {
    final wordLength = word.length;
    final definitionLength = definition.length;

    // Simple difficulty calculation based on word and definition complexity
    if (wordLength <= 5 && definitionLength <= 50) {
      return 'beginner';
    } else if (wordLength <= 8 && definitionLength <= 100) {
      return 'intermediate';
    } else {
      return 'advanced';
    }
  }

  /// Quick demo method to test AI functionality
  static Future<void> testAIFeatures() async {
    debugPrint('Testing AI Example Generation...');

    // Test adjective examples
    final adjExamples = await generateExampleSentences(
      word: 'brilliant',
      definition: 'extremely intelligent or talented',
      partOfSpeech: 'adjective',
      count: 3,
    );
    debugPrint('Adjective examples for "brilliant": $adjExamples');

    // Test noun examples
    final nounExamples = await generateExampleSentences(
      word: 'opportunity',
      definition: 'a chance for progress or advancement',
      partOfSpeech: 'noun',
      count: 3,
    );
    debugPrint('Noun examples for "opportunity": $nounExamples');

    // Test verb examples
    final verbExamples = await generateExampleSentences(
      word: 'accomplish',
      definition: 'to complete or achieve something successfully',
      partOfSpeech: 'verb',
      count: 3,
    );
    debugPrint('Verb examples for "accomplish": $verbExamples');

    // Test synonym generation
    final synonyms = await generateSynonyms(
      word: 'brilliant',
      definition: 'extremely intelligent or talented',
      partOfSpeech: 'adjective',
      count: 5,
    );
    debugPrint('Synonyms for "brilliant": $synonyms');

    debugPrint('AI Features test completed!');
  }
}

/// Data class to hold comprehensive word analysis results
class WordAnalysis {
  final String word;
  final String definition;
  final String pronunciation;
  final List<String> examples;
  final List<String> synonyms;
  final String partOfSpeech;
  final String difficulty;

  WordAnalysis({
    required this.word,
    required this.definition,
    required this.pronunciation,
    required this.examples,
    required this.synonyms,
    required this.partOfSpeech,
    required this.difficulty,
  });

  /// Create a fallback WordAnalysis when AI analysis fails
  factory WordAnalysis.fallback(String word, String? partOfSpeech) {
    return WordAnalysis(
      word: word,
      definition: 'A word in the English language',
      pronunciation: '/${word.toLowerCase()}/',
      examples: [
        'The word "$word" is used in many contexts.',
        'Understanding "$word" helps improve vocabulary.',
        'She used "$word" effectively in her presentation.',
      ],
      synonyms: ['similar', 'related', 'comparable'],
      partOfSpeech: partOfSpeech ?? 'noun',
      difficulty: 'intermediate',
    );
  }
}
