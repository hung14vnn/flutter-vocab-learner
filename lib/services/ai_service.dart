
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_analysis.dart';

class AIService {
  // Note: Set your OpenAI API key as an environment variable OPENAI_API_KEY
  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const openAiModel = 'gpt-3.5-turbo';
  static const String baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// Analyzes a word using OpenAI GPT and returns comprehensive word information
  static Future<WordAnalysis> analyzeWord({
    required String word,
    required String partOfSpeech,
    String? userLanguage,
  }) async {
    try {
      final prompt = _buildWordAnalysisPrompt(word, partOfSpeech, userLanguage);
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiApiKey',
        },
        body: jsonEncode({
          'model': openAiModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful English language assistant specialized in vocabulary analysis. You always respond with valid JSON only.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final content = responseData['choices'][0]['message']['content'];
        
        // Parse the JSON response from GPT
        final analysisJson = jsonDecode(content);
        return WordAnalysis.fromJson(analysisJson);
      } else {
        throw Exception('OpenAI API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Return fallback analysis if AI fails
      return _createFallbackAnalysis(word, partOfSpeech);
    }
  }

  /// Builds a comprehensive prompt for word analysis
  static String _buildWordAnalysisPrompt(String word, String partOfSpeech, String? userLanguage) {
    final definitionInUserLanguageField = userLanguage != null 
        ? '"definitionInUserLanguage": "Definition in $userLanguage (if different from English)",'
        : '"definitionInUserLanguage": null,';

    return '''
Analyze the word "$word" as a $partOfSpeech and provide a comprehensive analysis in JSON format.

Please respond with ONLY valid JSON in the following format:
{
  "definition": "A clear, concise definition of the word",
  "pronunciation": "IPA phonetic transcription (e.g., /wɜːrd/)",
  $definitionInUserLanguageField
  "examples": ["Example sentence 1", "Example sentence 2", "Example sentence 3"],
  "synonyms": ["synonym1", "synonym2", "synonym3"],
  "difficulty": "beginner|intermediate|advanced"
}

Requirements:
- Definition: Clear and educational, suitable for language learners
- Pronunciation: Use proper IPA notation${userLanguage != null ? '\n- DefinitionInUserLanguage: Provide translation in $userLanguage if it helps with understanding' : ''}
- Examples: 3 varied, practical sentences showing different contexts
- Synonyms: 3-5 relevant synonyms if available
- Difficulty: Classify as "beginner" (common, everyday words), "intermediate" (moderately complex), or "advanced" (academic, technical, or rare words)

Focus on making this educational and useful for vocabulary learning.
''';
  }

  /// Creates a fallback analysis when AI fails
  static WordAnalysis _createFallbackAnalysis(String word, String partOfSpeech) {
    return WordAnalysis(
      definition: 'A $partOfSpeech. Please add definition manually.',
      definitionInUserLanguage: null,
      pronunciation: '/$word/',
      examples: ['Please add example sentences manually.'],
      synonyms: [],
      difficulty: 'intermediate',
    );
  }
}