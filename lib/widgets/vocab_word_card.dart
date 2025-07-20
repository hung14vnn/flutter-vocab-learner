import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/vocab_word.dart';
import 'difficulty_chip.dart';
import 'state_chip.dart';

class VocabWordCard extends StatelessWidget {
  final VocabWord word;

  const VocabWordCard({required this.word, super.key});

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
                  DifficultyChip(difficulty: word.difficulty),
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
                  StateChip(state: word.state),
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
    if (word.word.isEmpty) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.volume_up, size: 20),
      tooltip: 'Play pronunciation',
      onPressed: () async {
        final wordText = word.word;
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
