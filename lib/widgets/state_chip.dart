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
      color = Color(0xFF3D74B6);
      text = 'NEW';
    } else if (state == WordState.learningState) {
      color = Color(0xFFFFC107);
      text = 'LEARNING';
    } else if (state == WordState.masteredState) {
      color = Color(0xFF8ABB6C);
      text = 'MASTERED';
    } else {
      color = Color.fromARGB(255, 109, 105, 99);
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
