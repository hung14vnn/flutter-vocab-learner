import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/vocab_provider.dart';

class PaginationControls extends StatelessWidget {
  const PaginationControls({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<VocabProvider>(
      builder: (context, vocabProvider, child) {
        if (!vocabProvider.isPaginationEnabled || vocabProvider.totalPages <= 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Items per page selector (compact)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Show:',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 6),
                  DropdownButton<int>(
                    value: vocabProvider.itemsPerPage,
                    isDense: true,
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    items: vocabProvider.availablePageSizes.map((size) {
                      return DropdownMenuItem<int>(
                        value: size,
                        child: Text(
                          size.toString(),
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        vocabProvider.setItemsPerPage(value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(width: 64),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 32), // Push navigation slightly to the left
                    // First page button (compact)
                    _buildCompactButton(
                      context,
                      Icons.first_page,
                      vocabProvider.currentPage > 1 ? vocabProvider.goToFirstPage : null,
                      'First',
                    ),
                    const SizedBox(width: 4),
                    // Previous page button (compact)
                    _buildCompactButton(
                      context,
                      Icons.chevron_left,
                      vocabProvider.currentPage > 1 ? vocabProvider.goToPreviousPage : null,
                      'Previous',
                    ),
                    const SizedBox(width: 12),
                    // Page info (compact)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${vocabProvider.currentPage} / ${vocabProvider.totalPages}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Next page button (compact)
                    _buildCompactButton(
                      context,
                      Icons.chevron_right,
                      vocabProvider.currentPage < vocabProvider.totalPages ? vocabProvider.goToNextPage : null,
                      'Next',
                    ),
                    const SizedBox(width: 4),
                    // Last page button (compact)
                    _buildCompactButton(
                      context,
                      Icons.last_page,
                      vocabProvider.currentPage < vocabProvider.totalPages ? vocabProvider.goToLastPage : null,
                      'Last',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Total items info (compact)
              Text(
                '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactButton(
    BuildContext context,
    IconData icon,
    VoidCallback? onPressed,
    String tooltip,
  ) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
          maxWidth: 32,
          maxHeight: 32,
        ),
        style: IconButton.styleFrom(
          backgroundColor: onPressed != null 
              ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.8)
              : null,
          foregroundColor: onPressed != null 
              ? Theme.of(context).colorScheme.onSurface 
              : Theme.of(context).disabledColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

}
