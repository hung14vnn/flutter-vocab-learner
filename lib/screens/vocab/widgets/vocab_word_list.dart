import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_learner/models/vocab_word.dart';
import 'package:vocab_learner/widgets/toast_notification.dart';
import 'package:vocab_learner/widgets/shimmer_effect.dart';
import '../../../providers/vocab_provider.dart';
import 'vocab_word_card.dart';

class VocabWordsList extends StatefulWidget {
  final ScrollController? scrollController;

  const VocabWordsList({super.key, this.scrollController});

  @override
  State<VocabWordsList> createState() => _VocabWordsListState();
}

class _VocabWordsListState extends State<VocabWordsList> {
  @override
  void initState() {
    super.initState();
    // Add scroll listener for pagination
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController?.hasClients ?? false) {
      final scrollController = widget.scrollController!;
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;

      // Load more when user is 200 pixels from bottom (only for infinite scroll mode)
      if (maxScroll - currentScroll <= 200) {
        final vocabProvider = Provider.of<VocabProvider>(
          context,
          listen: false,
        );
        if (!vocabProvider.isPaginationEnabled &&
            vocabProvider.hasMoreData &&
            !vocabProvider.isLoadingMore) {
          vocabProvider.loadMoreWords();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabProvider>(
      builder: (context, vocabProvider, child) {
        final showLoadingIndicator =
            !vocabProvider.isPaginationEnabled && vocabProvider.isLoadingMore;
        final itemCount =
            vocabProvider.filteredWords.length + (showLoadingIndicator ? 1 : 0);

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (showLoadingIndicator &&
                      index == vocabProvider.filteredWords.length) {
                    return _buildLoadingIndicator();
                  }
                  
                  final word = vocabProvider.filteredWords[index];
                  return VocabWordCard(
                    word: word,
                    isSelectionMode: vocabProvider.isSelectionMode,
                    isSelected: vocabProvider.isWordSelected(word.id),
                    isCompactMode: vocabProvider.isCompactMode,
                    onSelectionToggle: () {
                      if (!vocabProvider.isSelectionMode) {
                        vocabProvider.toggleSelectionMode();
                      }
                      vocabProvider.toggleWordSelection(word.id);
                    },
                    onLongPress: () {
                      if (!vocabProvider.isSelectionMode) {
                        vocabProvider.toggleSelectionMode();
                        vocabProvider.toggleWordSelection(word.id);
                      }
                    },
                    onEdit: (VocabWord updatedWord) async {
                      final success = await vocabProvider.updateWord(
                        updatedWord,
                      );
                      if (success) {
                        ToastNotification.showSuccess(
                          context,
                          message:
                              'Word "${updatedWord.word}" updated successfully!',
                        );
                      } else {
                        ToastNotification.showError(
                          context,
                          message:
                              'Failed to update word "${updatedWord.word}"',
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Consumer<VocabProvider>(
      builder: (context, vocabProvider, child) {
        return Column(
          children: [
            VocabWordCardShimmer(
              isCompactMode: vocabProvider.isCompactMode,
            ),
            VocabWordCardShimmer(
              isCompactMode: vocabProvider.isCompactMode,
            ),
            VocabWordCardShimmer(
              isCompactMode: vocabProvider.isCompactMode,
            ),
          ],
        );
      },
    );
  }
}
