import 'package:flutter/material.dart';

class DeckChip extends StatelessWidget {
  final String? deckName;
  final String? deckColor;
  final String? deckIcon;
  final VoidCallback? onTap;

  const DeckChip({
    super.key,
    this.deckName,
    this.deckColor,
    this.deckIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (deckName == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final color = _parseColor(deckColor) ?? theme.colorScheme.primaryContainer;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (deckIcon != null) ...[
              Text(
                deckIcon!,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              deckName!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getTextColor(color, theme),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    
    try {
      // Remove # if present
      String hexString = colorString.replaceAll('#', '');
      
      // Add alpha if not present
      if (hexString.length == 6) {
        hexString = 'FF$hexString';
      }
      
      return Color(int.parse(hexString, radix: 16));
    } catch (e) {
      return null;
    }
  }

  Color _getTextColor(Color backgroundColor, ThemeData theme) {
    // Calculate luminance to determine if we should use light or dark text
    final luminance = backgroundColor.computeLuminance();
    if (luminance > 0.5) {
      return theme.colorScheme.onSurface;
    } else {
      return theme.colorScheme.surface;
    }
  }
}
