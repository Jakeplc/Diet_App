class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final String rarity; // 'common', 'uncommon', 'rare', 'epic', 'legendary'

  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
    required this.rarity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'rarity': rarity,
    };
  }

  static AchievementBadge fromMap(Map<String, dynamic> map) {
    return AchievementBadge(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      icon: map['icon'] as String,
      isUnlocked: map['isUnlocked'] as bool,
      unlockedDate: map['unlockedDate'] != null
          ? DateTime.parse(map['unlockedDate'] as String)
          : null,
      rarity: map['rarity'] as String,
    );
  }
}

class ExtendedAchievementService {
  static final List<AchievementBadge> _allBadges = [
    // Consistency Badges
    AchievementBadge(
      id: '1',
      title: 'First Step',
      description: 'Log your first meal',
      category: 'Consistency',
      icon: 'ðŸ‘£',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 30)),
      rarity: 'common',
    ),
    AchievementBadge(
      id: '2',
      title: 'Week Warrior',
      description: 'Log meals for 7 consecutive days',
      category: 'Consistency',
      icon: 'âš”ï¸',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 25)),
      rarity: 'uncommon',
    ),
    AchievementBadge(
      id: '3',
      title: 'Month Master',
      description: 'Log meals for 30 consecutive days',
      category: 'Consistency',
      icon: 'ðŸ‘‘',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 10)),
      rarity: 'rare',
    ),
    AchievementBadge(
      id: '4',
      title: 'Century Club',
      description: 'Log meals for 100 days total',
      category: 'Consistency',
      icon: 'ðŸ’¯',
      isUnlocked: false,
      rarity: 'epic',
    ),
    AchievementBadge(
      id: '5',
      title: 'Iron Will',
      description: 'Maintain 90-day logging streak',
      category: 'Consistency',
      icon: 'âš¡',
      isUnlocked: false,
      rarity: 'legendary',
    ),

    // Nutrition Badges
    AchievementBadge(
      id: '6',
      title: 'Macro Master',
      description: 'Hit macros within 5% for 5 days',
      category: 'Nutrition',
      icon: 'ðŸŽ¯',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 15)),
      rarity: 'uncommon',
    ),
    AchievementBadge(
      id: '7',
      title: 'Protein Pro',
      description: 'Reach protein goal for 10 consecutive days',
      category: 'Nutrition',
      icon: 'ðŸ¥š',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 8)),
      rarity: 'uncommon',
    ),
    AchievementBadge(
      id: '8',
      title: 'Vitamin Villain',
      description: 'Track micronutrients for 7 days',
      category: 'Nutrition',
      icon: 'ðŸ’Š',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 5)),
      rarity: 'rare',
    ),
    AchievementBadge(
      id: '9',
      title: 'Water Warrior',
      description: 'Drink recommended water for 10 days',
      category: 'Nutrition',
      icon: 'ðŸ’§',
      isUnlocked: false,
      rarity: 'uncommon',
    ),
    AchievementBadge(
      id: '10',
      title: 'Calorie Counter',
      description: 'Stay within 50 calories of goal for 20 days',
      category: 'Nutrition',
      icon: 'ðŸ”¢',
      isUnlocked: false,
      rarity: 'rare',
    ),

    // Fitness Badges
    AchievementBadge(
      id: '11',
      title: 'Starter',
      description: 'Complete first workout',
      category: 'Fitness',
      icon: 'ðŸƒ',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 20)),
      rarity: 'common',
    ),
    AchievementBadge(
      id: '12',
      title: 'Heart of Gold',
      description: 'Log heart rate 5 times',
      category: 'Fitness',
      icon: 'â¤ï¸',
      isUnlocked: false,
      rarity: 'uncommon',
    ),
    AchievementBadge(
      id: '13',
      title: 'Step Counter',
      description: 'Log 50,000 steps',
      category: 'Fitness',
      icon: 'ðŸ‘Ÿ',
      isUnlocked: false,
      rarity: 'rare',
    ),
    AchievementBadge(
      id: '14',
      title: 'Marathon Man',
      description: 'Complete 26 workouts',
      category: 'Fitness',
      icon: 'ðŸ…',
      isUnlocked: false,
      rarity: 'epic',
    ),
    AchievementBadge(
      id: '15',
      title: 'Beast Mode',
      description: 'Complete 100 workouts',
      category: 'Fitness',
      icon: 'ðŸ»',
      isUnlocked: false,
      rarity: 'legendary',
    ),

    // Weight Loss Badges
    AchievementBadge(
      id: '16',
      title: 'First Loss',
      description: 'Lose 1 kg',
      category: 'Weight Loss',
      icon: 'ðŸ“‰',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 18)),
      rarity: 'common',
    ),
    AchievementBadge(
      id: '17',
      title: 'Major Progress',
      description: 'Lose 5 kg',
      category: 'Weight Loss',
      icon: 'â¬‡ï¸',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 12)),
      rarity: 'rare',
    ),
    AchievementBadge(
      id: '18',
      title: 'Transformation',
      description: 'Lose 10 kg',
      category: 'Weight Loss',
      icon: 'ðŸ”„',
      isUnlocked: false,
      rarity: 'epic',
    ),
    AchievementBadge(
      id: '19',
      title: 'Life Changer',
      description: 'Lose 20 kg',
      category: 'Weight Loss',
      icon: 'âœ¨',
      isUnlocked: false,
      rarity: 'legendary',
    ),

    // Community Badges
    AchievementBadge(
      id: '20',
      title: 'Social Butterfly',
      description: 'Add 5 friends',
      category: 'Community',
      icon: 'ðŸ¦‹',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 3)),
      rarity: 'uncommon',
    ),
    AchievementBadge(
      id: '21',
      title: 'Challenge Crusher',
      description: 'Complete 3 challenges',
      category: 'Community',
      icon: 'ðŸŽ®',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 2)),
      rarity: 'uncommon',
    ),
    AchievementBadge(
      id: '22',
      title: 'Team Player',
      description: 'Win a community challenge',
      category: 'Community',
      icon: 'ðŸ†',
      isUnlocked: false,
      rarity: 'rare',
    ),
    AchievementBadge(
      id: '23',
      title: 'Mentor',
      description: 'Motivate 10 friends',
      category: 'Community',
      icon: 'ðŸŽ“',
      isUnlocked: false,
      rarity: 'epic',
    ),

    // Sleep Badges
    AchievementBadge(
      id: '24',
      title: 'Night Owl',
      description: 'Log sleep 10 times',
      category: 'Health',
      icon: 'ðŸ¦‰',
      isUnlocked: false,
      rarity: 'uncommon',
    ),
    AchievementBadge(
      id: '25',
      title: 'Beauty Sleep',
      description: 'Get 8+ hours sleep for 5 nights',
      category: 'Health',
      icon: 'ðŸ˜´',
      isUnlocked: false,
      rarity: 'rare',
    ),
    AchievementBadge(
      id: '26',
      title: 'Sleepwalker',
      description: 'Log 30 nights of sleep',
      category: 'Health',
      icon: 'ðŸš¶',
      isUnlocked: false,
      rarity: 'epic',
    ),

    // Premium Badges
    AchievementBadge(
      id: '27',
      title: 'Premium Member',
      description: 'Go premium',
      category: 'Premium',
      icon: 'ðŸ’Ž',
      isUnlocked: true,
      unlockedDate: DateTime.now().subtract(const Duration(days: 40)),
      rarity: 'rare',
    ),
    AchievementBadge(
      id: '28',
      title: 'Analytics Master',
      description: 'View 10 analytics reports',
      category: 'Premium',
      icon: 'ðŸ“Š',
      isUnlocked: false,
      rarity: 'uncommon',
    ),
    AchievementBadge(
      id: '29',
      title: 'Data Hoarder',
      description: 'Export data 5 times',
      category: 'Premium',
      icon: 'ðŸ“‚',
      isUnlocked: false,
      rarity: 'uncommon',
    ),
    AchievementBadge(
      id: '30',
      title: 'Ultimate',
      description: 'Unlock all other achievements',
      category: 'Premium',
      icon: 'ðŸ‘‘',
      isUnlocked: false,
      rarity: 'legendary',
    ),
  ];

  static Future<List<AchievementBadge>> getAllBadges() async {
    return _allBadges;
  }

  static Future<List<AchievementBadge>> getUnlockedBadges() async {
    return _allBadges.where((b) => b.isUnlocked).toList();
  }

  static Future<List<AchievementBadge>> getLockedBadges() async {
    return _allBadges.where((b) => !b.isUnlocked).toList();
  }

  static Future<List<AchievementBadge>> getBadgesByCategory(
    String category,
  ) async {
    return _allBadges.where((b) => b.category == category).toList();
  }

  static Future<int> getTotalProgress() async {
    final unlocked = _allBadges.where((b) => b.isUnlocked).length;
    return ((unlocked / _allBadges.length) * 100).toInt();
  }

  static String getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return '#808080'; // Gray
      case 'uncommon':
        return '#00FF00'; // Green
      case 'rare':
        return '#0000FF'; // Blue
      case 'epic':
        return '#FF00FF'; // Purple
      case 'legendary':
        return '#FFD700'; // Gold
      default:
        return '#FFFFFF';
    }
  }
}
