class CoachingTip {
  final String id;
  final String
  category; // nutrition, hydration, exercise, macros, consistency, timing
  final String title;
  final String description;
  final String tip;
  final String icon; // emoji
  final int priority; // 1-5, higher = more important
  final List<String> applicableGoals; // e.g., ['lose_weight', 'body_recomp']
  final DateTime createdAt;

  CoachingTip({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.tip,
    required this.icon,
    required this.priority,
    required this.applicableGoals,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'tip': tip,
      'icon': icon,
      'priority': priority,
      'applicableGoals': applicableGoals,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CoachingTip.fromMap(Map<String, dynamic> map) {
    return CoachingTip(
      id: map['id'],
      category: map['category'],
      title: map['title'],
      description: map['description'],
      tip: map['tip'],
      icon: map['icon'],
      priority: map['priority'],
      applicableGoals: List<String>.from(map['applicableGoals']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
