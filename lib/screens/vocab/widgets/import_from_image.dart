import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../../providers/vocab_provider.dart';
import '../../../models/vocab_word.dart';
import '../../../widgets/toast_notification.dart';

class ImportFromImage extends StatefulWidget {
  final VocabProvider vocabProvider;
  final String deckId;

  const ImportFromImage({super.key, required this.vocabProvider, required this.deckId});

  @override
  State<ImportFromImage> createState() {
    return _ImportFromImageState();
  }
}

class _ImportFromImageState extends State<ImportFromImage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();
  TextRecognizer? _textRecognizer;

  File? _selectedImage;
  List<String> _extractedWords = [];
  Set<String> _selectedWords = {};
  bool _isProcessing = false;
  bool _isImporting = false;
  String? _errorMessage;
  bool _showManualInput = false;

  // Check if text recognition is supported on current platform
  bool get _isTextRecognitionSupported {
    // Google ML Kit Text Recognition is not supported on Windows/Linux desktop
    if (kIsWeb) return false;
    if (Platform.isWindows || Platform.isLinux) return false;
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  @override
  void initState() {
    super.initState();
    // Only initialize text recognizer on supported platforms
    if (_isTextRecognitionSupported) {
      _textRecognizer = TextRecognizer();
    }
  }

  @override
  void dispose() {
    _textRecognizer?.close();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Platform support warning
                  if (!_isTextRecognitionSupported) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Text recognition from images is not supported on this platform.',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can manually enter text instead by using the "Enter Text Manually" option below.',
                            style: TextStyle(color: Colors.orange.shade600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_selectedImage == null && !_showManualInput) ...[
                    const Text('Select an image to extract vocabulary words:'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (_isProcessing || !_isTextRecognitionSupported)
                                ? null
                                : () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (_isProcessing || !_isTextRecognitionSupported)
                                ? null
                                : () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('From Gallery'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Or'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _showManualTextInput,
                        icon: const Icon(Icons.text_fields),
                        label: const Text('Enter Text Manually'),
                      ),
                    ),
                  ] else if (_showManualInput) ...[
                    const Text('Enter or paste text to extract vocabulary words:'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText: 'Paste or type text here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _processManualText,
                          icon: const Icon(Icons.text_format),
                          label: const Text('Extract Words'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _isProcessing ? null : _hideManualTextInput,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Image preview
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isProcessing) ...[
                      const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('Processing image...'),
                          ],
                        ),
                      ),
                    ] else if (_extractedWords.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Found ${_extractedWords.length} words:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: _selectAllWords,
                                child: const Text('Select All'),
                              ),
                              TextButton(
                                onPressed: _clearSelection,
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _extractedWords.map((word) {
                              final isSelected = _selectedWords.contains(word);
                              return FilterChip(
                                label: Text(word),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedWords.add(word);
                                    } else {
                                      _selectedWords.remove(word);
                                    }
                                  });
                                },
                                selectedColor: Colors.blue.shade100,
                                checkmarkColor: Colors.blue.shade700,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_selectedWords.length} words selected',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ] else if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade600),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_selectedImage != null || _showManualInput) ...[
                  TextButton(
                    onPressed: _isProcessing || _isImporting
                        ? null
                        : _resetImage,
                    child: Text(_selectedImage != null ? 'Change Image' : 'Clear Text'),
                  ),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                TextButton(
                  onPressed: _isProcessing || _isImporting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                if (_selectedWords.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isImporting ? null : _importSelectedWords,
                    child: _isImporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Import ${_selectedWords.length} Words'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Handle permissions - skip on Windows/Desktop platforms
      if (Platform.isAndroid || Platform.isIOS) {
        if (source == ImageSource.camera) {
          final cameraStatus = await Permission.camera.request();
          if (!cameraStatus.isGranted) {
            _showError('Camera permission is required to take photos');
            return;
          }
        } else {
          // Handle different platforms for gallery access
          Permission permission;
          if (Platform.isAndroid) {
            // For Android 13+ (API 33+), use more specific permissions
            permission = Permission.photos;
          } else if (Platform.isIOS) {
            permission = Permission.photos;
          } else {
            permission = Permission.storage;
          }

          final storageStatus = await permission.request();
          if (!storageStatus.isGranted) {
            _showError('Storage permission is required to access gallery');
            return;
          }
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _extractedWords = [];
          _selectedWords = {};
          _errorMessage = null;
        });
        await _processImage();
      } else {}
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) {
      return;
    }

    // Check platform support
    if (!_isTextRecognitionSupported) {
      _showError(
        'Text recognition is not supported on this platform. '
        'This feature is available on Android, iOS, and macOS only.',
      );
      return;
    }

    if (_textRecognizer == null) {
      _showError('Text recognizer is not initialized.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final inputImage = InputImage.fromFile(_selectedImage!);
      final recognizedText = await _textRecognizer!.processImage(inputImage);
      final words = _extractWordsFromText(recognizedText.text);

      setState(() {
        _extractedWords = words;
        _isProcessing = false;
      });

      if (words.isEmpty) {
        _showError(
          'No words found in the image. Please try with a clearer image.',
        );
      }
    } catch (e) {
      debugPrint('Error in _processImage: $e');
      setState(() {
        _isProcessing = false;
      });
      _showError('Failed to process image: $e');
    }
  }

  List<String> _extractWordsFromText(String text) {
    // Common words to filter out (articles, prepositions, etc.)
    final commonWords = {
      'the',
      'a',
      'an',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by',
      'from',
      'up',
      'about',
      'into',
      'through',
      'during',
      'before',
      'after',
      'above',
      'below',
      'between',
      'among',
      'this',
      'that',
      'these',
      'those',
      'i',
      'you',
      'he',
      'she',
      'it',
      'we',
      'they',
      'me',
      'him',
      'her',
      'us',
      'them',
      'my',
      'your',
      'his',
      'its',
      'our',
      'their',
      'is',
      'am',
      'are',
      'was',
      'were',
      'be',
      'been',
      'being',
      'have',
      'has',
      'had',
      'do',
      'does',
      'did',
      'will',
      'would',
      'could',
      'should',
      'may',
      'might',
      'must',
      'can',
      'shall',
    };

    // Split text into words and clean them
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .split(RegExp(r'\s+')) // Split by whitespace
        .where((word) => word.length > 2) // Filter out short words
        .where(
          (word) => word.length < 20,
        ) // Filter out very long words (likely errors)
        .where((word) => RegExp(r'^[a-zA-Z]+$').hasMatch(word)) // Only letters
        .where((word) => !commonWords.contains(word)) // Filter out common words
        .where(
          (word) => !RegExp(r'^(.)\1+$').hasMatch(word),
        ) // Filter out repeated characters (like "aaa")
        .toSet() // Remove duplicates
        .toList();

    // Sort alphabetically
    words.sort();
    return words;
  }

  void _selectAllWords() {
    setState(() {
      _selectedWords = Set.from(_extractedWords);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedWords.clear();
    });
  }

  void _resetImage() {
    setState(() {
      _selectedImage = null;
      _showManualInput = false;
      _textController.clear();
      _extractedWords = [];
      _selectedWords = {};
      _errorMessage = null;
    });
  }

  Future<void> _importSelectedWords() async {
    if (_selectedWords.isEmpty) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final uuid = Uuid();
      final now = DateTime.now();
      int successCount = 0;
      int failCount = 0;

      for (final word in _selectedWords) {
        try {
          final vocabWord = VocabWord(
            id: uuid.v4(),
            deckId: widget.deckId,
            word: word,
            definition: '', // Will be filled by user later
            difficulty: 'beginner',
            partOfSpeech: 'unknown',
            repetitionLevel: 0,
            due: now,
            createdAt: now,
            updatedAt: now,
          );

          final success = await widget.vocabProvider.addWord(vocabWord);
          if (success) {
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          failCount++;
          debugPrint('Failed to add word "$word": $e');
        }
      }

      setState(() {
        _isImporting = false;
      });

      if (mounted) {
        if (successCount > 0) {
          ToastNotification.showSuccess(
            context,
            message:
                'Successfully imported $successCount words${failCount > 0 ? ' ($failCount failed)' : ''}',
          );
        } else {
          ToastNotification.showError(
            context,
            message: 'Failed to import words. Please try again.',
          );
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
      });
      _showError('Failed to import words: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });

    if (mounted) {
      ToastNotification.showError(context, message: message);
    }
  }

  void _showManualTextInput() {
    setState(() {
      _showManualInput = true;
      _selectedImage = null;
      _extractedWords = [];
      _selectedWords = {};
      _errorMessage = null;
    });
  }

  void _hideManualTextInput() {
    setState(() {
      _showManualInput = false;
      _textController.clear();
      _extractedWords = [];
      _selectedWords = {};
      _errorMessage = null;
    });
  }

  void _processManualText() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showError('Please enter some text to extract words.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    // Simulate processing delay for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      final words = _extractWordsFromText(text);
      
      setState(() {
        _extractedWords = words;
        _isProcessing = false;
      });

      if (words.isEmpty) {
        _showError('No words found in the text.');
      }
    });
  }
}
