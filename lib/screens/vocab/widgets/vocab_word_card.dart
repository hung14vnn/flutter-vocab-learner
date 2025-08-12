import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:vocab_learner/widgets/toast_notification.dart';
import '../../../models/vocab_word.dart';
import '../../../widgets/difficulty_chip.dart';
import 'state_chip.dart';

class VocabWordCard extends StatefulWidget {
  final VocabWord word;
  final bool isSelectionMode;
  final bool isSelected;
  final bool isCompactMode;
  final VoidCallback? onSelectionToggle;
  final VoidCallback? onLongPress;
  final Function(VocabWord)? onEdit;

  const VocabWordCard({
    required this.word,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.isCompactMode = false,
    this.onSelectionToggle,
    this.onLongPress,
    this.onEdit,
    super.key,
  });

  @override
  State<VocabWordCard> createState() => _VocabWordCardState();
}

class _VocabWordCardState extends State<VocabWordCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.isCompactMode) {
      return _buildCompactCard(context, theme);
    } else {
      return _buildRegularCard(context, theme);
    }
  }

  Widget _buildRegularCard(BuildContext context, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: widget.isSelected ? 4.0 : 1.0,
      color: widget.isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (widget.isSelectionMode) {
            widget.onSelectionToggle?.call();
          } else {
            _showWordDetails(context, widget.word);
          }
        },
        onLongPress: () {
          widget.onLongPress?.call();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.isSelectionMode) ...[
                    Checkbox(
                      value: widget.isSelected,
                      onChanged: (_) => widget.onSelectionToggle?.call(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      widget.word.word,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DifficultyChip(difficulty: widget.word.difficulty),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.word.partOfSpeech,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.word.definition,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.word.examples.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildExampleText(widget.word.examples.first, theme),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  StateChip(state: widget.word.state),
                  const Spacer(),
                  _buildPronunciationButton(
                    context,
                    widget.word.pronunciation ?? '',
                    widget.word,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4.0),
      elevation: widget.isSelected ? 4.0 : 1.0,
      color: widget.isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (widget.isSelectionMode) {
            widget.onSelectionToggle?.call();
          } else {
            _showWordDetails(context, widget.word);
          }
        },
        onLongPress: () {
          widget.onLongPress?.call();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              if (widget.isSelectionMode) ...[
                Checkbox(
                  value: widget.isSelected,
                  onChanged: (_) => widget.onSelectionToggle?.call(),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.word.word,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.word.partOfSpeech,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(
                  widget.word.definition,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _buildPronunciationButton(
                    context,
                    widget.word.pronunciation ?? '',
                    widget.word,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildPronunciationButton(
    BuildContext context,
    String? pronunciation,
    VocabWord currentWord,
  ) {
    if (currentWord.word.isEmpty) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.volume_up, size: 20),
      tooltip: 'Play pronunciation',
      onPressed: () async {
        final wordText = currentWord.word;
        final url =
            'https://translate.google.com/translate_tts?ie=UTF-8&q=${wordText.trim()}&tl=en&client=tw-ob';
        try {
          final dir = await getTemporaryDirectory();
          final filePath = '${dir.path}/tts_${wordText.toLowerCase()}.mp3';
          final file = File(filePath);
          if (!await file.exists()) {
            final response = await http.get(
              Uri.parse(url),
              headers: {'User-Agent': 'Mozilla/5.0'},
            );
            if (response.statusCode == 200) {
              await file.writeAsBytes(response.bodyBytes);
            } else {
              throw Exception('Failed to fetch audio: ${response.statusCode}');
            }
          }
          final player = AudioPlayer();
          await player.play(DeviceFileSource(filePath));

          player.onPlayerComplete.listen((event) async {
            try {
              if (await file.exists()) {
                await file.delete();
              }
            } catch (_) {}
          });
        } catch (e) {
          ToastNotification.showError(
            context,
            message: 'Failed to play audio: $e',
          );
        }
      },
    );
  }

  void _showWordDetails(BuildContext context, VocabWord word) {
    showDialog(
      context: context,
      builder: (context) =>
          WordDetailsDialog(word: word, onEdit: widget.onEdit),
    );
  }
}

class WordDetailsDialog extends StatefulWidget {
  final VocabWord word;
  final Function(VocabWord)? onEdit;

  const WordDetailsDialog({required this.word, this.onEdit, super.key});

  @override
  State<WordDetailsDialog> createState() => _WordDetailsDialogState();
}

class _WordDetailsDialogState extends State<WordDetailsDialog> {
  bool _isUserDefinitionRevealed = false;
  late VocabWord currentWord;

  @override
  void initState() {
    super.initState();
    currentWord = widget.word;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 550,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            _buildHeader(theme, context),

            // Content Section
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Definition
                    _buildDefinitionSection(theme),

                    // Pronunciation
                    if (currentWord.pronunciation != null) ...[
                      const SizedBox(height: 20),
                      _buildPronunciationSection(theme),
                    ],

                    // Examples
                    if (currentWord.examples.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildExamplesSection(theme),
                    ],

                    // Synonyms
                    if (currentWord.synonyms.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSynonymsSection(theme),
                    ],

                    // Antonyms
                    if (currentWord.antonyms.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildAntonymsSection(theme),
                    ],

                    // Tags
                    if (currentWord.tags.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildTagsSection(theme),
                    ],

                    // User Language Definition
                    if (currentWord.definitionInUserLanguage != null) ...[
                      const SizedBox(height: 20),
                      _buildDialogRevealDefinition(theme),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons
            _buildActionButtons(theme, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentWord.word,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildPartOfSpeech(theme),
                    const SizedBox(width: 8),
                    DifficultyChip(difficulty: currentWord.difficulty),
                    const SizedBox(width: 8),
                    StateChip(state: currentWord.state),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildPronunciationButton(context, currentWord.pronunciation),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartOfSpeech(ThemeData theme) {
    return Chip(
      label: Text(
        currentWord.partOfSpeech.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Color.fromARGB(255, 206, 128, 38),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDefinitionSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Definition',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            currentWord.definition,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPronunciationSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.record_voice_over,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Pronunciation',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            currentWord.pronunciation!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExamplesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.format_quote,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Examples',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...currentWord.examples.map(
          (example) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              '"$example"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSynonymsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.compare_arrows,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Synonyms',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: currentWord.synonyms
              .map(
                (synonym) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    synonym,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAntonymsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.swap_horiz, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Antonyms',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: currentWord.antonyms
              .map(
                (antonym) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    antonym,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTagsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_offer, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Tags',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: currentWord.tags
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPronunciationButton(
    BuildContext context,
    String? pronunciation,
  ) {
    if (currentWord.word.isEmpty) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.volume_up, size: 20),
      tooltip: 'Play pronunciation',
      onPressed: () async {
        final wordText = currentWord.word;
        final url =
            'https://translate.google.com/translate_tts?ie=UTF-8&q=${wordText.trim()}&tl=en&client=tw-ob';
        try {
          final dir = await getTemporaryDirectory();
          final filePath = '${dir.path}/tts_${wordText.toLowerCase()}.mp3';
          final file = File(filePath);
          if (!await file.exists()) {
            final response = await http.get(
              Uri.parse(url),
              headers: {'User-Agent': 'Mozilla/5.0'},
            );
            if (response.statusCode == 200) {
              await file.writeAsBytes(response.bodyBytes);
            } else {
              throw Exception('Failed to fetch audio: ${response.statusCode}');
            }
          }
          final player = AudioPlayer();
          await player.play(DeviceFileSource(filePath));
          // Wait for playback to complete, then delete the file
          player.onPlayerComplete.listen((event) async {
            try {
              if (await file.exists()) {
                await file.delete();
              }
            } catch (_) {}
          });
        } catch (e) {
          ToastNotification.showError(
            context,
            message: 'Failed to play audio: $e',
          );
        }
      },
    );
  }

  Widget _buildActionButtons(ThemeData theme, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.onEdit != null)
            TextButton.icon(
              onPressed: () {
                _showEditDialog(context);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
              ),
            )
          else
            const SizedBox.shrink(),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) async {
    final result = await showDialog<VocabWord>(
      context: context,
      builder: (context) => EditWordDialog(
        word: currentWord,
        onSave: (updatedWord) {
          // Call the original onEdit callback
          widget.onEdit?.call(updatedWord);
          // Return the updated word to this dialog
          Navigator.of(context).pop(updatedWord);
        },
      ),
    );

    // If we got an updated word back, update our state
    if (result != null && mounted) {
      setState(() {
        currentWord = result;
      });
    }
  }

  Widget _buildDialogRevealDefinition(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.translate, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Native Language',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isUserDefinitionRevealed
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isUserDefinitionRevealed
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _isUserDefinitionRevealed = !_isUserDefinitionRevealed;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isUserDefinitionRevealed
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentWord.definitionInUserLanguage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility_off,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Tap to reveal definition in your language',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class EditWordDialog extends StatefulWidget {
  final VocabWord word;
  final Function(VocabWord)? onSave;

  const EditWordDialog({required this.word, this.onSave, super.key});

  @override
  State<EditWordDialog> createState() => _EditWordDialogState();
}

class _EditWordDialogState extends State<EditWordDialog> {
  late TextEditingController wordController;
  late TextEditingController definitionController;
  late TextEditingController pronunciationController;
  late TextEditingController exampleController;
  late TextEditingController nativeDefinitionController;
  late TextEditingController synonymsController;
  late TextEditingController antonymsController;
  late TextEditingController tagsController;
  late String selectedDifficulty;
  late String selectedPartOfSpeech;
  String? errorText;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing word data
    wordController = TextEditingController(text: widget.word.word);
    definitionController = TextEditingController(text: widget.word.definition);
    pronunciationController = TextEditingController(
      text: widget.word.pronunciation ?? '',
    );
    exampleController = TextEditingController(
      text: widget.word.examples.join('\n'),
    );
    nativeDefinitionController = TextEditingController(
      text: widget.word.definitionInUserLanguage ?? '',
    );
    synonymsController = TextEditingController(
      text: widget.word.synonyms.join(', '),
    );
    antonymsController = TextEditingController(
      text: widget.word.antonyms.join(', '),
    );
    tagsController = TextEditingController(text: widget.word.tags.join(', '));
    selectedDifficulty = widget.word.difficulty;
    selectedPartOfSpeech = widget.word.partOfSpeech;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Word'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildWordInput(),
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
      ),
      actions: [
        TextButton(
          onPressed: () => {Navigator.of(context).pop()},
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: _handleSaveWord,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildWordInput() {
    return TextField(
      controller: wordController,
      decoration: const InputDecoration(
        labelText: 'Word *',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          errorText = null;
        });
      },
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
        labelText: 'Example Sentences (optional)',
        border: OutlineInputBorder(),
        hintText: 'Enter examples separated by new lines...',
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

  void _handleSaveWord() async {
    if (wordController.text.trim().isEmpty ||
        definitionController.text.trim().isEmpty) {
      setState(() {
        errorText = 'Please fill in word and definition fields';
      });
      return;
    }

    final now = DateTime.now();
    final updatedWord = widget.word.copyWith(
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
          : exampleController.text
                .trim()
                .split('\n')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList(),
      difficulty: selectedDifficulty,
      partOfSpeech: selectedPartOfSpeech,
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

    widget.onSave?.call(updatedWord);
  }
}
