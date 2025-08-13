import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocab_learner/widgets/toast_notification.dart';
import 'package:vocab_learner/widgets/blur_dialog.dart';
import '../../../providers/vocab_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/vocab_word.dart';
import '../../../services/ai_service.dart';
import '../../../utils/guid_generator.dart';

class AddWordDialog extends StatefulWidget {
  final VocabProvider vocabProvider;

  const AddWordDialog({super.key, required this.vocabProvider});

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final wordController = TextEditingController();
  final definitionController = TextEditingController();
  final pronunciationController = TextEditingController();
  final exampleController = TextEditingController();
  final nativeDefinitionController = TextEditingController();
  final synonymsController = TextEditingController();
  final antonymsController = TextEditingController();
  final tagsController = TextEditingController();
  String selectedDifficulty = 'beginner';
  String selectedPartOfSpeech = 'noun';
  String? errorText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AlertDialog(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline, size: 24),
            SizedBox(width: 8),
            Text('Add New Word'),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWordInput(),
            const SizedBox(height: 12),
            _buildPropertiesHeader(),
            const SizedBox(height: 12),
            _buildDefinitionInput(),
            const SizedBox(height: 12),
            _buildNativeDefinitionInput(),
            const SizedBox(height: 12),
            _buildPronunciationInput(),
            const SizedBox(height: 12),
            _buildExampleInput(),
            const SizedBox(height: 12),
            _buildSynonymsInput(),
            const SizedBox(height: 12),
            _buildAntonymsInput(),
            const SizedBox(height: 12),
            _buildTagsInput(),
            const SizedBox(height: 12),
            _buildDifficultyDropdown(),
            const SizedBox(height: 12),
            _buildPartOfSpeechDropdown(),
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
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _handleAddWord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.9),
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                ),
                child: const Text('Add Word'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWordInput() {
    return Row(
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
                errorText = null;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertiesHeader() {
    return Row(
      children: [
        Text('Properties', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Info',
          onPressed: _showPropertiesInfo,
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: _analyzeWordWithAI,
          icon: const Icon(Icons.auto_awesome, size: 18),
          label: const Text('AI Generate'),
          style: TextButton.styleFrom(foregroundColor: Colors.purple),
        ),
      ],
    );
  }

  Widget _buildDefinitionInput() {
    return TextField(
      controller: definitionController,
      decoration: const InputDecoration(
        labelText: 'Definition *',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildNativeDefinitionInput() {
    return TextField(
      controller: nativeDefinitionController,
      decoration: const InputDecoration(
        labelText: 'Native language definition (optional)',
        border: OutlineInputBorder(),
        hintText: 'Enter a definition or use AI to generate...',
      ),
      maxLines: 2,
    );
  }

  Widget _buildPronunciationInput() {
    return TextField(
      controller: pronunciationController,
      decoration: const InputDecoration(
        labelText: 'Pronunciation (optional)',
        border: OutlineInputBorder(),
        hintText: '/prəˌnʌnsiˈeɪʃən/',
      ),
    );
  }

  Widget _buildExampleInput() {
    return TextField(
      controller: exampleController,
      decoration: const InputDecoration(
        labelText: 'Example Sentence (optional)',
        border: OutlineInputBorder(),
        hintText: 'Enter an example or use AI to generate...',
      ),
      maxLines: 3,
    );
  }

  Widget _buildSynonymsInput() {
    return TextField(
      controller: synonymsController,
      decoration: const InputDecoration(
        labelText: 'Synonyms (optional)',
        border: OutlineInputBorder(),
        hintText: 'Enter synonyms separated by commas...',
      ),
      maxLines: 2,
    );
  }

  Widget _buildAntonymsInput() {
    return TextField(
      controller: antonymsController,
      decoration: const InputDecoration(
        labelText: 'Antonyms (optional)',
        border: OutlineInputBorder(),
        hintText: 'Enter antonyms separated by commas...',
      ),
      maxLines: 2,
    );
  }

  Widget _buildTagsInput() {
    return TextField(
      controller: tagsController,
      decoration: const InputDecoration(
        labelText: 'Tags (optional)',
        border: OutlineInputBorder(),
        hintText: 'Enter tags separated by commas...',
      ),
      maxLines: 2,
    );
  }

  Widget _buildDifficultyDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedDifficulty,
      decoration: const InputDecoration(
        labelText: 'Difficulty',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
        DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
        DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedDifficulty = value;
          });
        }
      },
    );
  }

  Widget _buildPartOfSpeechDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedPartOfSpeech,
      decoration: const InputDecoration(
        labelText: 'Part of Speech',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'noun', child: Text('Noun')),
        DropdownMenuItem(value: 'verb', child: Text('Verb')),
        DropdownMenuItem(value: 'adjective', child: Text('Adjective')),
        DropdownMenuItem(value: 'adverb', child: Text('Adverb')),
        DropdownMenuItem(value: 'preposition', child: Text('Preposition')),
        DropdownMenuItem(value: 'conjunction', child: Text('Conjunction')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedPartOfSpeech = value;
          });
        }
      },
    );
  }

  void _showPropertiesInfo() {
    showBlurDialog(
      context: context,
      blurStrength: 6.0,
      builder: (dialogContext) => AlertDialog(
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
  }

  void _analyzeWordWithAI() async {
    if (wordController.text.trim().isEmpty) {
      setState(() {
        errorText = 'Please enter a word first';
      });
      return;
    }

    _showAILoadingDialog();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final aiService = AIService();

      final analysis = await aiService.analyzeWord(
        word: wordController.text.trim(),
        userId: authProvider.appUser?.id ?? '',
      );

      if (mounted) Navigator.of(context).pop(); // Close loading dialog

      if (mounted) {
        _fillFormWithAIData(analysis);
        _showAISuccessDialog();
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Close loading dialog
      if (mounted) _showAIErrorDialog(e.toString());
    }
  }

  void _showAILoadingDialog() {
    showBlurDialog(
      context: context,
      barrierDismissible: false,
      blurStrength: 8.0,
      builder: (dialogContext) => AlertDialog(
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
  }

  void _fillFormWithAIData(dynamic analysis) {
    setState(() {
      definitionController.text = analysis.definition;
      nativeDefinitionController.text = analysis.definitionInUserLanguage ?? '';
      pronunciationController.text = analysis.pronunciation;
      exampleController.text = analysis.examples.join('\n');
      synonymsController.text = analysis.synonyms.join(', ');
      if (analysis.fixedWord != null) {
        wordController.text = analysis.fixedWord!;
      }
      selectedDifficulty = analysis.difficulty;
      selectedPartOfSpeech = analysis.partOfSpeech;
    });
  }

  void _showAISuccessDialog() {
    showBlurDialog(
      context: context,
      blurStrength: 6.0,
      builder: (dialogContext) => AlertDialog(
        title: const Text('AI Analysis Complete'),
        content: Text(
          'Generated definition, examples, and synonyms for "${wordController.text}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAIErrorDialog(String error) {
    showBlurDialog(
      context: context,
      blurStrength: 6.0,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Error'),
        content: Text('Error analyzing word: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleAddWord() async {
    if (wordController.text.trim().isEmpty ||
        definitionController.text.trim().isEmpty) {
      setState(() {
        errorText = 'Please fill in word and definition fields';
      });
      return;
    }

    final now = DateTime.now();
    final newWord = VocabWord(
      userId: widget.vocabProvider.currentUserId ?? '',
      id: GuidGenerator.generateGuid(),
      word: wordController.text.trim(),
      definition: definitionController.text.trim(),
      pronunciation: pronunciationController.text.trim().isEmpty
          ? null
          : pronunciationController.text.trim(),
      definitionInUserLanguage: nativeDefinitionController.text.trim().isEmpty
          ? null
          : nativeDefinitionController.text.trim(),
      examples: exampleController.text.trim().isEmpty
          ? []
          : [exampleController.text.trim()],
      difficulty: selectedDifficulty,
      partOfSpeech: selectedPartOfSpeech,
      state: WordState.newWordState,
      repetitionLevel: 0,
      due: now.add(const Duration(days: 1)),
      createdAt: now,
      updatedAt: now,
      synonyms: synonymsController.text.trim().isEmpty
          ? []
          : synonymsController.text.split(',').map((s) => s.trim()).toList(),
      antonyms: antonymsController.text.trim().isEmpty
          ? []
          : antonymsController.text.split(',').map((s) => s.trim()).toList(),
      tags: tagsController.text.trim().isEmpty
          ? []
          : tagsController.text.split(',').map((s) => s.trim()).toList(),
    );

    _showAddingWordDialog();

    try {
      final success = await widget.vocabProvider.addWord(newWord);

      if (mounted) Navigator.of(context).pop(); // Close loading dialog

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(); // Close add word dialog
          ToastNotification.showSuccess(
            context,
            message: 'Word "${wordController.text}" added successfully!',
          );
        }
      } else {
        if (mounted) {
          ToastNotification.showError(
            context,
            message: 'Failed to add word. ${widget.vocabProvider.errorMessage ?? "Unknown error"}',
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Close loading dialog
      if (mounted) {
        ToastNotification.showError(
          context,
          message: 'Error adding word: $e',
        );
      }
    }
  }

  void _showAddingWordDialog() {
    showBlurDialog(
      context: context,
      blurStrength: 6.0,
      builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    wordController.dispose();
    definitionController.dispose();
    pronunciationController.dispose();
    exampleController.dispose();
    nativeDefinitionController.dispose();
    synonymsController.dispose();
    antonymsController.dispose();
    tagsController.dispose();
    super.dispose();
  }
}
