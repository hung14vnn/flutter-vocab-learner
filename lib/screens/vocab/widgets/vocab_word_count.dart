import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/vocab_provider.dart';

class VocabWordCount extends StatelessWidget {
  const VocabWordCount({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<VocabProvider>(
      builder: (context, vocabProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Row(
            children: [
              Text(
                '${vocabProvider.filteredWords.length} words',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}