// Example of how to use the enhanced AI word analysis with user language support
// This file demonstrates the complete flow from user language setting to AI analysis

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ai_service.dart';

class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Analysis Example')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current User Language: ${authProvider.appUser?.language ?? "Not set"}',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () =>
                      _demonstrateAIAnalysis(context, authProvider),
                  child: const Text('Analyze Word "Beautiful"'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _demonstrateAIAnalysis(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    try {
      // Get user's language preference
      final userLanguage = authProvider.appUser?.language;

      // Analyze the word with user's language
      final analysis = await AIService.analyzeWord(
        word: 'beautiful',
        partOfSpeech: 'adjective',
        userLanguage: userLanguage,
      );

      // Show results in a dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('AI Analysis Results'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildResultItem('Definition', analysis.definition),
                  if (analysis.definitionInUserLanguage != null)
                    _buildResultItem(
                      'Definition in $userLanguage',
                      analysis.definitionInUserLanguage!,
                    ),
                  _buildResultItem('Pronunciation', analysis.pronunciation),
                  _buildResultItem('Examples', analysis.examples.join('\n')),
                  _buildResultItem('Synonyms', analysis.synonyms.join(', ')),
                  _buildResultItem('Difficulty', analysis.difficulty),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
