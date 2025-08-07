import 'dart:ui';

import 'package:vocab_learner/widgets/lottie_icon.dart';

final List<PracticeGame> kPracticeGames = [
  PracticeGame(
    name: 'Flashcards',
    description: 'Use flashcards to memorize vocabulary words and their meanings.',
    icon: LottieIcon(
      animationPath: 'assets/animations/note.json',
      darkAnimationPath: 'assets/animations/note_dark.json',
      size: 50.0,
      isNetwork: false,
      autoPlay: true,
      repeat: true,
    ),
  ),
];
class PracticeGame {  
  final String name;
  final String description;
  final LottieIcon icon;

  PracticeGame({
    required this.name,
    required this.description,
    required this.icon,
  });
} 

  // Pastel color palette
  final Color pastelPurple = const Color(0xFFD1C4E9);
  final Color pastelGreen = const Color(0xFFC8E6C9);
  final Color pastelBlue = const Color(0xFFB3E5FC);
  final Color pastelYellow = const Color(0xFFFFF9C4);
  final Color pastelPink = const Color(0xFFF8BBD0);
  final Color pastelRed = const Color(0xFFFFCDD2);
  final Color pastelGrey = const Color(0xFFF5F5F5);
  final Color pastelOrange = const Color(0xFFFFE0B2);