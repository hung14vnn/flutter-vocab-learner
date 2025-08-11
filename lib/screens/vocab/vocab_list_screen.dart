// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vocab_learner/screens/vocab/widgets/add_word_options.dart';
import 'package:vocab_learner/screens/vocab/widgets/import_from_google_translate_dialog.dart';
import 'package:vocab_learner/screens/vocab/widgets/vocab_word_list.dart';
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

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  void _showAddWordOptions(BuildContext context, VocabProvider vocabProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddWordOptionsDialog(
          vocabProvider: vocabProvider,
          onFileSelected: (result) {
            // Show the import dialog immediately
            _showImportDialog(context, vocabProvider, result);
          },
        );
      },
    );
  }
  
  void _showImportDialog(BuildContext context, VocabProvider vocabProvider, FilePickerResult result) {
    // Use SchedulerBinding to ensure the operation happens after the frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        showDialog(
          context: context,
          builder: (context) => ImportFromGoogleTranslateDialog(
            vocabProvider: vocabProvider, 
            filePickerResult: result,
          ),
        );
      } else {
        debugPrint('Widget or context no longer mounted, cannot show import dialog');
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, VocabProvider vocabProvider) {
    final selectedCount = vocabProvider.selectedCount;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('Deleting words...'),
                      ],
                    ),
                  ),
                );

                final success = await vocabProvider.deleteSelectedWords();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success 
                          ? 'Successfully deleted $selectedCount word${selectedCount > 1 ? 's' : ''}'
                          : 'Failed to delete words. Please try again.',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabProvider>(
      builder: (context, vocabProvider, child) {
        return Scaffold(
          appBar: AppBar(
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
                          ? () => _showDeleteConfirmation(context, vocabProvider)
                          : null,
                    ),
                  ]
                : [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // TODO: Implement search functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Search coming soon!')),
                        );
                      },
                    ),
                  ],
          ),
          body: Consumer<VocabProvider>(
            builder: (context, vocabProvider, child) {
              if (vocabProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vocabProvider.errorMessage != null) {
                return VocabErrorState(
                  errorMessage: vocabProvider.errorMessage!,
                  onRetry: () {
                    // TODO: Implement retry functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Retry coming soon!')),
                    );
                  },
                );
              }

              if (vocabProvider.allWords.isEmpty) {
                return const VocabEmptyState();
              }

              return const Column(
                children: [
                  VocabFilterSection(),
                  VocabWordCount(),
                  VocabWordsList(),
                ],
              );
            },
          ),
          floatingActionButton: vocabProvider.isSelectionMode
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    _showAddWordOptions(context, vocabProvider);
                  },
                  child: const Icon(Icons.add),
                ),
        );
      },
    );
  }
}