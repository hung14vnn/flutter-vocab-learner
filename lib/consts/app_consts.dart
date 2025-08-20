import 'package:flutter/material.dart';

final List<PracticeGame> kPracticeGames = [
  PracticeGame(
    name: 'Flashcards',
    description: 'Use flashcards to memorize vocabulary words and their meanings.',
    gameId: 'flash_cards',
    icon: Icon(
      Icons.web_stories,
      size: 32.0,
    ),
  ),
  PracticeGame(
    name: "Word Scramble",
    description: "Test your vocabulary skills by scrambling words and solving them.",
    gameId: 'word_scramble',
    icon: Icon(
      Icons.shuffle,
      size: 32.0,
    ),
  ),
];
class PracticeGame {  
  final String name;
  final String description;
  final String gameId;
  final Icon icon;

  PracticeGame({
    required this.name,
    required this.description,
    required this.gameId,
    required this.icon,
  });
} 

  // Modern color palette
  final Color modernPurpleDarkMode = const Color(0xFFEDE9FE);
  final Color modernGreenDarkMode = const Color(0xFFD1FAE5);
  final Color modernBlueDarkMode = const Color(0xFFDBEAFE);
  final Color modernYellowDarkMode = const Color(0xFFFEF3C7);
  final Color modernPinkDarkMode = const Color(0xFFFCE7F3);
  final Color modernRedDarkMode = const Color(0xFFFEE2E2);
  final Color modernGreyDarkMode = const Color(0xFFF8FAFC);
  final Color modernOrangeDarkMode = const Color(0xFFFED7AA);
  final Color modernPurpleLightMode = const Color(0xFF7C3AED);
  final Color modernGreenLightMode = const Color(0xFF6EE7B7);
  final Color modernBlueLightMode = const Color(0xFF60A5FA);
  final Color modernYellowLightMode = const Color(0xFFFBBF24);
  final Color modernPinkLightMode = const Color(0xFFFBCFE8);
  final Color modernRedLightMode = const Color(0xFFF87171);
  final Color modernGreyLightMode = const Color.fromARGB(255, 98, 100, 105);
  final Color modernOrangeLightMode = const Color.fromARGB(255, 228, 162, 48);

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