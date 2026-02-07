import 'package:flutter/material.dart';

/// Achievement categories
enum AchievementCategory { streak, weight, fasting, logging, goals, milestones }

/// Individual achievement/badge
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementCategory category;
  final int requirement; // The value needed to unlock
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentProgress; // User's current progress toward this achievement

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.requirement,
    this.isUnlocked = false,
    this.unlockedAt,
    this.currentProgress = 0,
  });

  /// Get progress percentage (0-100)
  double get progressPercentage {
    if (isUnlocked) return 100;
    return ((currentProgress / requirement) * 100).clamp(0, 100).toDouble();
  }

  /// Check if achievement is ready to unlock
  bool get canUnlock => currentProgress >= requirement && !isUnlocked;

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    AchievementCategory? category,
    int? requirement,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? currentProgress,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      requirement: requirement ?? this.requirement,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'category': category.name,
      'requirement': requirement,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'currentProgress': currentProgress,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
      category: AchievementCategory.values.firstWhere(
        (e) => e.name == map['category'],
      ),
      requirement: map['requirement'],
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null
          ? DateTime.parse(map['unlockedAt'])
          : null,
      currentProgress: map['currentProgress'] ?? 0,
    );
  }
}

/// Predefined achievements
class AchievementDefinitions {
  static const List<Achievement> all = [
    // Streak Achievements
    Achievement(
      id: 'streak_3',
      name: 'Getting Started',
      description: 'Log food for 3 days in a row',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      category: AchievementCategory.streak,
      requirement: 3,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Week Warrior',
      description: 'Log food for 7 days in a row',
      icon: Icons.local_fire_department,
      color: Colors.deepOrange,
      category: AchievementCategory.streak,
      requirement: 7,
    ),
    Achievement(
      id: 'streak_30',
      name: 'Monthly Master',
      description: 'Log food for 30 days in a row',
      icon: Icons.local_fire_department,
      color: Colors.red,
      category: AchievementCategory.streak,
      requirement: 30,
    ),
    Achievement(
      id: 'streak_100',
      name: 'Century Club',
      description: 'Log food for 100 days in a row',
      icon: Icons.emoji_events,
      color: Colors.amber,
      category: AchievementCategory.streak,
      requirement: 100,
    ),

    // Weight Loss Achievements
    Achievement(
      id: 'weight_5lb',
      name: 'First Steps',
      description: 'Lose 5 pounds',
      icon: Icons.trending_down,
      color: Colors.green,
      category: AchievementCategory.weight,
      requirement: 5,
    ),
    Achievement(
      id: 'weight_10lb',
      name: 'Double Digits',
      description: 'Lose 10 pounds',
      icon: Icons.trending_down,
      color: Colors.lightGreen,
      category: AchievementCategory.weight,
      requirement: 10,
    ),
    Achievement(
      id: 'weight_25lb',
      name: 'Quarter Century',
      description: 'Lose 25 pounds',
      icon: Icons.star,
      color: Colors.teal,
      category: AchievementCategory.weight,
      requirement: 25,
    ),
    Achievement(
      id: 'weight_50lb',
      name: 'Half Hundred',
      description: 'Lose 50 pounds',
      icon: Icons.stars,
      color: Colors.purple,
      category: AchievementCategory.weight,
      requirement: 50,
    ),

    // Fasting Achievements
    Achievement(
      id: 'fast_first',
      name: 'Fasting Beginner',
      description: 'Complete your first fast',
      icon: Icons.timer,
      color: Colors.blue,
      category: AchievementCategory.fasting,
      requirement: 1,
    ),
    Achievement(
      id: 'fast_10',
      name: 'Fasting Regular',
      description: 'Complete 10 fasts',
      icon: Icons.timer,
      color: Colors.indigo,
      category: AchievementCategory.fasting,
      requirement: 10,
    ),
    Achievement(
      id: 'fast_50',
      name: 'Fasting Expert',
      description: 'Complete 50 fasts',
      icon: Icons.verified,
      color: Colors.deepPurple,
      category: AchievementCategory.fasting,
      requirement: 50,
    ),

    // Logging Achievements
    Achievement(
      id: 'log_100',
      name: 'Food Logger',
      description: 'Log 100 food items',
      icon: Icons.restaurant,
      color: Colors.brown,
      category: AchievementCategory.logging,
      requirement: 100,
    ),
    Achievement(
      id: 'log_500',
      name: 'Nutrition Tracker',
      description: 'Log 500 food items',
      icon: Icons.restaurant_menu,
      color: Colors.deepOrange,
      category: AchievementCategory.logging,
      requirement: 500,
    ),
    Achievement(
      id: 'log_1000',
      name: 'Tracking Master',
      description: 'Log 1000 food items',
      icon: Icons.dinner_dining,
      color: Colors.red,
      category: AchievementCategory.logging,
      requirement: 1000,
    ),

    // Goal Achievements
    Achievement(
      id: 'goal_reached',
      name: 'Goal Getter',
      description: 'Reach your target weight',
      icon: Icons.emoji_events,
      color: Colors.amber,
      category: AchievementCategory.goals,
      requirement: 1,
    ),
    Achievement(
      id: 'calorie_target_7',
      name: 'Calorie Consistent',
      description: 'Hit calorie target for 7 days',
      icon: Icons.track_changes,
      color: Colors.cyan,
      category: AchievementCategory.goals,
      requirement: 7,
    ),
    Achievement(
      id: 'calorie_target_30',
      name: 'Calorie Champion',
      description: 'Hit calorie target for 30 days',
      icon: Icons.tune,
      color: Colors.blue,
      category: AchievementCategory.goals,
      requirement: 30,
    ),

    // Milestone Achievements
    Achievement(
      id: 'water_30',
      name: 'Hydration Hero',
      description: 'Log water for 30 days',
      icon: Icons.water_drop,
      color: Colors.lightBlue,
      category: AchievementCategory.milestones,
      requirement: 30,
    ),
    Achievement(
      id: 'scan_50',
      name: 'Barcode Scanner',
      description: 'Scan 50 barcodes',
      icon: Icons.qr_code_scanner,
      color: Colors.deepPurple,
      category: AchievementCategory.milestones,
      requirement: 50,
    ),
    Achievement(
      id: 'recipe_10',
      name: 'Recipe Creator',
      description: 'Create 10 custom recipes',
      icon: Icons.menu_book,
      color: Colors.pink,
      category: AchievementCategory.milestones,
      requirement: 10,
    ),
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return all.where((a) => a.category == category).toList();
  }
}
