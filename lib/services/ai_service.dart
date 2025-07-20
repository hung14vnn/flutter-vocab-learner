import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_analysis.dart';

class AIService {
  // Note: Set your Gemini API key here or as an environment variable GEMINI_API_KEY
  static const String _envApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String _hardcodedApiKey =
      'AIzaSyCGuV2XEi5KKzNNuGT8A5zrYn8lMmxCucY'; // Set your Gemini API key here for development

  static String get geminiApiKey {
    if (_envApiKey.isNotEmpty) {
      return _envApiKey;
    }
    if (_hardcodedApiKey.isNotEmpty &&
        _hardcodedApiKey != 'YOUR_GEMINI_API_KEY_HERE') {
      return _hardcodedApiKey;
    }
    throw Exception(
      'Gemini API key not found. Please set GEMINI_API_KEY environment variable or update _hardcodedApiKey in ai_service.dart',
    );
  }

  static const geminiModel = 'gemini-1.5-flash';
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Analyzes a word using Gemini AI and returns comprehensive word information
  static Future<WordAnalysis> analyzeWord({
    required String word,
    required String partOfSpeech,
    String? userLanguage,
  }) async {
    try {
      // Validate API key is available
      final apiKey = geminiApiKey; // This will throw if no API key is found

      final prompt = _buildWordAnalysisPrompt(word, partOfSpeech, userLanguage);
      final response = await http.post(
        Uri.parse('$baseUrl/$geminiModel:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'maxOutputTokens': 500, 'temperature': 0.7},
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        var content =
            responseData['candidates'][0]['content']['parts'][0]['text'];

        // Remove Markdown code block if present
        content = content.trim();
        if (content.startsWith('```json')) {
          content = content.substring(7);
        }
        if (content.startsWith('```')) {
          content = content.substring(3);
        }
        if (content.endsWith('```')) {
          content = content.substring(0, content.length - 3);
        }
        content = content.trim();

        // Parse the JSON response from Gemini
        final analysisJson = jsonDecode(content);
        return WordAnalysis.fromJson(analysisJson);
      } else if (response.statusCode == 401) {
        throw Exception(
          'Gemini API authentication failed. Please check your API key. '
          'Set the GEMINI_API_KEY environment variable or update _hardcodedApiKey in ai_service.dart',
        );
      } else if (response.statusCode == 429) {
        throw Exception(
          'Gemini API quota exceeded. Please check your plan and billing details. '
          'For more information, visit https://ai.google.dev/pricing',
        );
      } else {
        throw Exception(
          'Gemini API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error occurred while analyzing word: $e');

      // If it's an API key issue, rethrow to inform the user
      if (e.toString().contains('API key') ||
          e.toString().contains('authentication')) {
        rethrow;
      }

      // Return fallback analysis for other errors
      return _createFallbackAnalysis(word, partOfSpeech);
    }
  }

  /// Builds a comprehensive prompt for word analysis
  static String _buildWordAnalysisPrompt(
    String word,
    String partOfSpeech,
    String? userLanguage,
  ) {
    final definitionInUserLanguageField = userLanguage != null
        ? '"definitionInUserLanguage": "A brief translation of the word in $userLanguage",'
        : '"definitionInUserLanguage": null,';

    return '''
Analyze the word "$word" as a $partOfSpeech and provide a comprehensive analysis in JSON format.

You are a helpful English language assistant specialized in vocabulary analysis. You always respond with valid JSON only.

IMPORTANT: All values must be in double quotes. Do NOT use unquoted values, code blocks, or markdown. Respond ONLY with valid JSON, no extra text.

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
- Pronunciation: Use proper IPA notation
${userLanguage != null ? 'DefinitionInUserLanguage: Provide a brief translation of the word itself in $userLanguage (not the definition, just the word translation, e.g., "hello" = "xin chào")' : ''}
- Examples: 3 varied, practical sentences showing different contexts
- Synonyms: 3-5 relevant synonyms if available
- Difficulty: Classify as "beginner" (common, everyday words), "intermediate" (moderately complex), or "advanced" (academic, technical, or rare words)

Focus on making this educational and useful for vocabulary learning.
''';
  }

  /// Creates a fallback analysis when AI fails
  static WordAnalysis _createFallbackAnalysis(
    String word,
    String partOfSpeech,
  ) {
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
