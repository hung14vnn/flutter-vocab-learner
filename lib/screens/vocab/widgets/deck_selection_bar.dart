import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/deck_provider.dart';
import '../../../providers/vocab_provider.dart';
import 'deck_management_dialog.dart';

class DeckSelectionBar extends StatefulWidget {
  const DeckSelectionBar({super.key});

  @override
  State<DeckSelectionBar> createState() => _DeckSelectionBarState();
}

class _DeckSelectionBarState extends State<DeckSelectionBar> {
  String? _loadingDeckId;

  void _handleDeckSelection(String? deckId, DeckProvider deckProvider, VocabProvider vocabProvider) async {
    setState(() {
      _loadingDeckId = deckId ?? 'all';
    });
    
    if (deckId == null) {
      deckProvider.selectDeck(null);
      vocabProvider.setDeckFilter('');
    } else {
      final deck = deckProvider.decks.firstWhere((d) => d.id == deckId);
      deckProvider.selectDeck(deck);
      vocabProvider.setDeckFilter(deckId);
    }
    
    // Listen for the search to complete
    void searchListener() {
      if (!vocabProvider.isSearching && !vocabProvider.isLoading && mounted) {
        setState(() {
          _loadingDeckId = null;
        });
        vocabProvider.removeListener(searchListener);
      }
    }
    
    vocabProvider.addListener(searchListener);
    
    // Fallback: clear loading after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _loadingDeckId != null) {
        setState(() {
          _loadingDeckId = null;
        });
        vocabProvider.removeListener(searchListener);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Consumer<DeckProvider>(
        builder: (context, deckProvider, child) {
          return Row(
            children: [
              Icon(
                Icons.folder_open,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // All decks option
                      _buildDeckChip(
                        name: 'All Decks',
                        icon: '📚',
                        color: theme.colorScheme.primary,
                        isSelected: deckProvider.selectedDeck == null,
                        isLoading: _loadingDeckId == 'all',
                        onTap: () {
                          final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
                          _handleDeckSelection(null, deckProvider, vocabProvider);
                        },
                        theme: theme,
                      ),
                      const SizedBox(width: 8),
                      
                      // Individual decks
                      ...deckProvider.decks.map((deck) {
                        final color = _parseColor(deck.color) ?? theme.colorScheme.primary;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildDeckChip(
                            name: deck.name,
                            icon: deck.icon,
                            color: color,
                            wordCount: deck.wordCount,
                            isSelected: deckProvider.selectedDeck?.id == deck.id,
                            isLoading: _loadingDeckId == deck.id,
                            onTap: () {
                              final vocabProvider = Provider.of<VocabProvider>(context, listen: false);
                              _handleDeckSelection(deck.id, deckProvider, vocabProvider);
                            },
                            theme: theme,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Manage decks button
              IconButton(
                icon: Icon(
                  Icons.settings,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Manage Decks',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const DeckManagementDialog(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeckChip({
    required String name,
    String? icon,
    required Color color,
    int? wordCount,
    required bool isSelected,
    bool isLoading = false,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? color
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed-width container for icon/loading indicator
            SizedBox(
              width: 16,
              height: 16,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSelected ? color : theme.colorScheme.onSurface,
                          ),
                        ),
                      )
                    : icon != null
                        ? Text(
                            icon,
                            style: const TextStyle(fontSize: 14),
                          )
                        : const SizedBox.shrink(),
              ),
            ),
            if (icon != null || isLoading) const SizedBox(width: 6),
            Text(
              name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? color
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (wordCount != null && !isLoading) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? color.withValues(alpha: 0.3)
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  wordCount.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected 
                        ? color
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
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
}
