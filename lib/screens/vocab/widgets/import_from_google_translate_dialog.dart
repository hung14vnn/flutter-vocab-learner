import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:provider/provider.dart';
import 'package:vocab_learner/providers/auth_provider.dart';
import 'package:vocab_learner/providers/vocab_provider.dart';
import 'package:vocab_learner/services/ai_service.dart';
import 'package:vocab_learner/models/vocab_word.dart';
import 'package:vocab_learner/utils/guid_generator.dart';
import 'package:vocab_learner/widgets/toast_notification.dart';

class ImportFromGoogleTranslateDialog extends StatefulWidget {
  final VocabProvider vocabProvider;
  final FilePickerResult filePickerResult;

  const ImportFromGoogleTranslateDialog({
    super.key,
    required this.vocabProvider,
    required this.filePickerResult,
  });

  @override
  State<ImportFromGoogleTranslateDialog> createState() =>
      _ImportFromGoogleTranslateDialogState();
}

class _ImportFromGoogleTranslateDialogState
    extends State<ImportFromGoogleTranslateDialog> {
  List<List<dynamic>>? csvData;
  Excel? excelData;
  Map<String, String> listWordsImport = {};
  Set<String> selectedWords = {};
  bool isLoading = true;
  String? error;
  String? fileType;

  @override
  void initState() {
    super.initState();
    _loadFileContent();
  }

  Future<void> _loadFileContent() async {
    try {
      final file = widget.filePickerResult.files.first;
      fileType = file.extension?.toLowerCase();

      // Handle Excel files (.xlsx, .xls)
      if (fileType == 'xlsx' || fileType == 'xls') {
        await _loadExcelFile(file);
        return;
      }

      // Handle text files (CSV, TXT)
      String rawContent;

      // Try to read bytes first (for web)
      if (file.bytes != null) {
        try {
          rawContent = String.fromCharCodes(file.bytes!);
        } catch (e) {
          error =
              'Unable to decode file. Please ensure the file is a text-based format.';
          return;
        }
      }
      // For mobile/desktop, read from file path
      else if (file.path != null) {
        final fileHandle = File(file.path!);
        try {
          rawContent = await fileHandle.readAsString(
            encoding: Encoding.getByName('utf-8') ?? utf8,
          );
        } catch (e) {
          error = 'Unable to read file as text.\n\nError: $e';
          return;
        }
      } else {
        error = 'Unable to access file content';
        return;
      }

      // Process content based on file type
      if (fileType == 'csv') {
        try {
          csvData = const CsvToListConverter().convert(rawContent);
        } catch (e) {
          error = 'Error parsing CSV file: $e';
          return;
        }
      } else {
        // Treat as plain text
      }
    } catch (e) {
      error = 'Error reading file: $e';
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadExcelFile(PlatformFile file) async {
    try {
      Uint8List? bytes;

      // Get file bytes
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        final fileHandle = File(file.path!);
        bytes = await fileHandle.readAsBytes();
      } else {
        error = 'Unable to access Excel file';
        return;
      }

      final wordsFromUserContext = widget.vocabProvider.allWords;

      // Parse Excel file
      excelData = Excel.decodeBytes(bytes);

      if (excelData!.tables.isEmpty) {
        error = 'Excel file contains no sheets';
        return;
      }

      for (String sheetName in excelData!.tables.keys) {
        final sheet = excelData!.tables[sheetName];
        if (sheet == null) continue;

        final rows = sheet.rows;
        if (rows.isEmpty) continue;

        for (int i = 0; i < rows.length; i++) {
          final row = rows[i];
          final originalText = row.length > 2 ? row[2]?.value.toString() : '';
          final translatedText = row.length > 3 ? row[3]?.value.toString() : '';
          if (listWordsImport.containsKey(originalText) ||
              wordsFromUserContext.any((word) => word.word == originalText)) {
            continue;
          } else {
            if (originalText!.isNotEmpty && translatedText!.isNotEmpty) {
              listWordsImport[originalText] = translatedText;
              selectedWords.add(originalText);
            }
          }
        }
      }
    } catch (e) {
      error = 'Error reading Excel file: $e';
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _getCsvPreview() {
    if (csvData == null || csvData!.isEmpty) return 'No data';

    StringBuffer preview = StringBuffer();
    int rowsToShow = csvData!.length > 5 ? 5 : csvData!.length;

    for (int i = 0; i < rowsToShow; i++) {
      preview.writeln(csvData![i].join(' | '));
    }

    if (csvData!.length > 5) {
      preview.writeln('... and ${csvData!.length - 5} more rows');
    }

    return preview.toString();
  }

  Widget _buildContentDisplay() {
    if (listWordsImport.isNotEmpty) {
      return _buildWordsImportTable();
    } else if (csvData != null && csvData!.isNotEmpty) {
      return SingleChildScrollView(
        child: Text(
          _getCsvPreview(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    } else {
      return const Center(child: Text('No content available'));
    }
  }

  Future<void> _importSelectedWords() async {
    if (!mounted) return;
    
    final currentContext = context;
    final authProvider = Provider.of<AuthProvider>(currentContext, listen: false);
    
    try {
      // Show loading dialog
      showDialog(
        context: currentContext,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Analyzing and importing words...'),
            ],
          ),
        ),
      );

      final aiService = AIService();
      
      // Get selected words
      final selectedWordsData = Map.fromEntries(
        listWordsImport.entries
            .where((entry) => selectedWords.contains(entry.key))
      );

      // Analyze words using AI service
      final analysis = await aiService.analyzeCSVData(
        csvData: selectedWordsData,
        userId: authProvider.appUser?.id ?? '',
        onProgress: (current, total) {
          // Progress callback - could be used to update UI in the future
        },
      );

      // Add words to vocabulary provider
      final userId = authProvider.appUser?.id ?? '';
      final now = DateTime.now();
      
      for (final wordAnalysis in analysis.words) {
        if (wordAnalysis.isAnalysisSuccessful) {
          final vocabWord = VocabWord(
            id: GuidGenerator.generateGuid(),
            userId: userId,
            word: wordAnalysis.fixedWord ?? wordAnalysis.originalWord,
            definition: wordAnalysis.definition,
            definitionInUserLanguage: wordAnalysis.translation,
            pronunciation: wordAnalysis.pronunciation.isNotEmpty ? wordAnalysis.pronunciation : null,
            examples: wordAnalysis.examples,
            synonyms: wordAnalysis.synonyms,
            antonyms: wordAnalysis.antonyms,
            tags: wordAnalysis.tags,
            difficulty: wordAnalysis.difficulty,
            partOfSpeech: wordAnalysis.partOfSpeech,
            state: WordState.newWordState,
            repetitionLevel: 0,
            due: now,
            createdAt: now,
            updatedAt: now,
          );
          
          await widget.vocabProvider.addWord(vocabWord);
        }
      }

      // Close loading dialog
      if (mounted) Navigator.of(currentContext).pop();
      
      // Close import dialog
      if (mounted) Navigator.of(currentContext).pop();

      // Show success message
      if (mounted) {
        analysis.failedAnalyses > 0 
          ? ToastNotification.showWarning(
              currentContext,
              message:
                  'Successfully imported ${analysis.successfulAnalyses} words! ${analysis.failedAnalyses} words failed to import.',
            )
          : ToastNotification.showSuccess(
              currentContext,
              message:
                  'Successfully imported ${analysis.successfulAnalyses} words!',
            );
      }

    } catch (e) {
      if (mounted) Navigator.of(currentContext).pop();
      if (mounted) {
        ToastNotification.showError(
          currentContext,
          message: 'Failed to import words: $e',
        );
      }
    }
  }

  Widget _buildWordsImportTable() {
    final entries = listWordsImport.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Found ${entries.length} words to import (${selectedWords.length} selected)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Header row
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Checkbox(
                  tristate: true,
                  value: selectedWords.isEmpty
                      ? false
                      : selectedWords.length == entries.length
                      ? true
                      : null,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedWords.addAll(listWordsImport.keys);
                      } else {
                        selectedWords.clear();
                      }
                    });
                  },
                ),
              ),
              const Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Original Text',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Translation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Virtualized list
        Expanded(
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isSelected = selectedWords.contains(entry.key);

              return Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : null,
                  border: Border(
                    left: BorderSide(color: Theme.of(context).dividerColor),
                    right: BorderSide(color: Theme.of(context).dividerColor),
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedWords.remove(entry.key);
                      } else {
                        selectedWords.add(entry.key);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedWords.add(entry.key);
                              } else {
                                selectedWords.remove(entry.key);
                              }
                            });
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            entry.key,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            entry.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Import Vocabulary File${fileType != null ? ' (${fileType!.toUpperCase()})' : ''}',
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 600,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Text('Error: $error')
            : _buildContentDisplay(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        if (!isLoading && error == null)
          ElevatedButton(
            onPressed: selectedWords.isEmpty
                ? null
                : () => _importSelectedWords(),
            child: Text('Import (${selectedWords.length})'),
          ),
      ],
    );
  }
}
