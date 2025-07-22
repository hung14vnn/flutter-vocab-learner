import 'package:flutter/material.dart';
import 'package:vocab_learner/consts/app_consts.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
      ),
      body: ListView.builder(
        itemCount: kPracticeGames.length,
        itemBuilder: (context, index) {
          final game = kPracticeGames[index];
          return   Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
            )
            ,
            child: Card(
              child: ListTile(
                leading: game.icon,
                title: Text(game.name),
                subtitle: Text(game.description),
                onTap: () {
                  Navigator.pushNamed(context, '/${game.name.toLowerCase().replaceAll(' ', '_')}');
                },
              ),
            ),
          );
        },
      ),
    );
  }
}