import 'package:flutter/material.dart';
import 'package:vocab_learner/consts/app_consts.dart';

class VocabErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const VocabErrorState({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: modernRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading vocabulary',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFB91C1C),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}