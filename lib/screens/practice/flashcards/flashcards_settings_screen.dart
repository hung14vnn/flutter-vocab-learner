import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_learner/widgets/blur_dialog.dart';

class FlashcardsSettingsScreen extends StatefulWidget {
  const FlashcardsSettingsScreen({super.key});

  @override
  State<FlashcardsSettingsScreen> createState() => _FlashcardsSettingsScreenState();
}

class _FlashcardsSettingsScreenState extends State<FlashcardsSettingsScreen> {
  int _numberOfCards = 20;
  String _gameMode = 'mixed';
  String _difficultyFilter = 'all';
  bool _enableSound = true;
  bool _autoFlip = false;
  double _flipDelay = 2.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _numberOfCards = prefs.getInt('flashcards_number_of_cards') ?? 20;
      _gameMode = prefs.getString('flashcards_game_mode') ?? 'mixed';
      _difficultyFilter = prefs.getString('flashcards_difficulty_filter') ?? 'all';
      _enableSound = prefs.getBool('flashcards_enable_sound') ?? true;
      _autoFlip = prefs.getBool('flashcards_auto_flip') ?? false;
      _flipDelay = prefs.getDouble('flashcards_flip_delay') ?? 2.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('flashcards_number_of_cards', _numberOfCards);
    await prefs.setString('flashcards_game_mode', _gameMode);
    await prefs.setString('flashcards_difficulty_filter', _difficultyFilter);
    await prefs.setBool('flashcards_enable_sound', _enableSound);
    await prefs.setBool('flashcards_auto_flip', _autoFlip);
    await prefs.setDouble('flashcards_flip_delay', _flipDelay);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flashcards Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[400],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Number of Cards Setting
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.style, color: Colors.purple[400]),
                      const SizedBox(width: 12),
                      Text(
                        'Number of Cards',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Cards per session: $_numberOfCards'),
                  Slider(
                    value: _numberOfCards.toDouble(),
                    min: 5,
                    max: 100,
                    divisions: 19,
                    activeColor: Colors.purple[400],
                    onChanged: (value) {
                      setState(() {
                        _numberOfCards = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Game Mode Setting
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gamepad, color: Colors.purple[400]),
                      const SizedBox(width: 12),
                      Text(
                        'Game Mode',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      _buildGameModeOption('definition', 'Definition Mode', 'Show definitions, guess words'),
                      _buildGameModeOption('word', 'Word Mode', 'Show words, guess definitions'),
                      _buildGameModeOption('mixed', 'Mixed Mode', 'Random combination of both'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Difficulty Filter Setting
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.purple[400]),
                      const SizedBox(width: 12),
                      Text(
                        'Difficulty Filter',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDifficultyChip('all', 'All', Colors.grey),
                      _buildDifficultyChip('beginner', 'Beginner', Colors.green),
                      _buildDifficultyChip('intermediate', 'Intermediate', Colors.orange),
                      _buildDifficultyChip('advanced', 'Advanced', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Auto-Flip Settings
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flip_to_front, color: Colors.purple[400]),
                      const SizedBox(width: 12),
                      Text(
                        'Auto-Flip Settings',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Auto-Flip Cards'),
                    subtitle: const Text('Automatically flip cards after delay'),
                    value: _autoFlip,
                    activeColor: Colors.purple[400],
                    onChanged: (value) {
                      setState(() {
                        _autoFlip = value;
                      });
                    },
                    secondary: const Icon(Icons.autorenew),
                  ),
                  
                  if (_autoFlip) ...[
                    const SizedBox(height: 16),
                    Text('Flip delay: ${_flipDelay.toStringAsFixed(1)} seconds'),
                    Slider(
                      value: _flipDelay,
                      min: 1.0,
                      max: 10.0,
                      divisions: 18,
                      activeColor: Colors.purple[400],
                      onChanged: (value) {
                        setState(() {
                          _flipDelay = value;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Audio Settings
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.volume_up, color: Colors.purple[400]),
                      const SizedBox(width: 12),
                      Text(
                        'Audio Settings',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Enable Sound Effects'),
                    subtitle: const Text('Play sounds for interactions'),
                    value: _enableSound,
                    activeColor: Colors.purple[400],
                    onChanged: (value) {
                      setState(() {
                        _enableSound = value;
                      });
                    },
                    secondary: const Icon(Icons.music_note),
                  ),
                ],
              ),
            ),
          ),

          // Reset Settings
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.restore, color: Colors.red[400]),
                      const SizedBox(width: 12),
                      Text(
                        'Reset Settings',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _resetSettings,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[400],
                        side: BorderSide(color: Colors.red[400]!),
                      ),
                      child: const Text('Reset to Default'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeOption(String value, String title, String subtitle) {
    return RadioListTile<String>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      groupValue: _gameMode,
      activeColor: Colors.purple[400],
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _gameMode = newValue;
          });
        }
      },
    );
  }

  Widget _buildDifficultyChip(String value, String label, Color color) {
    final isSelected = _difficultyFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _difficultyFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _resetSettings() {
    showBlurDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _numberOfCards = 20;
                _gameMode = 'mixed';
                _difficultyFilter = 'all';
                _enableSound = true;
                _autoFlip = false;
                _flipDelay = 2.0;
              });
              Navigator.pop(context);
              _saveSettings();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
