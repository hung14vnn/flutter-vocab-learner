import 'package:flutter/material.dart';

class FlashcardSettingsDialog extends StatefulWidget {
  final int numberOfCards;
  final String difficulty;
  final bool enableSound;
  final Function(int, String, bool) onSettingsChanged;

  const FlashcardSettingsDialog({
    super.key,
    required this.numberOfCards,
    required this.difficulty,
    required this.enableSound,
    required this.onSettingsChanged,
  });

  @override
  State<FlashcardSettingsDialog> createState() => _FlashcardSettingsDialogState();
}

class _FlashcardSettingsDialogState extends State<FlashcardSettingsDialog> {
  late int _numberOfCards;
  late String _difficulty;
  late bool _enableSound;

  @override
  void initState() {
    super.initState();
    _numberOfCards = widget.numberOfCards;
    _difficulty = widget.difficulty;
    _enableSound = widget.enableSound;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings, size: 24),
          SizedBox(width: 8),
          Text('Game Settings'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Number of Cards',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _numberOfCards.toDouble(),
              min: 5,
              max: 50,
              divisions: 9,
              label: _numberOfCards.toString(),
              onChanged: (value) {
                setState(() {
                  _numberOfCards = value.round();
                });
              },
            ),
            Text(
              '$_numberOfCards cards',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Difficulty Filter',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _difficulty,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Difficulties')),
                DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
              ],
              onChanged: (value) {
                setState(() {
                  _difficulty = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  _enableSound ? Icons.volume_up : Icons.volume_off,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sound Effects',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: _enableSound,
                  onChanged: (value) {
                    setState(() {
                      _enableSound = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tips',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Start with fewer cards to build confidence\n'
                    '• Mix difficulties for balanced practice\n'
                    '• Sound effects provide instant feedback',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSettingsChanged(_numberOfCards, _difficulty, _enableSound);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
