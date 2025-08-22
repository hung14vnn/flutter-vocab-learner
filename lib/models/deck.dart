class Deck {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final List<String> wordIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> sharedWith;
  final String? color;
  final String? icon;

  Deck({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.wordIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.sharedWith = const [],
    this.color,
    this.icon,
  });

  factory Deck.fromFirestore(Object? data, String id) {
    final Map<String, dynamic> map = data as Map<String, dynamic>;
    return Deck(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      wordIds: List<String>.from(map['wordIds'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
      color: map['color'],
      icon: map['icon'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'wordIds': wordIds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'sharedWith': sharedWith,
      'color': color,
      'icon': icon,
    };
  }

  Deck copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<String>? wordIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? sharedWith,
    String? color,
    String? icon,
  }) {
    return Deck(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      wordIds: wordIds ?? this.wordIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sharedWith: sharedWith ?? this.sharedWith,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  // Helper method to get word count
  int get wordCount => wordIds.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Deck &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Deck{id: $id, name: $name, wordCount: $wordCount}';
  }
}
