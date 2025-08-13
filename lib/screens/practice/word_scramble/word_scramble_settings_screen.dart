import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocab_learner/widgets/blur_dialog.dart';

class WordScrambleSettingsScreen extends StatefulWidget {
  const WordScrambleSettingsScreen({super.key});

  @override
  State<WordScrambleSettingsScreen> createState() => _WordScrambleSettingsScreenState();
}

class _WordScrambleSettingsScreenState extends State<WordScrambleSettingsScreen> {
  bool _enableHints = true;
  bool _enableTimer = false;
  bool _enableSound = true;
  int _timeLimit = 30; // Time limit per word in seconds

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableHints = prefs.getBool('word_scramble_enable_hints') ?? true;
      _enableTimer = prefs.getBool('word_scramble_enable_timer') ?? false;
      _enableSound = prefs.getBool('word_scramble_enable_sound') ?? true;
      _timeLimit = prefs.getInt('word_scramble_time_limit') ?? 30;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('word_scramble_enable_hints', _enableHints);
    await prefs.setBool('word_scramble_enable_timer', _enableTimer);
    await prefs.setBool('word_scramble_enable_sound', _enableSound);
    await prefs.setInt('word_scramble_time_limit', _timeLimit);
    
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
          'Word Scramble Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[400],
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
          // Time Limit Setting
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
                      Icon(Icons.timer, color: Colors.blue[400]),
                      const SizedBox(width: 12),
                      Text(
                        'Time Limit',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Time per word: $_timeLimit seconds'),
                  Slider(
                    value: _timeLimit.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 22,
                    activeColor: Colors.blue[400],
                    onChanged: (value) {
                      setState(() {
                        _timeLimit = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Game Features Settings
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
                      Icon(Icons.tune, color: Colors.blue[400]),
                      const SizedBox(width: 12),
                      Text(
                        'Game Features',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Enable Hints
                  SwitchListTile(
                    title: const Text('Enable Hints'),
                    subtitle: const Text('Show hints when stuck'),
                    value: _enableHints,
                    activeColor: Colors.blue[400],
                    onChanged: (value) {
                      setState(() {
                        _enableHints = value;
                      });
                    },
                    secondary: const Icon(Icons.lightbulb_outline),
                  ),
                  
                  // Enable Timer
                  SwitchListTile(
                    title: const Text('Enable Timer'),
                    subtitle: const Text('Add time pressure to the game'),
                    value: _enableTimer,
                    activeColor: Colors.blue[400],
                    onChanged: (value) {
                      setState(() {
                        _enableTimer = value;
                      });
                    },
                    secondary: const Icon(Icons.timer),
                  ),
                  
                  // Enable Sound
                  SwitchListTile(
                    title: const Text('Enable Sound Effects'),
                    subtitle: const Text('Play sounds for correct/incorrect answers'),
                    value: _enableSound,
                    activeColor: Colors.blue[400],
                    onChanged: (value) {
                      setState(() {
                        _enableSound = value;
                      });
                    },
                    secondary: const Icon(Icons.volume_up),
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
                _enableHints = true;
                _enableTimer = false;
                _enableSound = true;
                _timeLimit = 30;
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
