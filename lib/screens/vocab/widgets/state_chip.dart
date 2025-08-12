import 'package:flutter/material.dart';
import '../../../models/vocab_word.dart';

class StateChip extends StatelessWidget {
  final WordState state;
  const StateChip({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    if (state == WordState.newWordState) {
      color = const Color(0xFF3B82F6);
      text = 'NEW';
    } else if (state == WordState.learningState) {
      color = const Color(0xFFF59E0B);
      text = 'LEARNING';
    } else if (state == WordState.masteredState) {
      color = const Color(0xFF10B981);
      text = 'MASTERED';
    } else if (state == WordState.reviewedState) {
      color = const Color(0xFF64748B);
      text = 'REVIEWED';
    }
    else {
      color = Colors.grey;
      text = 'UNKNOWN';
    }
    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
