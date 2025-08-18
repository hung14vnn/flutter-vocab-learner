import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/vocab_provider.dart';
import 'providers/progress_provider.dart';
import 'widgets/app_loading_wrapper.dart';
import 'consts/app_theme.dart';
import 'package:vocab_learner/screens/practice/flashcards/flashcards_game_screen.dart';
import 'package:vocab_learner/screens/practice/word_scramble/word_scramble_game_screen.dart';
import 'package:vocab_learner/screens/practice/flashcards/flashcards_home_screen.dart';
import 'package:vocab_learner/screens/practice/word_scramble/word_scramble_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize window manager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(578.25, 1028),
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const VocabLearnerApp());
}

class VocabLearnerApp extends StatelessWidget {
  const VocabLearnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, VocabProvider>(
          create: (_) => VocabProvider(),
          update: (_, authProvider, vocabProvider) {
            vocabProvider?.setUserId(authProvider.user?.uid);
            return vocabProvider!;
          },
        ),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: MaterialApp(
        title: 'Vocabulary',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AppLoadingWrapper(),
        routes: {
          '/flashcards': (context) => const FlashcardsHomeScreen(),
          '/word_scramble': (context) => const WordScrambleHomeScreen(),
          '/flashcards_game': (context) => const FlashcardsGameScreen(),
          '/word_scramble_game': (context) => const WordScrambleGameScreen(),
          // ...other routes...
        },
      ),
    );
  }
}
