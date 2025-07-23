import 'package:flutter/material.dart';
import '../models/vocab_word.dart';

class DifficultyChip extends StatelessWidget {
  final String difficulty;
  final WordState? state;

  const DifficultyChip({
    super.key,
    required this.difficulty,
    this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDifficultyChip(context),
        if (state != null) ...[
          const SizedBox(width: 8),
          _buildStateChip(context),
        ],
      ],
    );
  }

  Widget _buildDifficultyChip(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = Color(0xFF8ABB6C); // Green
        icon = Icons.looks_one;
        break;
      case 'intermediate':
        color = Color(0xFFFFBC4C); // Orange
        icon = Icons.looks_two;
        break;
      case 'advanced':
        color = Color(0xFFFB4141); // Red
        icon = Icons.looks_3;
        break;
      default:
        color = Color(0xFFF3E9DC); // Grey
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        difficulty.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStateChip(BuildContext context) {
    if (state == null) return const SizedBox.shrink();
    
    Color color;
    String text;
    IconData icon;
    
    if (state == WordState.newWordState) {
      color = Color(0xFF3D74B6); 
      text = 'NEW';
      icon = Icons.fiber_new;
    } else if (state == WordState.learningState) {
      color = Color(0xFFFB9E3A);
      text = 'LEARNING';
      icon = Icons.school;
    } else if (state == WordState.masteredState) {
      color = Color(0xFF8ABB6C);
      text = 'MASTERED';
      icon = Icons.check_circle;
    } else {
      color = Color(0xFFF3E9DC);
      text = 'UNKNOWN';
      icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 16),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
