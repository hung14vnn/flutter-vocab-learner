import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/vocab_provider.dart';

class VocabWordCount extends StatelessWidget {
  const VocabWordCount({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<VocabProvider>(
      builder: (context, vocabProvider, child) {
        String countText = '${vocabProvider.filteredWords.length} words';

        if (!vocabProvider.isPaginationEnabled) {
          if (vocabProvider.hasMoreData) {
            countText += ' (showing ${vocabProvider.filteredWords.length}+)';
          } else {
            countText += ' (all loaded)';
          }
        } else {
          countText =
              'Showing ${_getItemRangeText(vocabProvider)} of ${vocabProvider.totalItems} words';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                countText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              if (!vocabProvider.isPaginationEnabled) ...[
                const SizedBox(width: 8),
                Icon(Icons.layers, size: 16, color: Colors.grey.shade600),
              ],
              if (vocabProvider.isPaginationEnabled) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.format_list_numbered,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _getItemRangeText(VocabProvider vocabProvider) {
    int startItem =
        (vocabProvider.currentPage - 1) * vocabProvider.itemsPerPage + 1;
    int endItem = (vocabProvider.currentPage * vocabProvider.itemsPerPage)
        .clamp(0, vocabProvider.totalItems);

    if (vocabProvider.totalItems == 0) {
      return '0';
    }

    return '$startItem-$endItem';
  }
}
