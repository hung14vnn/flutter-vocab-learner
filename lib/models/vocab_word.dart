class VocabWord {
  final String id;
  final String word;
  final String definition;
  final String? pronunciation;
  final String? audioUrl;
  final String? imageUrl;
  final List<String> examples;
  final String difficulty; // beginner, intermediate, advanced
  final List<String> synonyms;
  final String partOfSpeech;
  final DateTime createdAt;
  final DateTime updatedAt;

  VocabWord({
    required this.id,
    required this.word,
    required this.definition,
    this.pronunciation,
    this.audioUrl,
    this.imageUrl,
    this.examples = const [],
    required this.difficulty,
    this.synonyms = const [],
    required this.partOfSpeech,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabWord.fromFirestore(Object? data, String id) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return VocabWord(
      id: id,
      word: map['word'] ?? '',
      definition: map['definition'] ?? '',
      pronunciation: map['pronunciation'],
      audioUrl: map['audioUrl'],
      imageUrl: map['imageUrl'],
      examples: List<String>.from(map['examples'] ?? []),
      difficulty: map['difficulty'] ?? 'beginner',
      synonyms: List<String>.from(map['synonyms'] ?? []),
      partOfSpeech: map['partOfSpeech'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'word': word,
      'definition': definition,
      'pronunciation': pronunciation,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'examples': examples,
      'difficulty': difficulty,
      'synonyms': synonyms,
      'partOfSpeech': partOfSpeech,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  VocabWord copyWith({
    String? id,
    String? word,
    String? definition,
    String? pronunciation,
    String? audioUrl,
    String? imageUrl,
    List<String>? examples,
    String? difficulty,
    List<String>? synonyms,
    String? partOfSpeech,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VocabWord(
      id: id ?? this.id,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      pronunciation: pronunciation ?? this.pronunciation,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      examples: examples ?? this.examples,
      difficulty: difficulty ?? this.difficulty,
      synonyms: synonyms ?? this.synonyms,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
