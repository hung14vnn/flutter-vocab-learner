import 'package:flutter/material.dart';
import 'package:vocab_learner/consts/app_consts.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Practice'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.surface.withOpacity(0.8),
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: ListView.builder(
        itemCount: kPracticeGames.length,
        itemBuilder: (context, index) {
          final game = kPracticeGames[index];
          return Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),
            child: Card(
              color: colorScheme.surface.withOpacity(0.9),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: ListTile(
                  leading: game.icon,
                  title: Text(game.name),
                  subtitle: Text(game.description),
                  onTap: () {
                    Navigator.pushNamed(context, '/${game.name.toLowerCase().replaceAll(' ', '_')}');
                  },
                ),
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}