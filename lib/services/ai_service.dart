import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_analysis.dart';

class AIService {
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Analyzes a word using Gemini AI and returns comprehensive word information
  static Future<WordAnalysis> analyzeWord({
    required String word,
    required String apiKey,
    required String modelName,
    String? userLanguage,
  }) async {
    try {
      // Get API key from provider (pass as argument)
      if (word.isEmpty) throw Exception('Word is required');
      if (apiKey.isEmpty) {
        throw Exception(
          'Gemini API key not set. Please log in and provide your API key.',
        );
      }
      final prompt = _buildWordAnalysisPrompt(word, userLanguage);
      final response = await http.post(
        Uri.parse('$baseUrl/$modelName:generateContent?key=$apiKey'),
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
          'Gemini API authentication failed. Please check your API key. ',
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

      throw Exception(
        'Failed to analyze word "$word". Please try again later.',
      );
    }
    // Removed static apiKey field
  }

  /// Builds a comprehensive prompt for word analysis
  static String _buildWordAnalysisPrompt(String word, String? userLanguage) {
    final definitionInUserLanguageField = userLanguage != null
        ? '"definitionInUserLanguage": "A brief translation of the word in $userLanguage",'
        : '"definitionInUserLanguage": null,';

    return '''
Analyze the word "$word" and provide a comprehensive analysis in JSON format.

You are a helpful English language assistant specialized in vocabulary analysis. You always respond with valid JSON only.

IMPORTANT: All values must be in double quotes. Do NOT use unquoted values, code blocks, or markdown. Respond ONLY with valid JSON, no extra text.

Please respond with ONLY valid JSON in the following format:
{
  "fixedWord": "fixed word for misspelling if applicable",
  "definition": "A clear, concise definition of the word",
  "pronunciation": "IPA phonetic transcription (e.g., /wɜːrd/)",
  $definitionInUserLanguageField
  "examples": ["Example sentence 1", "Example sentence 2", "Example sentence 3"],
  "synonyms": ["synonym1", "synonym2", "synonym3"],
  "difficulty": "beginner|intermediate|advanced",
  "partOfSpeech": "noun|verb|adjective|adverb|conjunction|preposition"
}

Requirements:
- Fixed Word: Fix the word if it's misspelled and replace the original word with the fixed word in the rest of the analysis
- Definition: Clear and educational, suitable for language learners, dont include the word itself in the definition(e.g., "box" = "a container with a lid", not "a box is a container with a lid"), if it has multiple meanings, provide at most 3 most common definitions
- Pronunciation: Use proper IPA notation
${userLanguage != null ? 'DefinitionInUserLanguage: Provide a brief translation of the word itself in $userLanguage (not the definition, just the word translation, e.g., "hello" = "xin chào")' : ''}
- Examples: 3 varied, practical sentences showing different contexts, divided by commas
- Synonyms: 3-5 relevant synonyms if available
- Difficulty: Classify as "beginner" (common, everyday words), "intermediate" (moderately complex), or "advanced" (academic, technical, or rare words)
- Part of Speech: Specify the part of speech (noun, verb, adjective, adverb, conjunction, preposition)

Focus on making this educational and useful for vocabulary learning.
''';
  }
}
