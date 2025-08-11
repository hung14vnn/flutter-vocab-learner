import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../models/vocab_word.dart';
import '../../../widgets/difficulty_chip.dart';
import 'state_chip.dart';

class VocabWordCard extends StatefulWidget {
  final VocabWord word;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onSelectionToggle;
  final VoidCallback? onLongPress;

  const VocabWordCard({
    required this.word,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionToggle,
    this.onLongPress,
    super.key,
  });

  @override
  State<VocabWordCard> createState() => _VocabWordCardState();
}

class _VocabWordCardState extends State<VocabWordCard> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: widget.isSelected ? 4.0 : 1.0,
      color: widget.isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.3) : null,
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
                  _buildPronunciationButton(context, widget.word.pronunciation),
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
  ) {
    if (widget.word.word.isEmpty) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.volume_up, size: 20),
      tooltip: 'Play pronunciation',
      onPressed: () async {
        final wordText = widget.word.word;
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to play audio: $e')));
        }
      },
    );
  }

  void _showWordDetails(BuildContext context, VocabWord word) {
    showDialog(
      context: context,
      builder: (context) => WordDetailsDialog(word: word),
    );
  }
}

class WordDetailsDialog extends StatefulWidget {
  final VocabWord word;

  const WordDetailsDialog({required this.word, super.key});

  @override
  State<WordDetailsDialog> createState() => _WordDetailsDialogState();
}

class _WordDetailsDialogState extends State<WordDetailsDialog> {
  bool _isUserDefinitionRevealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 16,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
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
                    // Part of Speech
                    _buildPartOfSpeech(theme),
                    
                    const SizedBox(height: 20),
                    
                    // Definition
                    _buildDefinitionSection(theme),
                    
                    // Pronunciation
                    if (widget.word.pronunciation != null) ...[
                      const SizedBox(height: 20),
                      _buildPronunciationSection(theme),
                    ],
                    
                    // Examples
                    if (widget.word.examples.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildExamplesSection(theme),
                    ],
                    
                    // Synonyms
                    if (widget.word.synonyms.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSynonymsSection(theme),
                    ],
                    
                    // Antonyms
                    if (widget.word.antonyms.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildAntonymsSection(theme),
                    ],
                    
                    // Tags
                    if (widget.word.tags.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildTagsSection(theme),
                    ],
                    
                    // User Language Definition
                    if (widget.word.definitionInUserLanguage != null) ...[
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
            theme.colorScheme.primaryContainer.withOpacity(0.7),
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
                  widget.word.word,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    DifficultyChip(difficulty: widget.word.difficulty),
                    const SizedBox(width: 8),
                    StateChip(state: widget.word.state),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildPronunciationButton(context, widget.word.pronunciation),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartOfSpeech(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.word.partOfSpeech,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
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
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Text(
            widget.word.definition,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
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
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Text(
            widget.word.pronunciation!,
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
        ...widget.word.examples.map((example) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.tertiary.withOpacity(0.2),
            ),
          ),
          child: Text(
            '"$example"',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        )),
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
          children: widget.word.synonyms.map((synonym) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Text(
              synonym,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
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
            Icon(
              Icons.swap_horiz,
              size: 18,
              color: theme.colorScheme.primary,
            ),
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
          children: widget.word.antonyms.map((antonym) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
              ),
            ),
            child: Text(
              antonym,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
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
            Icon(
              Icons.local_offer,
              size: 18,
              color: theme.colorScheme.primary,
            ),
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
          children: widget.word.tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Text(
              tag,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildPronunciationButton(
    BuildContext context,
    String? pronunciation,
  ) {
    if (widget.word.word.isEmpty) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.volume_up, size: 20),
      tooltip: 'Play pronunciation',
      onPressed: () async {
        final wordText = widget.word.word;
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to play audio: $e')));
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
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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

  Widget _buildDialogRevealDefinition(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.translate,
              size: 18,
              color: theme.colorScheme.primary,
            ),
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
                ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                : theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isUserDefinitionRevealed
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : theme.colorScheme.outline.withOpacity(0.3),
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
                        Row(
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Definition in your language:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.word.definitionInUserLanguage!,
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
