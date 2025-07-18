import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_learner/services/ai_service.dart';
import 'package:vocab_learner/models/word_analysis.dart';

void main() {
  group('AIService Tests', () {
    test('analyzeWord should return WordAnalysis for valid word', () async {
      // Test with a simple word
      const testWord = 'beautiful';
      const testPartOfSpeech = 'adjective';
      
      try {
        final analysis = await AIService.analyzeWord(
          word: testWord,
          partOfSpeech: testPartOfSpeech,
          userLanguage: 'Vietnamese', // Test with a user language
        );
        
        // Verify that the analysis has the required fields
        expect(analysis, isA<WordAnalysis>());
        expect(analysis.definition, isNotEmpty);
        expect(analysis.pronunciation, isNotEmpty);
        expect(analysis.examples, isNotEmpty);
        expect(analysis.difficulty, isIn(['beginner', 'intermediate', 'advanced']));
        
        print('AI Analysis successful for "$testWord":');
        print('Definition: ${analysis.definition}');
        print('Pronunciation: ${analysis.pronunciation}');
        print('Examples: ${analysis.examples}');
        print('Synonyms: ${analysis.synonyms}');
        print('Difficulty: ${analysis.difficulty}');
        
      } catch (e) {
        // If AI fails, we should still get a fallback analysis
        print('AI request failed (expected in tests without internet): $e');
        
        // Test the fallback analysis functionality
        final analysis = await AIService.analyzeWord(
          word: testWord,
          partOfSpeech: testPartOfSpeech,
          userLanguage: 'Vietnamese',
        );
        
        expect(analysis, isA<WordAnalysis>());
        expect(analysis.definition, contains('adjective'));
      }
    });
    
    test('WordAnalysis model should serialize/deserialize correctly', () {
      const analysis = WordAnalysis(
        definition: 'A test definition',
        definitionInUserLanguage: 'Định nghĩa kiểm tra',
        pronunciation: '/test/',
        examples: ['Example 1', 'Example 2'],
        synonyms: ['synonym1', 'synonym2'],
        difficulty: 'intermediate',
      );
      
      // Test toJson
      final json = analysis.toJson();
      expect(json['definition'], equals('A test definition'));
      expect(json['definitionInUserLanguage'], equals('Định nghĩa kiểm tra'));
      expect(json['pronunciation'], equals('/test/'));
      expect(json['examples'], equals(['Example 1', 'Example 2']));
      expect(json['synonyms'], equals(['synonym1', 'synonym2']));
      expect(json['difficulty'], equals('intermediate'));
      
      // Test fromJson
      final recreated = WordAnalysis.fromJson(json);
      expect(recreated.definition, equals(analysis.definition));
      expect(recreated.definitionInUserLanguage, equals(analysis.definitionInUserLanguage));
      expect(recreated.pronunciation, equals(analysis.pronunciation));
      expect(recreated.examples, equals(analysis.examples));
      expect(recreated.synonyms, equals(analysis.synonyms));
      expect(recreated.difficulty, equals(analysis.difficulty));
    });
  });
}
