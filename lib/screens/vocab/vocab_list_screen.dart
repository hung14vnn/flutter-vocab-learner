// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_learner/utils/guid_generator.dart';
import '../../providers/vocab_provider.dart';
import '../../models/vocab_word.dart';
import '../../services/ai_service.dart';

class VocabListScreen extends StatefulWidget {
  const VocabListScreen({super.key});

  @override
  State<VocabListScreen> createState() => _VocabListScreenState();
}

class _VocabListScreenState extends State<VocabListScreen> {
  void _showAddWordOptions(BuildContext context, VocabProvider vocabProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Words'),
          content: const Text(
            'How would you like to add new vocabulary words?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleImportWords(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.file_upload, size: 20),
                  const SizedBox(width: 8),
                  const Text('Import'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleManualAdd(context, vocabProvider);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 20),
                  const SizedBox(width: 8),
                  const Text('Manual Add'),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _handleImportWords(BuildContext context) {
    // TODO: Implement word import functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV import coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('From Preset Lists'),
              subtitle: const Text('Choose from curated vocabulary lists'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preset lists coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('From URL'),
              subtitle: const Text('Import from online vocabulary list'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL import coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleManualAdd(BuildContext context, VocabProvider vocabProvider) {
    // TODO: Navigate to manual add screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Navigator.of(context).pop();
                _showAddSingleWordForm(context, vocabProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Quick Add Multiple'),
              subtitle: const Text('Add multiple words quickly'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quick add coming soon!')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddSingleWordForm(
    BuildContext context,
    VocabProvider vocabProvider,
  ) {
    final wordController = TextEditingController();
    final definitionController = TextEditingController();
    final pronunciationController = TextEditingController();
    final exampleController = TextEditingController();
    final synonymsController = TextEditingController();
    String selectedDifficulty = 'beginner';
    String selectedPartOfSpeech = 'noun';

    String? errorText;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Word'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Word input with AI analysis button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: wordController,
                        decoration: const InputDecoration(
                          labelText: 'Word *',
                          border: OutlineInputBorder(),
                          hintText: 'Enter word for AI analysis...',
                        ),
                        onChanged: (value) {
                          setState(() {
                            errorText =
                                null; // Clear error message when input changes
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Properties',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Info',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Properties Info'),
                            content: const Text(
                              'You can fill these fields manually or use the AI Generate button to auto-generate all properties for your word.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        if (wordController.text.trim().isEmpty) {
                          setState(() {
                            errorText = 'Please enter a word first';
                          });
                          return;
                        }
                        await _analyzeWordWithAI(
                          wordController.text.trim(),
                          selectedPartOfSpeech,
                          definitionController,
                          pronunciationController,
                          exampleController,
                          synonymsController,
                          (difficulty) {
                            setState(() {
                              selectedDifficulty = difficulty;
                            });
                          },
                        );
                      },
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('AI Generate'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: definitionController,
                  decoration: const InputDecoration(
                    labelText: 'Definition *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pronunciationController,
                  decoration: const InputDecoration(
                    labelText: 'Pronunciation (optional)',
                    border: OutlineInputBorder(),
                    hintText: '/prəˌnʌnsiˈeɪʃən/',
                  ),
                ),
                const SizedBox(height: 12),
                // AI-Enhanced Example Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TextField(
                      controller: exampleController,
                      decoration: const InputDecoration(
                        labelText: 'Example Sentence (optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Enter an example or use AI to generate...',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Synonyms field
                TextField(
                  controller: synonymsController,
                  decoration: const InputDecoration(
                    labelText: 'Synonyms (optional)',
                    border: OutlineInputBorder(),
                    hintText: 'Enter synonyms separated by commas...',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'beginner',
                      child: Text('Beginner'),
                    ),
                    DropdownMenuItem(
                      value: 'intermediate',
                      child: Text('Intermediate'),
                    ),
                    DropdownMenuItem(
                      value: 'advanced',
                      child: Text('Advanced'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedDifficulty = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedPartOfSpeech,
                  decoration: const InputDecoration(
                    labelText: 'Part of Speech',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'noun', child: Text('Noun')),
                    DropdownMenuItem(value: 'verb', child: Text('Verb')),
                    DropdownMenuItem(
                      value: 'adjective',
                      child: Text('Adjective'),
                    ),
                    DropdownMenuItem(value: 'adverb', child: Text('Adverb')),
                    DropdownMenuItem(
                      value: 'preposition',
                      child: Text('Preposition'),
                    ),
                    DropdownMenuItem(
                      value: 'conjunction',
                      child: Text('Conjunction'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedPartOfSpeech = value;
                      });
                    }
                  },
                ),
                if (errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              // Mark the function as async to fix the await issue
              onPressed: () async {
                if (wordController.text.trim().isNotEmpty &&
                    definitionController.text.trim().isNotEmpty) {
                  final now = DateTime.now();
                  final newWord = VocabWord(
                    userId: vocabProvider.currentUserId ?? '', // Added userId
                    id: GuidGenerator.generateGuid(),
                    word: wordController.text.trim(),
                    definition: definitionController.text.trim(),
                    pronunciation: pronunciationController.text.trim().isEmpty
                        ? null
                        : pronunciationController.text.trim(),
                    examples: exampleController.text.trim().isEmpty
                        ? []
                        : [exampleController.text.trim()],
                    difficulty: selectedDifficulty,
                    partOfSpeech: selectedPartOfSpeech,
                    state: WordState.newWordState,
                    due: now.add(const Duration(days: 1)), // Due tomorrow
                    createdAt: now,
                    updatedAt: now,
                  );

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final success = await vocabProvider.addWord(newWord);

                    // Close loading dialog
                    Navigator.of(context).pop();

                    if (success) {
                      Navigator.of(context).pop(); // Close add word dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Word "${wordController.text}" added successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to add word. ${vocabProvider.errorMessage ?? "Unknown error"}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    // Close loading dialog
                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding word: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  setState(() {
                    errorText = 'Please fill in word and definition fields';
                  });
                }
              },
              child: const Text('Add Word'),
            ),
          ],
        ),
      ),
    );
  }

  /// Analyzes a word using AI and fills in all the form fields
  Future<void> _analyzeWordWithAI(
    String word,
    String partOfSpeech,
    TextEditingController definitionController,
    TextEditingController pronunciationController,
    TextEditingController exampleController,
    TextEditingController synonymsController,
    Function(String) onDifficultyChanged,
  ) async {
    if (word.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a word first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show comprehensive loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('🤖 Analyzing word with AI...'),
            SizedBox(height: 8),
            Text(
              'Generating definition, examples, synonyms, and more!',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      final analysis = await AIService.analyzeWord(
        word: word,
        partOfSpeech: partOfSpeech,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        // Fill in all the form fields with AI-generated data
        definitionController.text = analysis.definition;
        pronunciationController.text = analysis.pronunciation;
        exampleController.text = analysis.examples.join('\n');
        synonymsController.text = analysis.synonyms.join(', ');
        onDifficultyChanged(analysis.difficulty);

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('AI Analysis Complete'),
            content: Text(
              'Generated definition, examples, and synonyms for "$word"',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Error analyzing word: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        actions: [
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading vocabulary',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vocabProvider.errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement retry functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Retry coming soon!')),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (vocabProvider.allWords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No vocabulary words yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Words will appear here once you add them',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filter section
              Container(
                padding: const EdgeInsets.all(16.0),
                color: theme.colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: vocabProvider.selectedDifficulty,
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(
                            value: 'beginner',
                            child: Text('Beginner'),
                          ),
                          DropdownMenuItem(
                            value: 'intermediate',
                            child: Text('Intermediate'),
                          ),
                          DropdownMenuItem(
                            value: 'advanced',
                            child: Text('Advanced'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            vocabProvider.setDifficultyFilter(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: vocabProvider.selectedPartOfSpeech,
                        decoration: const InputDecoration(
                          labelText: 'Part of Speech',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All')),
                          DropdownMenuItem(value: 'noun', child: Text('Noun')),
                          DropdownMenuItem(value: 'verb', child: Text('Verb')),
                          DropdownMenuItem(
                            value: 'adjective',
                            child: Text('Adjective'),
                          ),
                          DropdownMenuItem(
                            value: 'adverb',
                            child: Text('Adverb'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            vocabProvider.setPartOfSpeechFilter(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Word count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Text(
                      '${vocabProvider.filteredWords.length} words',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Words list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: vocabProvider.filteredWords.length,
                  itemBuilder: (context, index) {
                    final word = vocabProvider.filteredWords[index];
                    return _VocabWordCard(word: word);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<VocabProvider>(
        builder: (context, vocabProvider, child) {
          return FloatingActionButton(
            onPressed: () {
              _showAddWordOptions(context, vocabProvider);
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class _VocabWordCard extends StatelessWidget {
  final VocabWord word;

  const _VocabWordCard({required this.word});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showWordDetails(context, word);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      word.word,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _DifficultyChip(difficulty: word.difficulty),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                word.partOfSpeech,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                word.definition,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (word.examples.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildExampleText(word.examples.first, theme),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _StateChip(state: word.state),
                  const Spacer(),
                  _buildPronunciationButton(context, word.pronunciation),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Extracted method to build the example text widget
  Widget _buildExampleText(String example, ThemeData theme) {
    return Text(
      '"$example"',
      style: theme.textTheme.bodySmall?.copyWith(
        fontStyle: FontStyle.italic,
        color: Colors.grey.shade600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Extracted method to build the pronunciation button
  Widget _buildPronunciationButton(
    BuildContext context,
    String? pronunciation,
  ) {
    if (pronunciation == null) return const SizedBox.shrink();

    return IconButton(
      icon: const Icon(Icons.volume_up, size: 20),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio playback coming soon!')),
        );
      },
    );
  }

  void _showWordDetails(BuildContext context, VocabWord word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(word.word),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Part of Speech: ${word.partOfSpeech}'),
              const SizedBox(height: 8),
              Text('Definition: ${word.definition}'),
              if (word.pronunciation != null) ...[
                const SizedBox(height: 8),
                Text('Pronunciation: ${word.pronunciation}'),
              ],
              if (word.examples.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Examples:'),
                ...word.examples.map(
                  (example) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Text('• $example'),
                  ),
                ),
              ],
              if (word.synonyms.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Synonyms: ${word.synonyms.join(', ')}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;

  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        color = Colors.green;
        break;
      case 'intermediate':
        color = Colors.orange;
        break;
      case 'advanced':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        difficulty.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _StateChip extends StatelessWidget {
  final WordState state;

  const _StateChip({required this.state});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    if (state == WordState.newWordState) {
      color = Colors.blue;
      text = 'NEW';
    } else if (state == WordState.learningState) {
      color = Colors.orange;
      text = 'LEARNING';
    } else if (state == WordState.masteredState) {
      color = Colors.green;
      text = 'MASTERED';
    } else {
      color = Colors.grey;
      text = 'UNKNOWN';
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
