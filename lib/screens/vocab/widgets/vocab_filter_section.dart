import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/vocab_provider.dart';

class VocabFilterSection extends StatelessWidget {
  const VocabFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<VocabProvider>(
      builder: (context, vocabProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: vocabProvider.selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(
                      value: 'beginner',
                      child: Text('Beginner'),
                    ),
                    DropdownMenuItem(
                      value: 'intermediate',
                      child: Text('Intermediate'),
                    ),
                    DropdownMenuItem(
                      value: 'advanced',
                      child: Text('Advanced'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      vocabProvider.setDifficultyFilter(value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: vocabProvider.selectedPartOfSpeech,
                  decoration: const InputDecoration(
                    labelText: 'Part of Speech',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'noun', child: Text('Noun')),
                    DropdownMenuItem(value: 'verb', child: Text('Verb')),
                    DropdownMenuItem(
                      value: 'adjective',
                      child: Text('Adjective'),
                    ),
                    DropdownMenuItem(
                      value: 'adverb',
                      child: Text('Adverb'),
                    ),
                    DropdownMenuItem(
                      value: 'preposition',
                      child: Text('Preposition'),
                    ),
                    DropdownMenuItem(
                      value: 'conjunction',
                      child: Text('Conjunction'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      vocabProvider.setPartOfSpeechFilter(value);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}