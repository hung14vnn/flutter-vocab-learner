import 'package:vocab_learner/widgets/lottie_icon.dart';

final List<PracticeGame> kPracticeGames = [
  PracticeGame(
    name: 'Flashcards',
    description: 'Use flashcards to memorize vocabulary words and their meanings.',
    icon: LottieIcon(
      animationPath: 'animations/note.json',
      darkAnimationPath: 'animations/note_dark.json',
      size: 50.0,
      isNetwork: false,
      autoPlay: true,
      repeat: true,
    ),
  ),
  PracticeGame(
    name: 'Word Match',
    description: 'Match words with their definitions, images, or synonyms against a timer.',
    icon: LottieIcon(
      animationPath: 'animations/note.json',
      darkAnimationPath: 'animations/note.json',
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