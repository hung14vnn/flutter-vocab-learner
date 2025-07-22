import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/vocab_word.dart';
import '../../../providers/vocab_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/progress_service.dart';
import '../../../widgets/game_stats_widget.dart';
import '../../../widgets/difficulty_chip.dart';
import '../../../widgets/sound_feedback_widget.dart';
import '../../../widgets/flashcard_settings_dialog.dart';
import '../../../widgets/achievement_widget.dart';

enum GameMode { definition, word, mixed }
enum CardSide { front, back }

class FlashcardsGameScreen extends StatefulWidget {
  const FlashcardsGameScreen({super.key});

  @override
  State<FlashcardsGameScreen> createState() => _FlashcardsGameScreenState();
}

class _FlashcardsGameScreenState extends State<FlashcardsGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _slideController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _slideAnimation;

  List<VocabWord> _gameWords = [];
  int _currentIndex = 0;
  GameMode _gameMode = GameMode.mixed;
  bool _isLoading = true;
  bool _showAnswer = false;
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  final ProgressService _progressService = ProgressService();
  
  // Settings
  int _numberOfCards = 20;
  String _difficultyFilter = 'all';
  bool _enableSound = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadGameWords();
  }

  void _setupAnimations() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Change from flip to reveal animation
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));
  }

  Future<void> _loadGameWords() async {
    final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
    
    setState(() => _isLoading = true);
    
    try {
      List<VocabWord> words;
      
      // Apply difficulty filter
      if (_difficultyFilter == 'all') {
        words = await vocabProvider.getRandomWords(_numberOfCards);
      } else {
        // Use existing filtered words functionality
        vocabProvider.setDifficultyFilter(_difficultyFilter);
        final filteredWords = vocabProvider.filteredWords
            .where((word) => word.difficulty == _difficultyFilter)
            .toList();
        
        if (filteredWords.length >= _numberOfCards) {
          filteredWords.shuffle();
          words = filteredWords.take(_numberOfCards).toList();
        } else {
          words = filteredWords;
        }
      }
      
      setState(() {
        _gameWords = words;
        _isLoading = false;
        _currentIndex = 0;
        _showAnswer = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load words: $e')),
        );
      }
    }
  }

  void _flipCard() {
    if (_flipController.isAnimating) return;
    
    // Play flip sound and haptic feedback
    if (_enableSound) {
      SoundFeedbackWidget.playFlipSound();
    }
    
    setState(() {
      _showAnswer = !_showAnswer;
    });
    
    if (_flipController.value == 0) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }

  Future<void> _nextCard({required bool isCorrect}) async {
    if (_currentIndex >= _gameWords.length - 1) {
      // Play completion sound
      if (_enableSound) {
        SoundFeedbackWidget.playCompletionSound();
      }
      _showGameComplete();
      return;
    }

    // Play sound feedback and show visual feedback
    if (_enableSound) {
      if (isCorrect) {
        SoundFeedbackWidget.playCorrectSound();
      } else {
        SoundFeedbackWidget.playIncorrectSound();
      }
    }
    
    // Show visual feedback overlay
    if (mounted) {
      SoundFeedbackWidget.showVisualFeedback(context, isCorrect);
    }

    // Update progress
    await _updateProgress(isCorrect);

    // Animate slide out
    await _slideController.forward();
    
    // Update state
    setState(() {
      _currentIndex++;
      _showAnswer = false;
      _totalAnswers++;
      if (isCorrect) _correctAnswers++;
    });

    // Check for achievements
    AchievementSystem.checkAndShowAchievements(
      context,
      correctAnswers: _correctAnswers,
      totalAnswers: _totalAnswers,
      currentIndex: _currentIndex,
      totalWords: _gameWords.length,
    );

    // Reset animations
    _flipController.reset();
    _slideController.reset();
  }

  Future<void> _updateProgress(bool isCorrect) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    if (userId == null) return;

    final currentWord = _gameWords[_currentIndex];
    
    try {
      await _progressService.recordPracticeSession(userId, currentWord.id, isCorrect);
    } catch (e) {
      debugPrint('Error updating progress: $e');
    }
  }

  void _showGameComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('🎉 Game Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_correctAnswers/$_totalAnswers',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Accuracy: ${_totalAnswers > 0 ? ((_correctAnswers / _totalAnswers) * 100).toStringAsFixed(1) : 0}%',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _buildScoreEmoji(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreEmoji() {
    final accuracy = _totalAnswers > 0 ? (_correctAnswers / _totalAnswers) * 100 : 0;
    
    if (accuracy >= 90) {
      return const Text('🌟 Excellent!', style: TextStyle(fontSize: 24));
    } else if (accuracy >= 70) {
      return const Text('😊 Good job!', style: TextStyle(fontSize: 24));
    } else if (accuracy >= 50) {
      return const Text('📚 Keep practicing!', style: TextStyle(fontSize: 24));
    } else {
      return const Text('💪 You can do better!', style: TextStyle(fontSize: 24));
    }
  }

  void _resetGame() {
    setState(() {
      _currentIndex = 0;
      _showAnswer = false;
      _correctAnswers = 0;
      _totalAnswers = 0;
    });
    _flipController.reset();
    _slideController.reset();
    _loadGameWords();
  }

  void _changeGameMode(GameMode mode) {
    setState(() {
      _gameMode = mode;
      _showAnswer = false;
    });
    _flipController.reset();
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => FlashcardSettingsDialog(
        numberOfCards: _numberOfCards,
        difficulty: _difficultyFilter,
        enableSound: _enableSound,
        onSettingsChanged: (numberOfCards, difficulty, enableSound) {
          setState(() {
            _numberOfCards = numberOfCards;
            _difficultyFilter = difficulty;
            _enableSound = enableSound;
          });
          _resetGame();
        },
      ),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
          ),
          PopupMenuButton<GameMode>(
            icon: const Icon(Icons.tune),
            onSelected: _changeGameMode,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: GameMode.definition,
                child: Text('Definition Mode'),
              ),
              const PopupMenuItem(
                value: GameMode.word,
                child: Text('Word Mode'),
              ),
              const PopupMenuItem(
                value: GameMode.mixed,
                child: Text('Mixed Mode'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _gameWords.isEmpty
              ? _buildEmptyState()
              : _buildGameContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No words available for practice',
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

  Widget _buildGameContent() {
    return Column(
      children: [
        _buildProgressIndicator(),
        _buildGameModeIndicator(),
        Expanded(
          child: _buildFlashcard(),
        ),
        _buildControls(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GameStatsWidget(
        correctAnswers: _correctAnswers,
        totalAnswers: _totalAnswers,
        currentIndex: _currentIndex,
        totalWords: _gameWords.length,
      ),
    );
  }

  Widget _buildGameModeIndicator() {
    String modeText;
    switch (_gameMode) {
      case GameMode.definition:
        modeText = 'Definition Mode';
        break;
      case GameMode.word:
        modeText = 'Word Mode';
        break;
      case GameMode.mixed:
        modeText = 'Mixed Mode';
        break;
    }

    final currentWord = _gameWords[_currentIndex];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Chip(
            label: Text(modeText),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          DifficultyChip(
            difficulty: currentWord.difficulty,
            state: currentWord.state,
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: _flipCard,
          child: Card(
            elevation: 8,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _showAnswer
                      ? [Colors.green[50]!, Colors.green[100]!]
                      : [Colors.blue[50]!, Colors.blue[100]!],
                ),
              ),
              child: Stack(
                children: [
                  // Front card (question) - always visible but can fade out
                  AnimatedOpacity(
                    opacity: _showAnswer ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildFrontCard(_gameWords[_currentIndex]),
                  ),
                  // Back card (answer) - slides in from the side to reveal
                  AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(MediaQuery.of(context).size.width * (1 - _flipAnimation.value), 0),
                        child: Opacity(
                          opacity: _flipAnimation.value,
                          child: _buildBackCard(_gameWords[_currentIndex]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(VocabWord word) {
    String content;
    String hint;
    
    switch (_gameMode) {
      case GameMode.definition:
        content = word.definition;
        hint = 'What word is this?';
        break;
      case GameMode.word:
        content = word.word;
        hint = 'What does this word mean?';
        break;
      case GameMode.mixed:
        final isDefinitionFirst = _currentIndex.isEven;
        content = isDefinitionFirst ? word.definition : word.word;
        hint = isDefinitionFirst ? 'What word is this?' : 'What does this word mean?';
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz,
            size: 32,
            color: Colors.blue[600],
          ),
          const SizedBox(height: 24),
          Text(
            hint,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            content,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.visibility, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                'Tap to reveal answer',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(VocabWord word) {
    String answer;
    
    switch (_gameMode) {
      case GameMode.definition:
        answer = word.word;
        break;
      case GameMode.word:
        answer = word.definition;
        break;
      case GameMode.mixed:
        final isDefinitionFirst = _currentIndex.isEven;
        answer = isDefinitionFirst ? word.word : word.definition;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb,
              size: 48,
              color: Colors.green[600],
            ),
            const SizedBox(height: 24),
            Text(
              'Answer:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              answer,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (word.pronunciation != null) ...[
              const SizedBox(height: 16),
              Text(
                word.pronunciation!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (word.examples.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Example:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.examples.first,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_showAnswer) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _nextCard(isCorrect: false),
                    icon: const Icon(Icons.close),
                    label: const Text('Incorrect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _nextCard(isCorrect: true),
                    icon: const Icon(Icons.check),
                    label: const Text('Correct'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _flipCard,
                icon: const Icon(Icons.visibility),
                label: const Text('Reveal Answer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
