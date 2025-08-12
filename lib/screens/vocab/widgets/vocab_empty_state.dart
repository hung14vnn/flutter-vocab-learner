import 'package:flutter/material.dart';
import 'package:vocab_learner/consts/app_consts.dart';

class VocabEmptyState extends StatelessWidget {
  const VocabEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: modernBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'No vocabulary words yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF0EA5E9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Words will appear here once you add them',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF38BDF8),
            ),
          ),
        ],
      ),
    );
  }
}