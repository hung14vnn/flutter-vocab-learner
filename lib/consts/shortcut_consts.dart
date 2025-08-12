import 'package:flutter/material.dart';

class ShortcutConsts {  
  final String name;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final int priority;

  ShortcutConsts({
    required this.name,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.priority,
  });
} 

final List<ShortcutConsts> kShortcuts = [
  ShortcutConsts(
    name: 'Add Single Word',
    description: 'Quickly add a new vocabulary word from the home screen.',
    icon: Icons.add_circle_outline,
    onTap: () {
      // Handle add single word action
    },
    priority: 1,
  ),
  ShortcutConsts(
    name: 'Practice',
    description: 'Start practicing your today vocabulary progress.',
    icon: Icons.play_circle_outline,
    onTap: () {
      // Handle practice action
    },
    priority: 2,
  ),
  ShortcutConsts(
    name: 'Settings',
    description: 'Access and modify app settings and preferences.',
    icon: Icons.settings,
    onTap: () {
      // Handle settings action
    },
    priority: 3,
  ),
];