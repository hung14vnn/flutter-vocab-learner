# AI Word Analysis Feature

This document describes how to use the `analyzeWord` function in the Vocab Learner app.

## Overview

The `analyzeWord` function uses OpenAI's GPT-3.5-turbo model to automatically generate comprehensive vocabulary information for any English word. It now supports multi-language definitions based on the user's native language preference.

## Features

- **Automatic Definition**: Generates clear, educational definitions in English
- **Native Language Support**: Provides definitions in the user's native language when available
- **Pronunciation Guide**: Provides IPA phonetic transcription
- **Example Sentences**: Creates 3 practical example sentences
- **Synonyms**: Lists relevant synonyms
- **Difficulty Classification**: Automatically classifies words as beginner, intermediate, or advanced

## Setting Your Language

1. Navigate to the Profile section
2. Find the "Language Settings" card
3. Select your native language from the dropdown
4. The setting will be saved automatically

Supported languages:
- English
- Vietnamese
- Spanish
- French
- German
- Chinese
- Japanese
- Korean

## Usage

### In the Vocabulary List Screen

1. Navigate to the Vocabulary section
2. Tap the "+" button to add a new word
3. Choose "Manual Add" → "Add Single Word"
4. Enter a word in the word field
5. Click the "AI Generate" button
6. The system will automatically fill in:
   - Definition (in English)
   - Definition in your native language (if set and different from English)
   - Pronunciation
   - Example sentences
   - Synonyms
   - Difficulty level

### Programmatic Usage

```dart
import 'package:vocab_learner/services/ai_service.dart';

// Analyze a word with user's language preference
final analysis = await AIService.analyzeWord(
  word: 'beautiful',
  partOfSpeech: 'adjective',
  userLanguage: 'Vietnamese', // Optional - user's native language
);

// Access the results
print('Definition: ${analysis.definition}');
print('Definition in user language: ${analysis.definitionInUserLanguage}');
print('Pronunciation: ${analysis.pronunciation}');
print('Examples: ${analysis.examples.join(", ")}');
print('Synonyms: ${analysis.synonyms.join(", ")}');
print('Difficulty: ${analysis.difficulty}');
```

## Error Handling

The function includes robust error handling:
- **Network Issues**: Returns fallback analysis if API is unavailable
- **API Errors**: Gracefully handles rate limits and authentication issues
- **Invalid Responses**: Provides fallback data if AI response is malformed

## Fallback Behavior

When the AI service fails, the function returns a basic analysis structure that users can edit manually:
- Basic definition template
- Phonetic placeholder
- Empty examples and synonyms lists
- Default difficulty classification

## Security Notes

- The OpenAI API key is included in the service (note: in production, this should be moved to environment variables)
- All requests are made over HTTPS
- No user data is permanently stored by the AI service

## Testing

Run the AI service tests:
```bash
flutter test test/ai_service_test.dart
```

## Dependencies

- `http: ^1.1.0` - For making API requests
- `dart:convert` - For JSON parsing
- OpenAI GPT-3.5-turbo API

## Models

### WordAnalysis Class

```dart
class WordAnalysis {
  final String definition;
  final String? definitionInUserLanguage; // Definition in user's native language
  final String pronunciation;
  final List<String> examples;
  final List<String> synonyms;
  final String difficulty;
}
```

This class represents the result of AI word analysis with proper JSON serialization support and multi-language definition support.
