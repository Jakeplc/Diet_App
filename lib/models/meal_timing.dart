class MealTiming {
  final String mealType; // breakfast, lunch, dinner, snack
  final String recommendedTime; // HH:MM format
  final String timeRange; // e.g., "6:00 AM - 8:00 AM"
  final String reason;
  final String tip;
  final String icon; // emoji
  final int caloriePercentage; // % of daily calories for this meal

  MealTiming({
    required this.mealType,
    required this.recommendedTime,
    required this.timeRange,
    required this.reason,
    required this.tip,
    required this.icon,
    required this.caloriePercentage,
  });
}

class MealTimingPlan {
  final String goal; // lose_weight, maintain, gain_weight, body_recomp
  final List<MealTiming> meals;
  final String summary;
  final List<String> tips;

  MealTimingPlan({
    required this.goal,
    required this.meals,
    required this.summary,
    required this.tips,
  });
}
