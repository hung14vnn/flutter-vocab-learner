class WordAnalysis {
  final String definition;
  final String? definitionInUserLanguage;
  final String pronunciation;
  final List<String> examples;
  final List<String> synonyms;
  final String difficulty;
  final String partOfSpeech;
  final String? fixedWord;

  const WordAnalysis({
    required this.definition,
    this.definitionInUserLanguage,
    required this.pronunciation,
    required this.examples,
    required this.synonyms,
    required this.difficulty,
    required this.partOfSpeech,
    this.fixedWord,
  });

  factory WordAnalysis.fromJson(Map<String, dynamic> json) {
    return WordAnalysis(
      definition: json['definition'] ?? '',
      definitionInUserLanguage: json['definitionInUserLanguage'],
      pronunciation: json['pronunciation'] ?? '',
      examples: List<String>.from(json['examples'] ?? []),
      synonyms: List<String>.from(json['synonyms'] ?? []),
      difficulty: json['difficulty'] ?? 'beginner',
      partOfSpeech: json['partOfSpeech'] ?? 'noun',
      fixedWord: json['fixedWord'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'definition': definition,
      'definitionInUserLanguage': definitionInUserLanguage,
      'pronunciation': pronunciation,
      'examples': examples,
      'synonyms': synonyms,
      'difficulty': difficulty,
      'partOfSpeech': partOfSpeech,
      'fixedWord': fixedWord,
    };
  }

  @override
  String toString() {
    return 'WordAnalysis{definition: $definition, definitionInUserLanguage: $definitionInUserLanguage, pronunciation: $pronunciation, examples: $examples, synonyms: $synonyms, difficulty: $difficulty, partOfSpeech: $partOfSpeech ${fixedWord != null ? ', fixedWord: $fixedWord' : ''}}';
  }
}
