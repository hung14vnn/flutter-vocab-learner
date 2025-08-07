import 'package:flutter/material.dart';

class ShortcutConsts {  
  final String name;
  final String description;
  final IconData icon;

  ShortcutConsts({
    required this.name,
    required this.description,
    required this.icon,
  });
} 

final List<ShortcutConsts> kShortcuts = [
  ShortcutConsts(
    name: 'Add Single Word',
    description: 'Quickly add a new vocabulary word.',
    icon: Icons.add_circle_outline,
  ),
  ShortcutConsts(
    name: 'Practice',
    description: 'Start practicing your vocabulary words.',
    icon: Icons.play_circle_outline,
  ),
  ShortcutConsts(
    name: 'Settings',
    description: 'Access app settings and preferences.',
    icon: Icons.settings,
  ),
];