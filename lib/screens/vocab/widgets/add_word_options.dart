import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../providers/vocab_provider.dart';
import 'add_word_dialog.dart';

class AddWordOptionsDialog extends StatelessWidget {
  final VocabProvider vocabProvider;
  final Function(FilePickerResult)? onFileSelected; // Add callback

  const AddWordOptionsDialog({super.key, required this.vocabProvider, this.onFileSelected});

  @override
  Widget build(BuildContext context) {
    // Use the root context for all async dialog operations
    final rootContext = context;
    return AlertDialog(
      title: const Text('Add New Words'),
      content: const Text('How would you like to add new vocabulary words?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _handleImportWords(rootContext);
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.file_upload, size: 20),
              SizedBox(width: 8),
              Text('Import'),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _handleManualAdd(rootContext);
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Manual Add'),
            ],
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _handleImportWords(BuildContext rootContext) {
    showDialog(
      context: rootContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import Words'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose import method:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('From CSV File'),
              subtitle: const Text('Import from comma-separated values file'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  const SnackBar(content: Text('CSV import coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('From File'),
              subtitle: const Text('Import from TXT, CSV, or Excel file'),
              onTap: () {
                _showImportFromGoogleTranslate(rootContext, dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('From URL'),
              subtitle: const Text('Import from online vocabulary list'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  const SnackBar(content: Text('URL import coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleManualAdd(BuildContext rootContext) {
    showDialog(
      context: rootContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Manual Add'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose how to add words manually:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Add Single Word'),
              subtitle: const Text('Add one word with full details'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showAddSingleWordForm(rootContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Quick Add Multiple'),
              subtitle: const Text('Add multiple words quickly'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  const SnackBar(content: Text('Quick add coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddSingleWordForm(BuildContext rootContext) {
    showDialog(
      context: rootContext,
      builder: (context) => AddWordDialog(vocabProvider: vocabProvider),
    );
  }

  Future<void> _showImportFromGoogleTranslate(BuildContext rootContext, BuildContext dialogContext) async {
    try {
      // Close the current dialog first using the correct dialog context
      Navigator.of(dialogContext).pop();
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv', 'xlsx', 'xls'],
        dialogTitle: 'Select vocabulary file (TXT, CSV, or Excel)',
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path;
        if (filePath != null) {
          // Use callback if provided, otherwise show error
          if (onFileSelected != null) {
            debugPrint('File selected successfully, triggering callback');
            onFileSelected!(result);
          } else {
            debugPrint('No callback provided for file selection');
            // Show error message using root context if it's still mounted
            if (rootContext.mounted) {
              ScaffoldMessenger.of(rootContext).showSnackBar(
                const SnackBar(content: Text('Import feature not properly configured')),
              );
            }
          }
        } else {
          debugPrint('No file path available');
          if (rootContext.mounted) {
            ScaffoldMessenger.of(rootContext).showSnackBar(
              const SnackBar(content: Text('Unable to access selected file')),
            );
          }
        }
      } else {
        debugPrint('No file selected');
        // User cancelled file selection, no need to show error
      }
    } catch (e) {
      // Handle any errors that might occur during file picking
      debugPrint('Error in file picker: $e');
      // Only show error if context is still valid
      if (rootContext.mounted) {
        ScaffoldMessenger.of(rootContext).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e')),
        );
      }
    }
  }
}
