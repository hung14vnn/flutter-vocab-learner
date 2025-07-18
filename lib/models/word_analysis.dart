class WordAnalysis {
  final String definition;
  final String? definitionInUserLanguage;
  final String pronunciation;
  final List<String> examples;
  final List<String> synonyms;
  final String difficulty;

  const WordAnalysis({
    required this.definition,
    this.definitionInUserLanguage,
    required this.pronunciation,
    required this.examples,
    required this.synonyms,
    required this.difficulty,
  });

  factory WordAnalysis.fromJson(Map<String, dynamic> json) {
    return WordAnalysis(
      definition: json['definition'] ?? '',
      definitionInUserLanguage: json['definitionInUserLanguage'],
      pronunciation: json['pronunciation'] ?? '',
      examples: List<String>.from(json['examples'] ?? []),
      synonyms: List<String>.from(json['synonyms'] ?? []),
      difficulty: json['difficulty'] ?? 'beginner',
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
    };
  }

  @override
  String toString() {
    return 'WordAnalysis{definition: $definition, definitionInUserLanguage: $definitionInUserLanguage, pronunciation: $pronunciation, examples: $examples, synonyms: $synonyms, difficulty: $difficulty}';
  }
}
