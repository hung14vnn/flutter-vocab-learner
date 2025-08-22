import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/deck_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/deck.dart';

class DeckManagementDialog extends StatefulWidget {
  const DeckManagementDialog({super.key});

  @override
  State<DeckManagementDialog> createState() => _DeckManagementDialogState();
}

class _DeckManagementDialogState extends State<DeckManagementDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedColor = '#2196F3';
  String _selectedIcon = '📚';

  final List<String> _availableColors = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#9C27B0', // Purple
    '#F44336', // Red
    '#00BCD4', // Cyan
    '#795548', // Brown
    '#607D8B', // Blue Grey
  ];

  final List<String> _availableIcons = [
    '📚', '📖', '📝', '📊', '🎯', '🧠', '💡', '🔥',
    '⭐', '🎓', '🏆', '📋', '📌', '🚀', '💼', '🎨',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.folder_open,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Deck Management',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Existing decks
            Consumer<DeckProvider>(
              builder: (context, deckProvider, child) {
                if (deckProvider.decks.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No decks yet. Create your first deck below!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Decks',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...deckProvider.decks.map((deck) => _buildDeckItem(deck, theme)),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Create new deck section
            Text(
              'Create New Deck',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Deck name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Deck Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Business English',
              ),
            ),
            const SizedBox(height: 12),
            
            // Deck description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Brief description of this deck',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // Color selection
            Text(
              'Color',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableColors.map((color) => _buildColorOption(color)).toList(),
            ),
            const SizedBox(height: 16),
            
            // Icon selection
            Text(
              'Icon',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableIcons.map((icon) => _buildIconOption(icon)).toList(),
            ),
            const SizedBox(height: 24),
            
            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _createDeck,
                icon: const Icon(Icons.add),
                label: const Text('Create Deck'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckItem(Deck deck, ThemeData theme) {
    final color = _parseColor(deck.color) ?? theme.colorScheme.primary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (deck.icon != null) ...[
            Text(
              deck.icon!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deck.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (deck.description != null)
                  Text(
                    deck.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                Text(
                  '${deck.wordCount} words',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () {
              // TODO: Implement edit functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(String colorHex) {
    final color = _parseColor(colorHex) ?? Colors.blue;
    final isSelected = _selectedColor == colorHex;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = colorHex;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 4,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _buildIconOption(String icon) {
    final isSelected = _selectedIcon == icon;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIcon = icon;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
              ? Border.all(color: Theme.of(context).colorScheme.primary)
              : null,
        ),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    
    try {
      String hexString = colorString.replaceAll('#', '');
      if (hexString.length == 6) {
        hexString = 'FF$hexString';
      }
      return Color(int.parse(hexString, radix: 16));
    } catch (e) {
      return null;
    }
  }

  void _createDeck() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a deck name')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final deckProvider = Provider.of<DeckProvider>(context, listen: false);
    
    if (authProvider.user == null) return;

    final newDeck = Deck(
      id: '',
      userId: authProvider.user!.uid,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: _selectedColor,
      icon: _selectedIcon,
    );

    try {
      await deckProvider.createDeck(newDeck);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deck created successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create deck: $e')),
        );
      }
    }
  }
}
