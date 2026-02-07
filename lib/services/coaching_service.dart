import '../models/food_log.dart';
import '../models/coaching_tip.dart';

class CoachingService {
  // Predefined coaching tips library
  static final List<CoachingTip> _allTips = [
    // Nutrition Tips
    CoachingTip(
      id: '1',
      category: 'nutrition',
      title: 'Protein at Every Meal',
      description: 'Distribute protein evenly across meals',
      tip:
          '🥚 Aim for 25-35g protein per meal. Add eggs, chicken, Greek yogurt, or legumes to breakfast, lunch, and dinner.',
      icon: '🥚',
      priority: 5,
      applicableGoals: ['lose_weight', 'body_recomp', 'gain_weight'],
    ),
    CoachingTip(
      id: '2',
      category: 'nutrition',
      title: 'Whole Grains Over Refined',
      description: 'Switch to complex carbs for sustained energy',
      tip:
          '🌾 Replace white bread/rice with oats, brown rice, whole wheat pasta, and quinoa. They keep you fuller longer!',
      icon: '🌾',
      priority: 4,
      applicableGoals: ['lose_weight', 'maintain', 'body_recomp'],
    ),
    CoachingTip(
      id: '3',
      category: 'nutrition',
      title: 'Vegetables First Strategy',
      description: 'Prioritize nutrient-dense vegetables',
      tip:
          '🥦 Eat vegetables first at each meal. They fill you up with fewer calories and provide essential micronutrients.',
      icon: '🥦',
      priority: 4,
      applicableGoals: ['lose_weight', 'maintain'],
    ),
    CoachingTip(
      id: '4',
      category: 'nutrition',
      title: 'Healthy Fats Matter',
      description: 'Include omega-3s and unsaturated fats',
      tip:
          '🥑 Add avocado, olive oil, nuts, and fatty fish. Healthy fats support hormone production and satiety.',
      icon: '🥑',
      priority: 3,
      applicableGoals: [
        'lose_weight',
        'maintain',
        'gain_weight',
        'body_recomp',
      ],
    ),

    // Hydration Tips
    CoachingTip(
      id: '5',
      category: 'hydration',
      title: 'Water Before Meals',
      description: 'Drink water 15 mins before eating',
      tip:
          '💧 Drinking water before meals reduces appetite and improves digestion. Aim for a glass 15 minutes before eating.',
      icon: '💧',
      priority: 4,
      applicableGoals: ['lose_weight'],
    ),
    CoachingTip(
      id: '6',
      category: 'hydration',
      title: 'Hydration & Performance',
      description: 'Optimal water intake boosts workouts',
      tip:
          '🏃 Even mild dehydration reduces workout performance. Drink water throughout the day, especially during exercise.',
      icon: '🏃',
      priority: 4,
      applicableGoals: ['gain_weight', 'body_recomp'],
    ),
    CoachingTip(
      id: '7',
      category: 'hydration',
      title: 'Track Your Hydration',
      description: 'Monitor water intake consistently',
      tip:
          '📊 Use the water logging feature daily. Your urine color should be pale yellow - a sign of good hydration.',
      icon: '📊',
      priority: 3,
      applicableGoals: [
        'lose_weight',
        'maintain',
        'gain_weight',
        'body_recomp',
      ],
    ),

    // Macro Tips
    CoachingTip(
      id: '8',
      category: 'macros',
      title: 'Carbs Post-Workout',
      description: 'Refuel with carbs after training',
      tip:
          '🏋️ Eat carbs and protein within 1-2 hours after workouts. This replenishes glycogen and aids muscle recovery.',
      icon: '🏋️',
      priority: 4,
      applicableGoals: ['body_recomp', 'gain_weight'],
    ),
    CoachingTip(
      id: '9',
      category: 'macros',
      title: 'Protein for Satiety',
      description: 'Protein keeps you full longer',
      tip:
          '🍗 High-protein meals increase satiety hormones. This naturally helps you eat less without feeling deprived.',
      icon: '🍗',
      priority: 5,
      applicableGoals: ['lose_weight', 'body_recomp'],
    ),
    CoachingTip(
      id: '10',
      category: 'macros',
      title: 'Don\'t Fear Fats',
      description: 'Fats are essential for hormone health',
      tip:
          '🧈 Healthy fats (20-30% of calories) support testosterone, vitamin absorption, and brain function.',
      icon: '🧈',
      priority: 3,
      applicableGoals: ['gain_weight', 'body_recomp', 'maintain'],
    ),

    // Consistency Tips
    CoachingTip(
      id: '11',
      category: 'consistency',
      title: 'Log Daily, Even Weekends',
      description: 'Consistency beats perfection',
      tip:
          '📝 Track your food every single day, including weekends. This awareness alone improves results by 30%+',
      icon: '📝',
      priority: 5,
      applicableGoals: [
        'lose_weight',
        'maintain',
        'gain_weight',
        'body_recomp',
      ],
    ),
    CoachingTip(
      id: '12',
      category: 'consistency',
      title: 'Build Your Streak',
      description: 'Form habits through streaks',
      tip:
          '🔥 Your streak matters! Even small daily actions compound. Missing one day resets progress - keep it going!',
      icon: '🔥',
      priority: 5,
      applicableGoals: [
        'lose_weight',
        'maintain',
        'gain_weight',
        'body_recomp',
      ],
    ),
    CoachingTip(
      id: '13',
      category: 'consistency',
      title: 'Plan Ahead',
      description: 'Meal prep reduces temptation',
      tip:
          '🍱 Spend 1 hour Sunday prepping meals. Having healthy food ready prevents impulse bad decisions.',
      icon: '🍱',
      priority: 4,
      applicableGoals: ['lose_weight', 'body_recomp'],
    ),

    // Timing Tips
    CoachingTip(
      id: '14',
      category: 'timing',
      title: 'Breakfast Boosts Metabolism',
      description: 'Start your day with a meal',
      tip:
          '🌅 Eating breakfast jump-starts your metabolism and provides energy for the day. Don\'t skip it!',
      icon: '🌅',
      priority: 4,
      applicableGoals: ['lose_weight', 'maintain'],
    ),
    CoachingTip(
      id: '15',
      category: 'timing',
      title: 'No Food Before Bed',
      description: 'Stop eating 3 hours before sleep',
      tip:
          '😴 Eating close to bedtime disrupts sleep quality. Aim for your last meal 3 hours before bed.',
      icon: '😴',
      priority: 3,
      applicableGoals: ['lose_weight', 'maintain'],
    ),

    // General Tips
    CoachingTip(
      id: '16',
      category: 'general',
      title: 'Progressive Overload',
      description: 'Gradually increase workout intensity',
      tip:
          '💪 Each week, add 1-2 more reps, slightly more weight, or longer duration. Small improvements compound!',
      icon: '💪',
      priority: 4,
      applicableGoals: ['body_recomp', 'gain_weight'],
    ),
    CoachingTip(
      id: '17',
      category: 'general',
      title: 'Sleep Matters',
      description: 'Get 7-9 hours of quality sleep',
      tip:
          '😴 Poor sleep increases hunger hormones and decreases fat loss. Make sleep a priority for results.',
      icon: '😴',
      priority: 4,
      applicableGoals: ['lose_weight', 'body_recomp', 'gain_weight'],
    ),
    CoachingTip(
      id: '18',
      category: 'general',
      title: 'Track Weight Trends',
      description: 'Focus on weekly averages, not daily',
      tip:
          '📈 Daily weight fluctuates 2-3 lbs. Track weekly averages to see true progress. Don\'t get discouraged!',
      icon: '📈',
      priority: 4,
      applicableGoals: ['lose_weight', 'body_recomp'],
    ),
    CoachingTip(
      id: '19',
      category: 'general',
      title: 'Calorie Awareness',
      description: 'Understanding your calorie goal',
      tip:
          '🎯 Your daily calorie target is personalized to YOUR goal. Stick to it consistently for best results.',
      icon: '🎯',
      priority: 5,
      applicableGoals: [
        'lose_weight',
        'maintain',
        'gain_weight',
        'body_recomp',
      ],
    ),
    CoachingTip(
      id: '20',
      category: 'general',
      title: 'Read Food Labels',
      description: 'Know what you\'re eating',
      tip:
          '🏷️ Check nutrition labels for hidden sugars, sodium, and calories. Knowledge is power!',
      icon: '🏷️',
      priority: 3,
      applicableGoals: ['lose_weight', 'maintain'],
    ),
  ];

  // Generate personalized tips based on user data
  static List<CoachingTip> generatePersonalizedTips({
    required String userGoal,
    required List<FoodLog> recentLogs,
    required bool isPremium,
  }) {
    if (!isPremium) return [];

    // Filter tips applicable to user's goal
    List<CoachingTip> applicableTips = _allTips
        .where((tip) => tip.applicableGoals.contains(userGoal))
        .toList();

    // Analyze recent logs to provide contextual tips
    if (recentLogs.isNotEmpty) {
      // Check if user is skipping breakfast
      final breakfastLogs = recentLogs
          .where((log) => log.mealType.toLowerCase() == 'breakfast')
          .toList();
      if (breakfastLogs.isEmpty) {
        // Prioritize breakfast tip
        applicableTips.sort((a, b) {
          if (a.id == '14' && b.id != '14') return -1;
          if (a.id != '14' && b.id == '14') return 1;
          return 0;
        });
      }

      // Check protein intake
      double avgProtein = recentLogs.isNotEmpty
          ? recentLogs.map((e) => e.protein).reduce((a, b) => a + b) /
                recentLogs.length
          : 0;
      if (avgProtein < 80) {
        // Prioritize protein tips
        applicableTips.sort((a, b) {
          if ((a.id == '1' || a.id == '9') && b.id != '1' && b.id != '9') {
            return -1;
          }
          if ((a.id != '1' && a.id != '9') && (b.id == '1' || b.id == '9')) {
            return 1;
          }
          return 0;
        });
      }
    }

    // Sort by priority and return top 5
    applicableTips.sort((a, b) => b.priority.compareTo(a.priority));
    return applicableTips.take(5).toList();
  }

  // Get a single random tip
  static CoachingTip getRandomTip({required String userGoal}) {
    final applicable = _allTips
        .where((tip) => tip.applicableGoals.contains(userGoal))
        .toList();
    if (applicable.isEmpty) return _allTips.first;
    applicable.shuffle();
    return applicable.first;
  }

  // Get tips by category
  static List<CoachingTip> getTipsByCategory(String category) {
    return _allTips.where((tip) => tip.category == category).toList();
  }

  // Get all available categories
  static List<String> getCategories() {
    return _allTips.map((tip) => tip.category).toSet().toList();
  }
}
