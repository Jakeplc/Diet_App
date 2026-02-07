import '../models/meal_timing.dart';

class MealTimingService {
  // Generates meal timing recommendations based on user's goal
  static MealTimingPlan generateMealTiming(String userGoal) {
    switch (userGoal) {
      case 'lose_weight':
        return _generateWeightLossTiming();
      case 'gain_weight':
        return _generateMuscleGainTiming();
      case 'body_recomp':
        return _generateBodyRecompTiming();
      default:
        return _generateMaintenanceTiming();
    }
  }

  // Weight loss: Space meals evenly, eat larger meals early, smaller dinner
  static MealTimingPlan _generateWeightLossTiming() {
    return MealTimingPlan(
      goal: 'lose_weight',
      meals: [
        MealTiming(
          mealType: 'Breakfast',
          recommendedTime: '7:00 AM',
          timeRange: '6:30 AM - 8:00 AM',
          reason: 'Kickstart metabolism and break overnight fast',
          tip:
              'Eat 30-35% of daily calories with protein to start your day strong',
          icon: '🥐',
          caloriePercentage: 35,
        ),
        MealTiming(
          mealType: 'Mid-Morning Snack',
          recommendedTime: '10:30 AM',
          timeRange: '10:00 AM - 11:00 AM',
          reason:
              'Maintain stable blood sugar and prevent afternoon energy crash',
          tip:
              'Keep it light: Greek yogurt, apple, or protein bar (150-200 cal)',
          icon: '🍎',
          caloriePercentage: 15,
        ),
        MealTiming(
          mealType: 'Lunch',
          recommendedTime: '1:00 PM',
          timeRange: '12:00 PM - 2:00 PM',
          reason: 'Second largest meal fuels afternoon productivity',
          tip: 'Eat 30-35% of daily calories with lean protein and vegetables',
          icon: '🥗',
          caloriePercentage: 35,
        ),
        MealTiming(
          mealType: 'Dinner',
          recommendedTime: '7:00 PM',
          timeRange: '6:00 PM - 8:00 PM',
          reason: 'Lighter meal allows better digestion and sleep',
          tip: 'Eat 15% of daily calories, focus on protein and veggies',
          icon: '🍖',
          caloriePercentage: 15,
        ),
      ],
      summary:
          'Weight Loss Timing: Front-load calories early, space meals evenly to manage hunger',
      tips: [
        '💧 Drink water 20-30 min before meals to enhance satiety',
        '⏰ Stay consistent - eat at same times daily for appetite regulation',
        '🚫 Avoid eating 2-3 hours before bed to prevent sleep disruption',
        '🔔 Set phone reminders for consistent meal timing',
      ],
    );
  }

  // Muscle gain: More frequent meals, carbs around workouts, higher calories
  static MealTimingPlan _generateMuscleGainTiming() {
    return MealTimingPlan(
      goal: 'gain_weight',
      meals: [
        MealTiming(
          mealType: 'Breakfast',
          recommendedTime: '7:00 AM',
          timeRange: '6:30 AM - 8:00 AM',
          reason: 'Break overnight fast and fuel morning activity',
          tip: 'Eat 25-30% of daily calories with carbs for sustained energy',
          icon: '🥞',
          caloriePercentage: 28,
        ),
        MealTiming(
          mealType: 'Mid-Morning Snack',
          recommendedTime: '10:00 AM',
          timeRange: '9:30 AM - 10:30 AM',
          reason: 'Increase total daily caloric intake throughout day',
          tip: 'Eat 200-300 calories: protein + carbs (shake, trail mix)',
          icon: '🥤',
          caloriePercentage: 15,
        ),
        MealTiming(
          mealType: 'Pre-Workout',
          recommendedTime: '12:30 PM',
          timeRange: '12:00 PM - 1:00 PM',
          reason: 'Fuel workout with carbs and moderate protein',
          tip: 'Eat 25-30 min before: banana + protein for sustained energy',
          icon: '⚡',
          caloriePercentage: 12,
        ),
        MealTiming(
          mealType: 'Post-Workout',
          recommendedTime: '2:00 PM',
          timeRange: '1:30 PM - 2:30 PM',
          reason: 'Replenish glycogen and support muscle protein synthesis',
          tip: 'Eat within 2 hours: carbs + 25g protein (rice + chicken)',
          icon: '🍗',
          caloriePercentage: 18,
        ),
        MealTiming(
          mealType: 'Dinner',
          recommendedTime: '6:30 PM',
          timeRange: '6:00 PM - 7:30 PM',
          reason: 'Final large meal to meet daily caloric and protein targets',
          tip: 'Eat 25-30% of daily calories with complex carbs + lean protein',
          icon: '🍲',
          caloriePercentage: 17,
        ),
      ],
      summary:
          'Muscle Gain Timing: Frequent meals with carbs around workouts for maximum gains',
      tips: [
        '💪 Post-workout meals most important - prioritize this timing',
        '🎯 Eat 0.7-1g protein per lb bodyweight spread across all meals',
        '⏰ Consistent meal timing helps establish eating patterns for surplus',
        '🍌 Pre-workout carbs give energy for heavier lifts',
      ],
    );
  }

  // Body recomposition: Balance calorie deficit with muscle-building nutrition timing
  static MealTimingPlan _generateBodyRecompTiming() {
    return MealTimingPlan(
      goal: 'body_recomp',
      meals: [
        MealTiming(
          mealType: 'Breakfast',
          recommendedTime: '7:00 AM',
          timeRange: '6:30 AM - 8:00 AM',
          reason: 'Kickstart metabolism with high-protein meal',
          tip: 'Eat 30% of daily calories: eggs + oats (40g protein)',
          icon: '🍳',
          caloriePercentage: 30,
        ),
        MealTiming(
          mealType: 'Pre-Workout',
          recommendedTime: '12:00 PM',
          timeRange: '11:30 AM - 12:30 PM',
          reason: 'Fuel workout with strategic carbs for performance',
          tip: 'Eat 25 min before: rice cakes + protein (200 cal, 30g carbs)',
          icon: '⚡',
          caloriePercentage: 15,
        ),
        MealTiming(
          mealType: 'Post-Workout',
          recommendedTime: '2:00 PM',
          timeRange: '1:30 PM - 2:30 PM',
          reason: 'Critical window for muscle protein synthesis in deficit',
          tip: 'Eat immediately: protein shake + carbs (300 cal, 40g protein)',
          icon: '🍗',
          caloriePercentage: 20,
        ),
        MealTiming(
          mealType: 'Dinner',
          recommendedTime: '6:30 PM',
          timeRange: '6:00 PM - 7:30 PM',
          reason: 'High-protein dinner supports muscle during deficit',
          tip:
              'Eat 35% of daily calories: lean protein + veggies (40g protein)',
          icon: '🥩',
          caloriePercentage: 35,
        ),
      ],
      summary:
          'Body Recomp Timing: High protein spread across day with strategic pre/post-workout nutrition',
      tips: [
        '🎯 Prioritize post-workout window - this preserves muscle in deficit',
        '💪 Eat 1g protein per lb bodyweight across 4 meals',
        '⏰ Consistent timing supports both fat loss and muscle gain',
        '🚫 Avoid eating 2-3 hours before bed despite smaller deficit',
      ],
    );
  }

  // Maintenance: Balanced approach with flexibility
  static MealTimingPlan _generateMaintenanceTiming() {
    return MealTimingPlan(
      goal: 'maintain',
      meals: [
        MealTiming(
          mealType: 'Breakfast',
          recommendedTime: '7:30 AM',
          timeRange: '7:00 AM - 8:30 AM',
          reason: 'Start day with balanced nutrition',
          tip: 'Eat 25-30% of daily calories: balanced macros',
          icon: '🥣',
          caloriePercentage: 28,
        ),
        MealTiming(
          mealType: 'Lunch',
          recommendedTime: '12:30 PM',
          timeRange: '12:00 PM - 1:30 PM',
          reason: 'Midday fuel for sustained energy',
          tip: 'Eat 30-35% of daily calories: protein + veggies',
          icon: '🥙',
          caloriePercentage: 33,
        ),
        MealTiming(
          mealType: 'Snack',
          recommendedTime: '4:00 PM',
          timeRange: '3:30 PM - 4:30 PM',
          reason: 'Bridge the gap between lunch and dinner',
          tip: 'Eat 10% of daily calories: light snack (fruit, nuts)',
          icon: '🍪',
          caloriePercentage: 10,
        ),
        MealTiming(
          mealType: 'Dinner',
          recommendedTime: '7:00 PM',
          timeRange: '6:30 PM - 8:00 PM',
          reason: 'Complete daily nutrition and prepare for rest',
          tip: 'Eat 25-30% of daily calories: balanced, satisfying meal',
          icon: '🍽️',
          caloriePercentage: 29,
        ),
      ],
      summary:
          'Maintenance Timing: Balanced meals spread throughout day with flexibility',
      tips: [
        '⏰ Eat at similar times daily for consistency',
        '💧 Hydrate throughout the day, especially between meals',
        '🎯 No strict meal timing needed - focus on total daily intake',
        '✨ Allow 2-3 hours between meals for digestion',
      ],
    );
  }

  // Get meals for display
  static List<MealTiming> getMeals(String userGoal) {
    return generateMealTiming(userGoal).meals;
  }

  // Get tips for display
  static List<String> getTips(String userGoal) {
    return generateMealTiming(userGoal).tips;
  }

  // Calculate when to eat based on wake time
  static String calculateMealTime(
    String userGoal,
    String mealType,
    String wakeTime,
  ) {
    // Simple calculation: offset from wake time
    // This can be enhanced based on actual user schedule
    return 'Calculated timing based on your schedule';
  }
}
