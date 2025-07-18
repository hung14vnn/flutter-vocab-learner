class VocabWord {
  final String id;
  final String userId; // The user who created this word
  final String word;
  final String definition;
  final String? definitionInUserLanguage; // Optional field for definition in user's language
  final String? pronunciation;
  final String? audioUrl;
  final String? imageUrl;
  final List<String> examples;
  final String difficulty; // beginner, intermediate, advanced
  final List<String> synonyms;
  final String partOfSpeech;
  final WordState state; // new, learning, mastered
  final DateTime due;
  final DateTime createdAt;
  final DateTime updatedAt;

  VocabWord({
    required this.id,
    required this.userId,
    required this.word,
    required this.definition,
    this.definitionInUserLanguage,
    this.pronunciation,
    this.audioUrl,
    this.imageUrl,
    this.examples = const [],
    required this.difficulty,
    this.synonyms = const [],
    required this.partOfSpeech,
    this.state = WordState.newWordState,
    required this.due,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabWord.fromFirestore(Object? data, String id) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return VocabWord(
      id: id,
      userId: map['userId'] ?? '',
      word: map['word'] ?? '',
      definition: map['definition'] ?? '',
      definitionInUserLanguage: map['definitionInUserLanguage'],
      pronunciation: map['pronunciation'],
      audioUrl: map['audioUrl'],
      imageUrl: map['imageUrl'],
      examples: List<String>.from(map['examples'] ?? []),
      difficulty: map['difficulty'] ?? 'beginner',
      synonyms: List<String>.from(map['synonyms'] ?? []),
      partOfSpeech: map['partOfSpeech'] ?? '',
      state: WordState.values.firstWhere(
        (state) =>
            state.value == (map['state'] ?? WordState.newWordState.value),
        orElse: () => WordState.newWordState,
      ),
      due: DateTime.fromMillisecondsSinceEpoch(map['due'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'word': word,
      'definition': definition,
      'definitionInUserLanguage': definitionInUserLanguage,
      'pronunciation': pronunciation,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'examples': examples,
      'difficulty': difficulty,
      'synonyms': synonyms,
      'partOfSpeech': partOfSpeech,
      'state': state.value,
      'due': due.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  VocabWord copyWith({
    String? id,
    String? userId,
    String? word,
    String? definition,
    String? definitionInUserLanguage,
    String? pronunciation,
    String? audioUrl,
    String? imageUrl,
    List<String>? examples,
    String? difficulty,
    List<String>? synonyms,
    String? partOfSpeech,
    WordState? state,
    DateTime? due,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VocabWord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      definitionInUserLanguage: definitionInUserLanguage ?? this.definitionInUserLanguage,
      pronunciation: pronunciation ?? this.pronunciation,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      examples: examples ?? this.examples,
      difficulty: difficulty ?? this.difficulty,
      synonyms: synonyms ?? this.synonyms,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      state: state ?? this.state,
      due: due ?? this.due,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WordState {
  static const String newWord = 'new';
  static const String learning = 'learning';
  static const String mastered = 'mastered';

  final String value;

  const WordState._(this.value);

  static const WordState newWordState = WordState._(newWord);
  static const WordState learningState = WordState._(learning);
  static const WordState masteredState = WordState._(mastered);

  static const List<WordState> values = [
    newWordState,
    learningState,
    masteredState,
  ];

  @override
  String toString() => value;
}
