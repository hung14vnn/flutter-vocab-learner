import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/vocab_provider.dart';
import '../../../widgets/vocab_word_card.dart';

class VocabWordsList extends StatelessWidget {
  const VocabWordsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabProvider>(
      builder: (context, vocabProvider, child) {
        return Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: vocabProvider.filteredWords.length,
            itemBuilder: (context, index) {
              final word = vocabProvider.filteredWords[index];
              return VocabWordCard(word: word);
            },
          ),
        );
      },
    );
  }
}