import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_learner/widgets/toast_notification.dart';
import '../../../models/vocab_word.dart';
import '../../../providers/vocab_provider.dart';
import '../../../services/progress_service.dart';
import '../flashcards/widgets/game_stats_widget.dart';
import '../../../widgets/difficulty_chip.dart';
import '../flashcards/widgets/sound_feedback_widget.dart';
import '../../../widgets/achievement_widget.dart';
import 'dart:math' as math;

enum GameDifficulty { easy, medium, hard }

class WordScrambleGameScreen extends StatefulWidget {
  final List<VocabWord>? specificWords;

  const WordScrambleGameScreen({super.key, this.specificWords});

  @override
  State<WordScrambleGameScreen> createState() => _WordScrambleGameScreenState();
}

class _WordScrambleGameScreenState extends State<WordScrambleGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _slideController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<Offset> _slideAnimation;

  List<VocabWord> _gameWords = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  final ProgressService _progressService = ProgressService();
  bool _progressRecorded = false;

  // Game state
  List<String> _scrambledLetters = [];
  List<String> _selectedLetters = [];
  String _userAnswer = '';
  bool _showHint = false;
  bool _gameCompleted = false;

  // Settings
  int _numberOfWords = 15;
  GameDifficulty _difficulty = GameDifficulty.medium;
  String _difficultyFilter = 'all';
  bool _enableSound = true;
  bool _showDefinition = true;

  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadGameWords();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _slideController.dispose();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(1.5, 0)).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
  }

  Future<void> _loadGameWords() async {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      List<VocabWord> words;

      if (widget.specificWords != null && widget.specificWords!.isNotEmpty) {
        words = widget.specificWords!;
      } else {
        if (_difficultyFilter == 'all') {
          words = await vocabProvider.getRandomWords(_numberOfWords);
        } else {
          vocabProvider.setDifficultyFilter(_difficultyFilter);
          final filteredWords = vocabProvider.filteredWords
              .where((word) => word.difficulty == _difficultyFilter)
              .toList();

          if (filteredWords.length >= _numberOfWords) {
            filteredWords.shuffle();
            words = filteredWords.take(_numberOfWords).toList();
          } else {
            words = filteredWords;
          }
        }
      }

      // Filter words that are suitable for scrambling (3+ letters)
      words = words.where((word) => word.word.length >= 3).toList();

      setState(() {
        _gameWords = words;
        _isLoading = false;
        _currentIndex = 0;
        _gameCompleted = false;
      });

      if (_gameWords.isNotEmpty) {
        _setupCurrentWord();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ToastNotification.showError(
          context,
          message: 'Failed to load words: $e',
        );
      }
    }
  }

  void _setupCurrentWord() {
    if (_currentIndex >= _gameWords.length) return;

    final currentWord = _gameWords[_currentIndex];
    setState(() {
      _scrambledLetters = _scrambleWord(currentWord.word);
      _selectedLetters.clear();
      _userAnswer = '';
      _showHint = false;
      _answerController.clear();
    });
  }

  List<String> _scrambleWord(String word) {
    final letters = word.toLowerCase().split('');
    final random = math.Random();

    // Create a more sophisticated scrambling based on difficulty
    switch (_difficulty) {
      case GameDifficulty.easy:
        // Keep first and last letter in place for easier words
        if (letters.length > 3) {
          final middle = letters.sublist(1, letters.length - 1);
          middle.shuffle(random);
          return [letters.first] + middle + [letters.last];
        }
        break;
      case GameDifficulty.medium:
        // Standard shuffle
        break;
      case GameDifficulty.hard:
        // Add extra complexity by ensuring the word doesn't resemble the original
        for (int i = 0; i < 5; i++) {
          letters.shuffle(random);
          if (letters.join() != word.toLowerCase()) break;
        }
        return letters;
    }

    letters.shuffle(random);
    return letters;
  }

  void _onLetterTap(int index) {
    if (index >= _scrambledLetters.length) return;

    setState(() {
      final letter = _scrambledLetters[index];
      _selectedLetters.add(letter);
      _userAnswer += letter;
      _answerController.text = _userAnswer;
      _scrambledLetters.removeAt(index);
    });

    // Auto-check if all letters are used
    if (_scrambledLetters.isEmpty) {
      _checkAnswer();
    }
  }

  void _onSelectedLetterTap(int index) {
    if (index >= _selectedLetters.length) return;

    setState(() {
      final letter = _selectedLetters[index];
      _scrambledLetters.add(letter);
      _selectedLetters.removeAt(index);
      _userAnswer = _selectedLetters.join();
      _answerController.text = _userAnswer;
    });
  }

  void _shuffleLetters() {
    setState(() {
      _scrambledLetters.shuffle();
    });

    if (_enableSound) {
      SoundFeedbackWidget.playFlipSound();
    }
  }

  void _clearAnswer() {
    setState(() {
      _scrambledLetters.addAll(_selectedLetters);
      _selectedLetters.clear();
      _userAnswer = '';
      _answerController.clear();
    });
  }

  void _showHintDialog() {
    setState(() {
      _showHint = true;
    });
  }

  Future<void> _checkAnswer() async {
    final currentWord = _gameWords[_currentIndex];
    final isCorrect =
        _userAnswer.toLowerCase() == currentWord.word.toLowerCase();

    if (isCorrect) {
      _bounceController.forward().then((_) => _bounceController.reverse());
      if (_enableSound) {
        SoundFeedbackWidget.playCorrectSound();
      }
    } else {
      _shakeController.forward().then((_) => _shakeController.reverse());
      if (_enableSound) {
        SoundFeedbackWidget.playIncorrectSound();
      }
    }

    // Show visual feedback
    if (mounted) {
      SoundFeedbackWidget.showVisualFeedback(context, isCorrect);
    }

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 1500));

    if (isCorrect) {
      _nextWord();
    } else {
      // Reset for retry
      _setupCurrentWord();
    }
  }

  // Future<void> _updateProgress(bool isCorrect) async {
  //   if (_progressRecorded) return;

  //   try {
  //     final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //     final user = authProvider.user;
  //     if (user != null) {
  //       final currentWord = _gameWords[_currentIndex];
  //       await _progressService.recordWordProgress(
  //         userId: user.uid,
  //         wordId: currentWord.id,
  //         isCorrect: isCorrect,
  //         gameType: 'word_scramble',
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('Error updating progress: $e');
  //   }
  // }

  void _nextWord() {
    setState(() {
      _totalAnswers++;
      _correctAnswers++;
      _currentIndex++;
    });

    if (_currentIndex >= _gameWords.length) {
      _showGameComplete();
    } else {
      // Slide animation before showing next word
      _slideController.forward().then((_) {
        _slideController.reset();
        _setupCurrentWord();
      });
    }

    // Check for achievements
    AchievementSystem.checkAndShowAchievements(
      context,
      correctAnswers: _correctAnswers,
      totalAnswers: _totalAnswers,
      currentIndex: _currentIndex,
      totalWords: _gameWords.length,
    );
  }

  void _showGameComplete() {
    setState(() {
      _gameCompleted = true;
    });

    if (_enableSound) {
      SoundFeedbackWidget.playCompletionSound();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You completed the word scramble game!'),
            const SizedBox(height: 16),
            Text('Score: $_correctAnswers / ${_gameWords.length}'),
            Text(
              'Accuracy: ${((_correctAnswers / _gameWords.length) * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      _correctAnswers = 0;
      _totalAnswers = 0;
      _gameCompleted = false;
      _progressRecorded = false;
    });
    _loadGameWords();
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Number of Words'),
              subtitle: Slider(
                value: _numberOfWords.toDouble(),
                min: 5,
                max: 30,
                divisions: 5,
                label: _numberOfWords.toString(),
                onChanged: null,
              ),
            ),
            ListTile(
              title: const Text('Difficulty'),
              subtitle: DropdownButton<GameDifficulty>(
                value: _difficulty,
                onChanged: null,
                items: GameDifficulty.values.map((difficulty) {
                  return DropdownMenuItem(
                    value: difficulty,
                    child: Text(difficulty.name.toUpperCase()),
                  );
                }).toList(),
              ),
            ),
            SwitchListTile(
              title: const Text('Show Definition'),
              value: _showDefinition,
              onChanged: (value) {
                setState(() {
                  _showDefinition = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Sound Effects'),
              value: _enableSound,
              onChanged: (value) {
                setState(() {
                  _enableSound = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text('Apply & Restart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Scramble'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : _gameWords.isEmpty
          ? _buildEmptyState()
          : _gameCompleted
          ? _buildCompletedState()
          : _buildGameContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shuffle, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No words available for scramble game',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Game Completed!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: $_correctAnswers / ${_gameWords.length}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
              ElevatedButton(
                onPressed: _restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Play Again'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    final currentWord = _gameWords[_currentIndex];

    return Column(
      children: [
        _buildProgressIndicator(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildWordInfo(currentWord),
                const SizedBox(height: 32),
                _buildSelectedLetters(),
                const SizedBox(height: 24),
                _buildScrambledLetters(),
                const Spacer(),
                _buildControls(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GameStatsWidget(
        correctAnswers: _correctAnswers,
        totalAnswers: _totalAnswers,
        currentIndex: _currentIndex,
        totalWords: _gameWords.length,
      ),
    );
  }

  Widget _buildWordInfo(VocabWord word) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_showDefinition) ...[
              const Text(
                'Definition:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.definition,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
            DifficultyChip(difficulty: word.difficulty),
            if (_showHint) ...[
              const SizedBox(height: 12),
              Text(
                'Hint: ${word.word.length} letters',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedLetters() {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.purple[50],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _selectedLetters.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _onSelectedLetterTap(entry.key),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.value.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrambledLetters() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(20 * math.sin(_shakeAnimation.value * math.pi * 4), 0),
          child: SlideTransition(
            position: _slideAnimation,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _scrambledLetters.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _onLetterTap(entry.key),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        entry.value.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: _shuffleLetters,
          icon: const Icon(Icons.shuffle),
          label: const Text('Shuffle'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _clearAnswer,
          icon: const Icon(Icons.clear),
          label: const Text('Clear'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _showHintDialog,
          icon: const Icon(Icons.lightbulb),
          label: const Text('Hint'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _selectedLetters.isNotEmpty ? _checkAnswer : null,
          icon: const Icon(Icons.check),
          label: const Text('Check'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
