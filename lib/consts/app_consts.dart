import 'package:flutter/material.dart';

final List<PracticeGame> kPracticeGames = [
  PracticeGame(
    name: 'Flashcards',
    description: 'Use flashcards to memorize vocabulary words and their meanings.',
    icon: Icon(
      Icons.web_stories,
      size: 40.0,
    ),
  ),
  PracticeGame(
    name: "Word Scramble",
    description: "Test your vocabulary skills by scrambling words and solving them.",
    icon: Icon(
      Icons.shuffle,
      size: 40.0,
    ),
  ),
];
class PracticeGame {  
  final String name;
  final String description;
  final Icon icon;

  PracticeGame({
    required this.name,
    required this.description,
    required this.icon,
  });
} 

  // Modern color palette
  final Color modernPurple = const Color(0xFFEDE9FE); // Soft violet
  final Color modernGreen = const Color(0xFFD1FAE5); // Soft emerald
  final Color modernBlue = const Color(0xFFDBEAFE); // Soft sky blue
  final Color modernYellow = const Color(0xFFFEF3C7); // Soft amber
  final Color modernPink = const Color(0xFFFCE7F3); // Soft pink
  final Color modernRed = const Color(0xFFFEE2E2); // Soft rose
  final Color modernGrey = const Color(0xFFF8FAFC); // Clean slate
  final Color modernOrange = const Color(0xFFFED7AA); // Soft orange

final List<String> listNamesApp = [
  'Vocabulary',
  'Từ vựng',
  'Vocabulario',
  'Vocabulaire',
  'Vokabeln',
  '词汇',
  '語彙',
  '어휘',
];