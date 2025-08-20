import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_learner/screens/practice/flashcards/flashcards_game_screen.dart';
import 'package:vocab_learner/screens/practice/flashcards/flashcards_settings_screen.dart';
import 'package:vocab_learner/services/progress_service.dart';
import 'package:vocab_learner/models/user_progress.dart';
import 'package:vocab_learner/providers/vocab_provider.dart';
import 'package:vocab_learner/utils/global_state.dart';

class FlashcardsHomeScreen extends StatefulWidget {
  const FlashcardsHomeScreen({super.key});

  @override
  State<FlashcardsHomeScreen> createState() => _FlashcardsHomeScreenState();
}

class _FlashcardsHomeScreenState extends State<FlashcardsHomeScreen> {
  final ProgressService _progressService = ProgressService();
  UserProgress? _todayProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkTodayProgress();
  }

  Future<void> _checkTodayProgress() async {
    try {
      final userId = GlobalState.getUserId(context);
      if (userId != null) {
        final progress = await _progressService.getTodayProgress(userId , 'flash_cards');
        setState(() {
          _todayProgress = progress;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startTodayProgress(String gameId) async {
    try {
      final userId = GlobalState.getUserId(context);
      if (userId == null) return;

      final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
      final words = vocabProvider.allWords;
      
      if (words.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No vocabulary words available')),
        );
        return;
      }

      // Take 20 words for today's practice
      final todayWords = words.take(20).toList();
      await _progressService.createTodayProgress(
        userId,
        todayWords.map((w) => w.id).toList(),
        gameId,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlashcardsGameScreen(specificWords: todayWords),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start today\'s progress: $e')),
      );
    }
  }

  Future<void> _continueTodayProgress() async {
    try {
      final userId = GlobalState.getUserId(context);
      if (userId == null || _todayProgress == null) return;

      final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
      final words = vocabProvider.allWords;
      
      // Get the words for this progress session
      final progressWords = words.where((w) => _todayProgress!.wordIds.contains(w.id)).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlashcardsGameScreen(specificWords: progressWords),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to continue today\'s progress: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Flashcards',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary.withValues(alpha: 0.9),
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
            colorScheme.surface.withValues(alpha: 0.3),
            colorScheme.surface.withValues(alpha: 0.8),
            colorScheme.surface.withValues(alpha: 0.25),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Icon and Title
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(-5, -5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.web_stories,
                  size: 64,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 32),
              
              // Game Title
              Text(
                'Flashcards',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              
              // Game Description
              Text(
                'Practice vocabulary with interactive flashcards!\nFlip cards to reveal definitions and test your knowledge.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              
              // Progress-aware buttons
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ..._buildProgressButtons(context, theme, colorScheme),
              
              const SizedBox(height: 16),
              
              // Settings Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FlashcardsSettingsScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.6), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.settings, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Settings',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Game Features
              Card(
                color: colorScheme.surface.withValues(alpha: 0.8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Game Features',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureRow(context, Icons.flip_to_front, 'Interactive Card Flipping'),
                      const SizedBox(height: 8),
                      _buildFeatureRow(context, Icons.shuffle, 'Multiple Game Modes'),
                      const SizedBox(height: 8),
                      _buildFeatureRow(context, Icons.volume_up, 'Audio Feedback'),
                      const SizedBox(height: 8),
                      _buildFeatureRow(context, Icons.analytics, 'Progress Analytics'),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProgressButtons(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final userId = GlobalState.getUserId(context);
    
    if (userId == null) {
      // User not authenticated - show login message
      return [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Please sign in to track progress',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ];
    }

    if (_todayProgress == null) {
      // No progress today - show start button and practice without saving
      return [
        // Start Today's Progress Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _startTodayProgress('flash_cards'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.9),
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              side: BorderSide(
                color: colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
              shadowColor: colorScheme.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.today, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Start Today\'s Progress',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Practice Without Saving Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FlashcardsGameScreen(saveProgress: false),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
              foregroundColor: colorScheme.secondary,
              side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.6), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_outline, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Practice Without Saving',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    } else if (_todayProgress!.isLearned) {
      // Progress completed today
      return [
        // Completed Message
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Today\'s Progress Complete!',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Great job! You\'ve completed your flashcard practice for today.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Practice Without Saving Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FlashcardsGameScreen(saveProgress: false),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
              foregroundColor: colorScheme.secondary,
              side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.6), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_outline, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Practice More (No Progress)',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    } else {
      // Progress exists but not completed - show continue button
      final progressPercentage = (_todayProgress!.correctAnswers.length + _todayProgress!.wrongAnswers.length) / _todayProgress!.wordIds.length;
      return [
        // Continue Progress Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _continueTodayProgress,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.tertiary.withValues(alpha: 0.9),
              foregroundColor: colorScheme.onTertiary,
              elevation: 0,
              side: BorderSide(
                color: colorScheme.tertiary.withValues(alpha: 0.3),
                width: 1,
              ),
              shadowColor: colorScheme.tertiary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow, size: 28),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue Today\'s Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(progressPercentage * 100).toInt()}% Complete',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onTertiary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Practice Without Saving Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FlashcardsGameScreen(saveProgress: false),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
              foregroundColor: colorScheme.secondary,
              side: BorderSide(color: colorScheme.secondary.withValues(alpha: 0.6), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_outline, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Practice Without Saving',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
