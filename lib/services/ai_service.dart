import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:vocab_learner/models/app_user.dart';
import '../models/word_analysis.dart';
import '../models/csv_analysis_result.dart';

class AIService {
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return AppUser.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<WordAnalysis> analyzeWord({
    required String word,
    required String userId,
  }) async {
    try {
      final userDoc = await getUser(userId);
      if (userDoc == null) {
        throw Exception('User not found');
      }
      if (word.isEmpty) throw Exception('Word is required');
      if (userDoc.apiKey!.isEmpty) {
        throw Exception(
          'Gemini API key not set. Please log in and provide your API key.',
        );
      }
      final prompt = _buildWordAnalysisPrompt(word, userDoc.language);
      final response = await http.post(
        Uri.parse(
          '$baseUrl/${userDoc.modelVersion}:generateContent?key=${userDoc.apiKey}',
        ),
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
      if (e.toString().contains('API key') ||
          e.toString().contains('authentication')) {
        rethrow;
      }

      throw Exception(
        'Failed to analyze word "$word". Please try again later.',
      );
    }
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
      "antonyms": ["antonym1", "antonym2", "antonym3"],
      "tags": ["tag1", "tag2", "tag3"],
      "difficulty": "beginner|intermediate|advanced",
      "partOfSpeech": "noun|verb|adjective|adverb|conjunction|preposition"
    }

    Requirements:
    - Fixed Word: Fix the word if it's misspelled and replace the original word with the fixed word in the rest of the analysis
    - Definition: Clear and educational, suitable for language learners, dont include the word itself in the definition(e.g., "box" = "a container with a lid", not "a box is a container with a lid"), if it has multiple meanings, provide at most 3 most common definitions
    - Pronunciation: Use proper IPA notation
    ${userLanguage != null ? 'DefinitionInUserLanguage: Provide a brief translation of the word itself in $userLanguage (not the definition, just the word translation, e.g., "hello" = "xin chào")' : ''}
    - Examples: 3 varied, practical sentences showing different contexts
    - Synonyms: 3-5 relevant synonyms if available
    - Antonyms: 3-5 relevant antonyms if available
    - Tags: 3-5 relevant tags or categories for the word (e.g., "food", "emotion", "nature")
    - Difficulty: Classify as "beginner" (common, everyday words), "intermediate" (moderately complex), or "advanced" (academic, technical, or rare words)
    - Part of Speech: Specify the part of speech (noun, verb, adjective, adverb, conjunction, preposition)

    Focus on making this educational and useful for vocabulary learning.
    ''';
  }

  Future<CSVAnalysisResult> analyzeCSVData({
    required Map<String, String> csvData,
    required String userId,
    Function(int current, int total)? onProgress,
  }) async {
    try {
      if (csvData.isEmpty) {
        throw Exception('CSV data is empty');
      }
      final userDoc = await getUser(userId);
      if (userDoc == null) {
        throw Exception('User not found');
      }
      // Extract valid word pairs
      final listWords = <String>[];
      for (final entry in csvData.entries) {
        final originalWord = entry.key.trim();
        if (originalWord.isNotEmpty) {
          listWords.add(originalWord);
        }
      }

      onProgress?.call(1, 2); // Starting analysis

      // Build batch analysis prompt
      final prompt = _buildBatchAnalysisPrompt(listWords, userDoc.language);

      // Make single API call
      final response = await http.post(
        Uri.parse(
          '$baseUrl/${userDoc.modelVersion}:generateContent?key=${userDoc.apiKey}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'maxOutputTokens': 8000, // Increased for batch processing
            'temperature': 0.7,
          },
        }),
      );

      onProgress?.call(2, 2); // Analysis complete

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        var content =
            responseData['candidates'][0]['content']['parts'][0]['text'];

        // Clean up response
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

        // Parse batch response
        final batchResult = jsonDecode(content);
        final words = <CSVWordAnalysis>[];
        final errors = <String>[];
        int successfulAnalyses = 0;
        int failedAnalyses = 0;

        if (batchResult['words'] is List) {
          for (final wordData in batchResult['words']) {
            try {
              words.add(CSVWordAnalysis.fromJson(wordData));
              successfulAnalyses++;
            } catch (e) {
              // Create failed entry if JSON parsing fails
              final originalWord = wordData['originalWord'] ?? 'Unknown';
              final translation = wordData['translation'] ?? '';
              words.add(
                CSVWordAnalysis.failed(
                  originalWord: originalWord,
                  translation: translation,
                  errorMessage: 'Failed to parse AI response: $e',
                ),
              );
              errors.add('Failed to parse analysis for "$originalWord": $e');
              failedAnalyses++;
            }
          }
        }

        return CSVAnalysisResult(
          words: words,
          totalWords: words.length,
          successfulAnalyses: successfulAnalyses,
          failedAnalyses: failedAnalyses,
          errors: errors,
        );
      } else if (response.statusCode == 401) {
        throw Exception(
          'Gemini API authentication failed. Please check your API key.',
        );
      } else if (response.statusCode == 429) {
        throw Exception(
          'Gemini API quota exceeded. Please check your plan and billing details.',
        );
      } else {
        throw Exception(
          'Gemini API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to analyze CSV data: $e');
    }
  }

  /// Builds a batch analysis prompt for multiple words
  static String _buildBatchAnalysisPrompt(
    List<String> listWords,
    String? userLanguage,
  ) {
    final translationInUserLanguageField = userLanguage != null
        ? '"translation": "A brief translation of the word in $userLanguage",'
        : '"translation": null,';

    final wordsListJson = listWords.map((word) => word).join(',\n');

    return '''
    Analyze the following list of words and their translations, and provide comprehensive analysis for each word in JSON format.

    You are a helpful English language assistant specialized in vocabulary analysis. You always respond with valid JSON only.

    IMPORTANT: All values must be in double quotes. Do NOT use unquoted values, code blocks, or markdown. Respond ONLY with valid JSON, no extra text.

    Input words to analyze:
    [
    $wordsListJson
    ]

    Please respond with ONLY valid JSON in the following format:
    {
      "words": [
        {
          "originalWord": "the original word from input",
          "fixedWord": "fixed word for misspelling if applicable, otherwise same as originalWord",
          "definition": "A clear, concise definition of the word",
          "pronunciation": "IPA phonetic transcription (e.g., /wɜːrd/)",
          $translationInUserLanguageField
          "examples": ["Example sentence 1", "Example sentence 2", "Example sentence 3"],
          "synonyms": ["synonym1", "synonym2", "synonym3"],
          "antonyms": ["antonym1", "antonym2", "antonym3"],
          "tags": ["tag1", "tag2", "tag3"],
          "difficulty": "beginner|intermediate|advanced",
          "partOfSpeech": "noun|verb|adjective|adverb|conjunction|preposition",
          "isAnalysisSuccessful": true
        }
      ]
    }

    Requirements for each word:
    - Original Word: Keep exactly as provided in input
    - Fixed Word: Fix the word if it's misspelled and replace the original word with the fixed word in the rest of the analysis
    - Definition: Clear and educational, suitable for language learners, dont include the word itself in the definition(e.g., "box" = "a container with a lid", not "a box is a container with a lid"), if it has multiple meanings, provide at most 3 most common definitions
    - Pronunciation: Use proper IPA notation
    ${userLanguage != null ? '- Translation: Provide a brief translation of the word itself in (not the definition, just the word translation, e.g., "hello" = "xin chào")' : ''}
    - Examples: 3 varied, practical sentences showing different contexts
    - Synonyms: 3-5 relevant synonyms if available
    - Antonyms: 3-5 relevant antonyms if available
    - Tags: 3-5 relevant tags or categories for the word (e.g., "food", "emotion", "nature")
    - Difficulty: Classify as "beginner" (common, everyday words), "intermediate" (moderately complex), or "advanced" (academic, technical, or rare words)
    - Part of Speech: Specify the main part of speech (noun, verb, adjective, adverb, conjunction, preposition)
    - Analysis Successful: Always set to true unless there's an error

    Focus on making this educational and useful for vocabulary learning. Process ALL words in the input list.
    ''';
  }
}
