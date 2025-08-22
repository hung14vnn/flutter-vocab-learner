import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vocab_learner/widgets/blur_dialog.dart';
import 'package:vocab_learner/widgets/toast_notification.dart';
import '../../../providers/vocab_provider.dart';
import 'add_word_dialog.dart';
import 'import_from_image.dart';

class AddWordOptionsDialog extends StatefulWidget {
  final VocabProvider vocabProvider;
  final String deckId;
  final Function(FilePickerResult)? onFileSelected; // Add callback

  const AddWordOptionsDialog({
    super.key,
    required this.vocabProvider,
    required this.deckId,
    this.onFileSelected,
  });

  @override
  State<AddWordOptionsDialog> createState() => _AddWordOptionsDialogState();
}

class _AddWordOptionsDialogState extends State<AddWordOptionsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Words'),
      content: const Text('How would you like to add new vocabulary words?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _handleFileImport(context);
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.file_upload, size: 20),
              SizedBox(width: 8),
              Text('Import File'),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _handleImageImport(context);
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image, size: 20),
              SizedBox(width: 8),
              Text('Import Image'),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _handleManualAdd(context);
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

  void _handleImageImport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Import from Image'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ImportFromImage(vocabProvider: widget.vocabProvider, deckId: widget.deckId),
        ),
      ),
    );
  }

  void _handleFileImport(BuildContext context) {
    showBlurDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import from File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose file import method:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('From Google Translate Exported File'),
              subtitle: const Text('Import from CSV, or Excel file'),
              onTap: () {
                _showImportFromGoogleTranslate(context, dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('From URL'),
              subtitle: const Text('Import from online vocabulary list'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                ToastNotification.showInfo(
                  context,
                  message: 'URL import coming soon!',
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

  void _handleManualAdd(BuildContext context) {
    showBlurDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Manual Add'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose how to add words manually:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Single Word'),
              subtitle: const Text('Add one word at a time with details'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                _showAddSingleWordForm(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Quick Add Multiple'),
              subtitle: const Text('Add multiple words quickly'),
              onTap: () {
                Navigator.of(dialogContext).pop();
                ToastNotification.showInfo(
                  context,
                  message: 'Quick add coming soon!',
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

  void _showAddSingleWordForm(BuildContext context) {
    showBlurDialog(
      context: context,
      builder: (context) => AddWordDialog(vocabProvider: widget.vocabProvider, deckId: widget.deckId),
    );
  }

  Future<void> _showImportFromGoogleTranslate(BuildContext context, BuildContext dialogContext) async {
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
          if (widget.onFileSelected != null) {
            debugPrint('File selected successfully, triggering callback');
            widget.onFileSelected!(result);
          } else {
            debugPrint('No callback provided for file selection');
            if (context.mounted) {
              ToastNotification.showError(
                context,
                message: 'Import feature not properly configured',
              );
            }
          }
        } else {
          if (context.mounted) {
            ToastNotification.showError(
              context,
              message: 'Unable to access selected file',
            );
          }
        }
      } else {
        debugPrint('No file selected');
      }
    } catch (e) {
      debugPrint('Error in file picker: $e');
      if (context.mounted) {
        ToastNotification.showError(
          context,
          message: 'Failed to select file: $e',
        );
      }
    }
  }
}
