import 'package:flutter/material.dart';
import '../models/vocab_word.dart';

class StateChip extends StatelessWidget {
  final WordState state;
  const StateChip({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    if (state == WordState.newWordState) {
      color = Colors.blue;
      text = 'NEW';
    } else if (state == WordState.learningState) {
      color = Colors.orange;
      text = 'LEARNING';
    } else if (state == WordState.masteredState) {
      color = Colors.green;
      text = 'MASTERED';
    } else {
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
