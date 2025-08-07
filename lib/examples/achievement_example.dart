import 'package:flutter/material.dart';
import '../widgets/achievement_widget.dart';

class AchievementExampleScreen extends StatefulWidget {
  const AchievementExampleScreen({super.key});

  @override
  State<AchievementExampleScreen> createState() => _AchievementExampleScreenState();
}

class _AchievementExampleScreenState extends State<AchievementExampleScreen> {
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  int _currentIndex = 0;
  final int _totalWords = 20;

  void _simulateCorrectAnswer() {
    setState(() {
      _correctAnswers++;
      _totalAnswers++;
      _currentIndex++;
    });

    // Check for achievements after each correct answer
    AchievementSystem.checkAndShowAchievements(
      context,
      correctAnswers: _correctAnswers,
      totalAnswers: _totalAnswers,
      currentIndex: _currentIndex,
      totalWords: _totalWords,
      averageTime: const Duration(seconds: 2), // Simulate fast response
      totalSessions: 50, // Simulate session count
      totalWordsLearned: 500, // Simulate words learned
    );
  }

  void _simulateWrongAnswer() {
    setState(() {
      _totalAnswers++;
      _currentIndex++;
    });

    AchievementSystem.checkAndShowAchievements(
      context,
      correctAnswers: _correctAnswers,
      totalAnswers: _totalAnswers,
      currentIndex: _currentIndex,
      totalWords: _totalWords,
    );
  }

  void _resetProgress() {
    setState(() {
      _correctAnswers = 0;
      _totalAnswers = 0;
      _currentIndex = 0;
    });
    AchievementSystem.resetShownAchievements();
  }

  void _showCustomAchievement(AchievementType type) {
    final achievements = {
      AchievementType.common: {
        'title': 'Getting Started!',
        'description': 'You answered your first question!',
        'icon': Icons.play_arrow,
        'color': Colors.blue,
      },
      AchievementType.rare: {
        'title': 'Nice Progress!',
        'description': 'You are doing great!',
        'icon': Icons.thumb_up,
        'color': Colors.green,
      },
      AchievementType.epic: {
        'title': 'Amazing Work!',
        'description': 'Your skills are impressive!',
        'icon': Icons.emoji_events,
        'color': Colors.purple,
      },
      AchievementType.legendary: {
        'title': 'LEGENDARY!',
        'description': 'You have achieved greatness!',
        'icon': Icons.auto_awesome,
        'color': Colors.amber,
      },
    };

    final data = achievements[type]!;
    AchievementSystem.showAchievement(
      context,
      title: data['title'] as String,
      description: data['description'] as String,
      icon: data['icon'] as IconData,
      color: data['color'] as Color,
      type: type,
      points: type == AchievementType.legendary ? 1000 : type == AchievementType.epic ? 500 : type == AchievementType.rare ? 100 : 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = _totalAnswers > 0 ? _correctAnswers / _totalAnswers : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement System Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Progress Statistics',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Correct', _correctAnswers, Colors.green),
                        _buildStatCard('Total', _totalAnswers, Colors.blue),
                        _buildStatCard('Progress', '$_currentIndex/$_totalWords', Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _totalWords > 0 ? _currentIndex / _totalWords : 0,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Simulate Answers',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _currentIndex < _totalWords ? _simulateCorrectAnswer : null,
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text('Correct Answer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _currentIndex < _totalWords ? _simulateWrongAnswer : null,
                            icon: const Icon(Icons.close, color: Colors.white),
                            label: const Text('Wrong Answer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _resetProgress,
                      child: const Text('Reset Progress'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Test Achievement Types',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildAchievementButton('Common', AchievementType.common, Colors.grey),
                        _buildAchievementButton('Rare', AchievementType.rare, Colors.blue),
                        _buildAchievementButton('Epic', AchievementType.epic, Colors.purple),
                        _buildAchievementButton('Legendary', AchievementType.legendary, Colors.amber),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(height: 8),
                    Text(
                      'Try answering questions to trigger different achievements!',
                      style: TextStyle(color: Colors.blue.shade700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Features: • Animated particles • Gradient backgrounds • Different rarities • Points system • Sound & haptic feedback',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, dynamic value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAchievementButton(String label, AchievementType type, Color color) {
    return ElevatedButton(
      onPressed: () => _showCustomAchievement(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
