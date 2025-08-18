// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vocab_learner/screens/vocab/widgets/add_word_options.dart';
import 'package:vocab_learner/screens/vocab/widgets/import_from_google_translate_dialog.dart';
import 'package:vocab_learner/screens/vocab/widgets/vocab_word_list.dart';
import 'package:vocab_learner/screens/vocab/widgets/pagination_controls.dart';
import 'package:vocab_learner/widgets/toast_notification.dart';
import 'package:vocab_learner/widgets/blur_dialog.dart';
import 'package:vocab_learner/widgets/shimmer_effect.dart';
import '../../providers/vocab_provider.dart';
import '../../providers/auth_provider.dart';
import 'widgets/vocab_filter_section.dart';
import 'widgets/vocab_word_count.dart';
import 'widgets/vocab_empty_state.dart';
import 'widgets/vocab_error_state.dart';

class VocabListScreen extends StatefulWidget {
  const VocabListScreen({super.key});

  @override
  State<VocabListScreen> createState() => _VocabListScreenState();
}

class _VocabListScreenState extends State<VocabListScreen> {
  late AuthProvider authProvider;
  final ScrollController _scrollController = ScrollController();
  bool _isAddButtonVisible = true;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // Hide button when scrolled to the bottom (within 50 pixels threshold)
      final shouldShowButton = (maxScroll - currentScroll) > 50;

      if (shouldShowButton != _isAddButtonVisible) {
        setState(() {
          _isAddButtonVisible = shouldShowButton;
        });
      }
    }
  }

  void _showAddWordOptions(BuildContext context, VocabProvider vocabProvider) {
    showBlurDialog(
      context: context,
      blurStrength: 6.0,
      builder: (dialogContext) => AddWordOptionsDialog(
        vocabProvider: vocabProvider,
        onFileSelected: (result) {
          // Show the import dialog immediately
          _showImportDialog(context, vocabProvider, result);
        },
      ),
    );
  }

  void _showImportDialog(
    BuildContext context,
    VocabProvider vocabProvider,
    FilePickerResult result,
  ) {
    // Use SchedulerBinding to ensure the operation happens after the frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        showBlurDialog(
          context: context,
          blurStrength: 6.0,
          builder: (dialogContext) => ImportFromGoogleTranslateDialog(
            vocabProvider: vocabProvider,
            filePickerResult: result,
          ),
        );
      } else {
        debugPrint(
          'Widget or context no longer mounted, cannot show import dialog',
        );
      }
    });
  }

  void _showDeleteConfirmation(
    BuildContext context,
    VocabProvider vocabProvider,
  ) {
    final selectedCount = vocabProvider.selectedCount;
    showBlurDialog(
      context: context,
      blurStrength: 6.0,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Words'),
        content: Text(
          'Are you sure you want to delete $selectedCount selected word${selectedCount > 1 ? 's' : ''}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              ToastNotification.showLoading(
                context,
                message:
                    'Deleting $selectedCount word${selectedCount > 1 ? 's' : ''}...',
              );

              final success = await vocabProvider.deleteSelectedWords();

              if (mounted) {
                ToastNotification.hide(context);
                if (success) {
                  ToastNotification.showSuccess(
                    context,
                    message:
                        '$selectedCount word${selectedCount > 1 ? 's' : ''} deleted successfully!',
                  );
                } else {
                  ToastNotification.showError(
                    context,
                    message: 'Failed to delete selected words',
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabProvider>(
      builder: (context, vocabProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withValues(alpha: 0.1),
                colorScheme.surface.withValues(alpha: 0.6),
                colorScheme.secondary.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: vocabProvider.isSelectionMode
                  ? Text('${vocabProvider.selectedCount} selected')
                  : const Text('Vocabulary'),
              leading: vocabProvider.isSelectionMode
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        vocabProvider.clearSelection();
                      },
                    )
                  : null,
              actions: vocabProvider.isSelectionMode
                  ? [
                      IconButton(
                        icon: const Icon(Icons.select_all),
                        onPressed: () {
                          vocabProvider.selectAllWords();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: vocabProvider.selectedCount > 0
                            ? () => _showDeleteConfirmation(
                                context,
                                vocabProvider,
                              )
                            : null,
                      ),
                    ]
                  : [
                      IconButton(
                        icon: Icon(
                          vocabProvider.isPaginationEnabled
                              ? Icons.format_list_numbered
                              : Icons.all_inclusive,
                        ),
                        tooltip: vocabProvider.isPaginationEnabled
                            ? 'Switch to infinite scroll mode'
                            : 'Switch to page navigation mode',
                        onPressed: () {
                          vocabProvider.togglePaginationMode();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          vocabProvider.isCompactMode
                              ? Icons.view_agenda
                              : Icons.view_list,
                        ),
                        tooltip: vocabProvider.isCompactMode
                            ? 'Switch to detailed view'
                            : 'Switch to compact view',
                        onPressed: () {
                          vocabProvider.toggleCompactMode();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isFilterExpanded
                              ? Icons.filter_list_off
                              : Icons.filter_list,
                        ),
                        tooltip: _isFilterExpanded
                            ? 'Hide filters'
                            : 'Show filters',
                        onPressed: () {
                          setState(() {
                            _isFilterExpanded = !_isFilterExpanded;
                          });
                        },
                      ),
                    ],
            ),
            body: Consumer<VocabProvider>(
              builder: (context, vocabProvider, child) {
                if (vocabProvider.errorMessage != null) {
                  print(vocabProvider.errorMessage);
                  return VocabErrorState(
                    errorMessage: vocabProvider.errorMessage!,
                    onRetry: () {
                      ToastNotification.showWarning(
                        context,
                        message: "Retry coming soon!",
                      );
                    },
                  );
                }

                if (vocabProvider.isFirstLoading) {
                  return Column(
                    children: [
                      if (_isFilterExpanded) ...[
                        VocabFilterSection(
                          onClose: () {
                            setState(() {
                              _isFilterExpanded = false;
                            });
                          },
                        ),
                      ],
                      const VocabWordCount(),
                      const PaginationControls(),
                      Expanded(
                        child: VocabWordsShimmerList(
                          isCompactMode: vocabProvider.isCompactMode,
                          itemCount: 10,
                        ),
                      ),
                    ],
                  );
                }

                if (vocabProvider.allWords.isEmpty) {
                  return Column(
                    children: [
                      if (_isFilterExpanded) ...[
                        VocabFilterSection(
                          onClose: () {
                            setState(() {
                              _isFilterExpanded = false;
                            });
                          },
                        ),
                      ],
                      const Expanded(child: VocabEmptyState()),
                    ],
                  );
                }

                return Column(
                  children: [
                    if (_isFilterExpanded) ...[
                      VocabFilterSection(
                        onClose: () {
                          setState(() {
                            _isFilterExpanded = false;
                          });
                        },
                      ),
                    ],
                    if (vocabProvider.isPaginationEnabled) ...[
                      PaginationControls(),
                    ],
                    if (!vocabProvider.isPaginationEnabled) ...[
                      VocabWordCount(),
                    ],
                    if (vocabProvider.isSearching) ...[
                      Expanded(
                        child: SearchLoadingOverlay(
                          isCompactMode: vocabProvider.isCompactMode,
                          child: VocabWordsList(
                            scrollController: _scrollController,
                          ),
                        ),
                      ),
                    ] else if (vocabProvider.isLoading &&
                        !vocabProvider.isFirstLoading) ...[
                      Expanded(
                        child: VocabWordsShimmerList(
                          isCompactMode: vocabProvider.isCompactMode,
                          itemCount: 5,
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: VocabWordsList(
                          scrollController: _scrollController,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            floatingActionButton:
                vocabProvider.isSelectionMode || !_isAddButtonVisible
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      _showAddWordOptions(context, vocabProvider);
                    },
                    child: const Icon(Icons.add),
                  ),
          ),
        );
      },
    );
  }
}
