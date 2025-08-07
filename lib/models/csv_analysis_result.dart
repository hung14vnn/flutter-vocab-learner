class CSVAnalysisResult {
  final List<CSVWordAnalysis> words;
  final int totalWords;
  final int successfulAnalyses;
  final int failedAnalyses;
  final List<String> errors;

  const CSVAnalysisResult({
    required this.words,
    required this.totalWords,
    required this.successfulAnalyses,
    required this.failedAnalyses,
    this.errors = const [],
  });

  factory CSVAnalysisResult.fromJson(Map<String, dynamic> json) {
    return CSVAnalysisResult(
      words: (json['words'] as List<dynamic>)
          .map((wordJson) => CSVWordAnalysis.fromJson(wordJson))
          .toList(),
      totalWords: json['totalWords'] ?? 0,
      successfulAnalyses: json['successfulAnalyses'] ?? 0,
      failedAnalyses: json['failedAnalyses'] ?? 0,
      errors: List<String>.from(json['errors'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'words': words.map((word) => word.toJson()).toList(),
      'totalWords': totalWords,
      'successfulAnalyses': successfulAnalyses,
      'failedAnalyses': failedAnalyses,
      'errors': errors,
    };
  }

  /// Converts to CSV format with all properties filled
  String toCsv() {
    final csvLines = <String>[];
    
    // Header
    csvLines.add('Original Word,Translation,Definition,Pronunciation,Examples,Synonyms,Difficulty,Part of Speech,Fixed Word');
    
    // Data rows
    for (final word in words) {
      final row = [
        _escapeCsvField(word.originalWord),
        _escapeCsvField(word.translation),
        _escapeCsvField(word.definition),
        _escapeCsvField(word.pronunciation),
        _escapeCsvField(word.examples.join('; ')),
        _escapeCsvField(word.synonyms.join('; ')),
        _escapeCsvField(word.difficulty),
        _escapeCsvField(word.partOfSpeech),
        _escapeCsvField(word.fixedWord ?? ''),
      ];
      csvLines.add(row.join(','));
    }
    
    return csvLines.join('\n');
  }

  String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}

class CSVWordAnalysis {
  final String originalWord;
  final String translation;
  final String definition;
  final String pronunciation;
  final List<String> examples;
  final List<String> synonyms;
  final String difficulty;
  final String partOfSpeech;
  final String? fixedWord;
  final bool isAnalysisSuccessful;

  const CSVWordAnalysis({
    required this.originalWord,
    required this.translation,
    required this.definition,
    required this.pronunciation,
    required this.examples,
    required this.synonyms,
    required this.difficulty,
    required this.partOfSpeech,
    this.fixedWord,
    this.isAnalysisSuccessful = true,
  });

  factory CSVWordAnalysis.fromJson(Map<String, dynamic> json) {
    return CSVWordAnalysis(
      originalWord: json['originalWord'] ?? '',
      translation: json['translation'] ?? '',
      definition: json['definition'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      examples: List<String>.from(json['examples'] ?? []),
      synonyms: List<String>.from(json['synonyms'] ?? []),
      difficulty: json['difficulty'] ?? 'beginner',
      partOfSpeech: json['partOfSpeech'] ?? 'noun',
      fixedWord: json['fixedWord'],
      isAnalysisSuccessful: json['isAnalysisSuccessful'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalWord': originalWord,
      'translation': translation,
      'definition': definition,
      'pronunciation': pronunciation,
      'examples': examples,
      'synonyms': synonyms,
      'difficulty': difficulty,
      'partOfSpeech': partOfSpeech,
      'fixedWord': fixedWord,
      'isAnalysisSuccessful': isAnalysisSuccessful,
    };
  }

  /// Creates a failed analysis entry
  factory CSVWordAnalysis.failed({
    required String originalWord,
    required String translation,
    required String errorMessage,
  }) {
    return CSVWordAnalysis(
      originalWord: originalWord,
      translation: translation,
      definition: 'Analysis failed: $errorMessage',
      pronunciation: '',
      examples: [],
      synonyms: [],
      difficulty: 'beginner',
      partOfSpeech: 'unknown',
      isAnalysisSuccessful: false,
    );
  }
}
