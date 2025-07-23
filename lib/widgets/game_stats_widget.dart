import 'package:flutter/material.dart';

class GameStatsWidget extends StatelessWidget {
  final int correctAnswers;
  final int totalAnswers;
  final int currentIndex;
  final int totalWords;

  const GameStatsWidget({
    super.key,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.currentIndex,
    required this.totalWords,
  });

  double get accuracy {
    if (totalAnswers == 0) return 0.0;
    return correctAnswers / totalAnswers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                context,
                'Progress',
                '${currentIndex + 1}/$totalWords',
                Icons.auto_stories,
                Color(0xFF3D74B6),
              ),
              _buildStatItem(
                context,
                'Score',
                '$correctAnswers/$totalAnswers',
                Icons.score,
                Color(0xFF8ABB6C),
              ),
              _buildStatItem(
                context,
                'Accuracy',
                '${(accuracy * 100).toStringAsFixed(0)}%',
                Icons.trending_up,
                Color(0xFFFFBC4C),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (currentIndex + 1) / totalWords,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getProgressColor() {
    if (accuracy >= 0.8) return Color(0xFF8ABB6C);
    if (accuracy >= 0.6) return Color(0xFFFFBC4C);
    return Color(0xFFFB4141);
  }
}
