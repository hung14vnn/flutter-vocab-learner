class VocabWord {
  final String id;
  final String word;
  final String definition;
  final String? definitionInUserLanguage; // Optional field for definition in user's language
  final String? pronunciation;
  final String? audioUrl;
  final String? imageUrl;
  final List<String> examples;
  final String difficulty; // beginner, intermediate, advanced
  final List<String> synonyms;
  final List<String> antonyms; // New field for antonyms
  final List<String> tags; // New field for tags
  final String partOfSpeech;
  final WordState state; // new, learning, mastered
  final int repetitionLevel; // Level of repetition for spaced repetition
  final DateTime due;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? deckId; // Optional deck ID for organizing words into decks

  VocabWord({
    required this.id,
    required this.word,
    required this.definition,
    this.definitionInUserLanguage,
    this.pronunciation,
    this.audioUrl,
    this.imageUrl,
    this.examples = const [],
    required this.difficulty,
    this.synonyms = const [],
    this.antonyms = const [], // Initialize with an empty list
    this.tags = const [], // Initialize with an empty list
    required this.partOfSpeech,
    this.state = WordState.newWordState,
    required this.repetitionLevel,
    required this.due,
    required this.createdAt,
    required this.updatedAt,
    this.deckId, // Optional deck ID
  });

  factory VocabWord.fromFirestore(Object? data, String id) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return VocabWord(
      id: id,
      word: map['word'] ?? '',
      definition: map['definition'] ?? '',
      definitionInUserLanguage: map['definitionInUserLanguage'],
      pronunciation: map['pronunciation'],
      audioUrl: map['audioUrl'],
      imageUrl: map['imageUrl'],
      examples: List<String>.from(map['examples'] ?? []),
      difficulty: map['difficulty'] ?? 'beginner',
      synonyms: List<String>.from(map['synonyms'] ?? []),
      antonyms: List<String>.from(map['antonyms'] ?? []), // Handle antonyms
      tags: List<String>.from(map['tags'] ?? []), // Handle tags
      partOfSpeech: map['partOfSpeech'] ?? '',
      state: WordState.values.firstWhere(
        (state) =>
            state.value == (map['state'] ?? WordState.newWordState.value),
        orElse: () => WordState.newWordState,
      ),
      repetitionLevel: map['repetitionLevel'] ?? 0,
      due: DateTime.fromMillisecondsSinceEpoch(map['due'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      deckId: map['deckId'], // Handle deckId
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'word': word,
      'definition': definition,
      'definitionInUserLanguage': definitionInUserLanguage,
      'pronunciation': pronunciation,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'examples': examples,
      'difficulty': difficulty,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'tags': tags,
      'partOfSpeech': partOfSpeech,
      'state': state.value,
      'repetitionLevel': repetitionLevel,
      'due': due.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'deckId': deckId, // Include deckId
    };
  }

  VocabWord copyWith({
    String? id,
    String? word,
    String? definition,
    String? definitionInUserLanguage,
    String? pronunciation,
    String? audioUrl,
    String? imageUrl,
    List<String>? examples,
    String? difficulty,
    List<String>? synonyms,
    List<String>? antonyms,
    List<String>? tags,
    String? partOfSpeech,
    WordState? state,
    int? repetitionLevel,
    DateTime? due,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deckId,
  }) {
    return VocabWord(
      id: id ?? this.id,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      definitionInUserLanguage: definitionInUserLanguage ?? this.definitionInUserLanguage,
      pronunciation: pronunciation ?? this.pronunciation,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      examples: examples ?? this.examples,
      difficulty: difficulty ?? this.difficulty,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      tags: tags ?? this.tags,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      state: state ?? this.state,
      repetitionLevel: repetitionLevel ?? this.repetitionLevel,
      due: due ?? this.due,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deckId: deckId ?? this.deckId,
    );
  }
}

class WordState {
  static const String newWord = 'new';
  static const String learning = 'learning';
  static const String reviewed = 'reviewed';
  static const String mastered = 'mastered';

  final String value;

  const WordState._(this.value);

  static const WordState newWordState = WordState._(newWord);
  static const WordState learningState = WordState._(learning);
  static const WordState reviewedState = WordState._(reviewed);
  static const WordState masteredState = WordState._(mastered);

  static const List<WordState> values = [
    newWordState,
    learningState,
    reviewedState,
    masteredState,
  ];

  @override
  String toString() => value;
}
