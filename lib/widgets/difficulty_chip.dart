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
        color = const Color(0xFF10B981); // Modern emerald
        icon = Icons.looks_one;
        break;
      case 'intermediate':
        color = const Color(0xFFF59E0B); // Modern amber
        icon = Icons.looks_two;
        break;
      case 'advanced':
        color = const Color(0xFFEF4444); // Modern red
        icon = Icons.looks_3;
        break;
      default:
        color = const Color(0xFFF1F5F9); // Modern slate
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
      color = const Color(0xFF3B82F6); 
      text = 'NEW';
      icon = Icons.fiber_new;
    } else if (state == WordState.learningState) {
      color = const Color(0xFFF59E0B);
      text = 'LEARNING';
      icon = Icons.school;
    } else if (state == WordState.masteredState) {
      color = const Color(0xFF10B981);
      text = 'MASTERED';
      icon = Icons.check_circle;
    } else {
      color = const Color(0xFFF1F5F9);
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
