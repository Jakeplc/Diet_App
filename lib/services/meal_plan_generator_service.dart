import 'dart:math';
import '../models/meal_plan.dart';
import '../models/food_item.dart';
import '../models/recipe.dart';
import '../models/user_profile.dart';
import 'storage_service.dart';

class MealPlanGeneratorService {
  /// Generate a meal plan for the specified number of days
  static Future<List<MealPlan>> generateMealPlan({
    required int days,
    required DateTime startDate,
    bool includeRecipes = true,
    bool avoidRepetition = true,
  }) async {
    // Get user profile for nutritional targets
    final profile = StorageService.getUserProfile();
    if (profile == null) {
      throw Exception(
        'User profile not found. Please complete onboarding first.',
      );
    }

    // Get available foods and recipes
    final allFoods = StorageService.getAllFoodItems();
    final allRecipes = includeRecipes
        ? StorageService.getAllRecipes()
        : <Recipe>[];

    if (allFoods.isEmpty) {
      throw Exception('No foods available in database.');
    }

    // Filter foods based on diet type
    final availableFoods = _filterFoodsByDietType(allFoods, profile.dietType);
    final availableRecipes = includeRecipes
        ? _filterRecipesByDietType(allRecipes, profile.dietType)
        : <Recipe>[];

    // Calculate meal distribution
    final mealDistribution = _calculateMealDistribution(profile);

    // Generate meal plans
    final mealPlans = <MealPlan>[];
    final random = Random();
    final usedFoodIds = <String>{}; // Track used foods for variety

    for (int day = 0; day < days; day++) {
      final currentDate = startDate.add(Duration(days: day));
      final dayOfWeek = _getDayOfWeek(currentDate);

      // Generate meals for each meal type
      for (final mealType in ['Breakfast', 'Lunch', 'Dinner', 'Snack']) {
        final targetCalories = mealDistribution[mealType] ?? 0;

        // Select foods for this meal
        final selectedFoodIds = _selectFoodsForMeal(
          mealType: mealType,
          targetCalories: targetCalories,
          availableFoods: availableFoods,
          availableRecipes: availableRecipes,
          usedFoodIds: avoidRepetition ? usedFoodIds : {},
          random: random,
        );

        if (selectedFoodIds.isNotEmpty) {
          final mealPlan = MealPlan(
            id: '${currentDate.toIso8601String()}_$mealType',
            name: '$mealType for $dayOfWeek',
            date: currentDate,
            dayOfWeek: dayOfWeek,
            mealType: mealType,
            foodItemIds: selectedFoodIds,
            isPremium: false,
          );

          mealPlans.add(mealPlan);
        }

        // Clear used foods every 2 days for some repetition
        if (avoidRepetition && day % 2 == 1 && mealType == 'Snack') {
          usedFoodIds.clear();
        }
      }
    }

    return mealPlans;
  }

  /// Filter foods based on diet type
  static List<FoodItem> _filterFoodsByDietType(
    List<FoodItem> foods,
    String dietType,
  ) {
    switch (dietType.toLowerCase()) {
      case 'vegetarian':
        return foods
            .where(
              (food) =>
                  !food.category.toLowerCase().contains('meat') &&
                  !food.category.toLowerCase().contains('fish') &&
                  !food.category.toLowerCase().contains('seafood'),
            )
            .toList();

      case 'vegan':
        return foods
            .where(
              (food) =>
                  !food.category.toLowerCase().contains('meat') &&
                  !food.category.toLowerCase().contains('fish') &&
                  !food.category.toLowerCase().contains('seafood') &&
                  !food.category.toLowerCase().contains('dairy') &&
                  !food.name.toLowerCase().contains('egg') &&
                  !food.name.toLowerCase().contains('milk') &&
                  !food.name.toLowerCase().contains('cheese') &&
                  !food.name.toLowerCase().contains('yogurt'),
            )
            .toList();

      case 'keto':
        // Low carb foods (< 10g carbs per 100g)
        return foods.where((food) => food.carbs < 10).toList();

      case 'paleo':
        return foods
            .where(
              (food) =>
                  !food.category.toLowerCase().contains('grain') &&
                  !food.category.toLowerCase().contains('dairy') &&
                  !food.name.toLowerCase().contains('bread') &&
                  !food.name.toLowerCase().contains('pasta') &&
                  !food.name.toLowerCase().contains('rice'),
            )
            .toList();

      default:
        return foods;
    }
  }

  /// Filter recipes based on diet type
  static List<Recipe> _filterRecipesByDietType(
    List<Recipe> recipes,
    String dietType,
  ) {
    // For now, return all recipes. Can be enhanced to check ingredients
    return recipes;
  }

  /// Calculate calorie distribution across meals
  static Map<String, double> _calculateMealDistribution(UserProfile profile) {
    final totalCalories = profile.dailyCalorieTarget;

    // Standard distribution: Breakfast 25%, Lunch 35%, Dinner 30%, Snack 10%
    return {
      'Breakfast': totalCalories * 0.25,
      'Lunch': totalCalories * 0.35,
      'Dinner': totalCalories * 0.30,
      'Snack': totalCalories * 0.10,
    };
  }

  /// Select foods for a meal to meet calorie target
  static List<String> _selectFoodsForMeal({
    required String mealType,
    required double targetCalories,
    required List<FoodItem> availableFoods,
    required List<Recipe> availableRecipes,
    required Set<String> usedFoodIds,
    required Random random,
  }) {
    final selectedIds = <String>[];
    double currentCalories = 0;
    final tolerance = targetCalories * 0.15; // 15% tolerance

    // Filter foods suitable for meal type
    final suitableFoods = _getFoodsForMealType(
      availableFoods,
      mealType,
      usedFoodIds,
    );
    final anyMealTypeFoods = _getFoodsForMealType(availableFoods, mealType, {});

    if (suitableFoods.isEmpty) {
      // If variety filtering exhausted choices, fall back to meal-type foods.
      final fallbackFoods = anyMealTypeFoods.isNotEmpty
          ? anyMealTypeFoods
          : availableFoods;
      final food = fallbackFoods[random.nextInt(fallbackFoods.length)];
      selectedIds.add(food.id);
      usedFoodIds.add(food.id);
      return selectedIds;
    }

    // Try to hit target calories
    int attempts = 0;
    while (currentCalories < targetCalories - tolerance && attempts < 10) {
      final remainingCalories = targetCalories - currentCalories;

      // Find food that fits remaining calories
      final candidateFoods = suitableFoods.isNotEmpty
          ? suitableFoods
          : (anyMealTypeFoods.isNotEmpty ? anyMealTypeFoods : availableFoods)
                .where((food) => !usedFoodIds.contains(food.id))
                .toList();
      final filteredCandidates = candidateFoods
          .where(
            (food) =>
                food.calories <= remainingCalories + tolerance &&
                !selectedIds.contains(food.id),
          )
          .toList();

      if (filteredCandidates.isEmpty) break;

      // Select random food from candidates
      final selectedFood =
          filteredCandidates[random.nextInt(filteredCandidates.length)];
      selectedIds.add(selectedFood.id);
      usedFoodIds.add(selectedFood.id);
      currentCalories += selectedFood.calories;

      attempts++;
    }

    // If we couldn't select any foods, add at least one
    if (selectedIds.isEmpty && suitableFoods.isNotEmpty) {
      final food = suitableFoods[random.nextInt(suitableFoods.length)];
      selectedIds.add(food.id);
      usedFoodIds.add(food.id);
    }

    return selectedIds;
  }

  /// Get foods suitable for specific meal type
  static List<FoodItem> _getFoodsForMealType(
    List<FoodItem> foods,
    String mealType,
    Set<String> usedFoodIds,
  ) {
    final unusedFoods = foods
        .where((f) => !usedFoodIds.contains(f.id))
        .toList();

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return unusedFoods
            .where(
              (food) =>
                  food.name.toLowerCase().contains('egg') ||
                  food.name.toLowerCase().contains('oat') ||
                  food.name.toLowerCase().contains('yogurt') ||
                  food.name.toLowerCase().contains('bread') ||
                  food.name.toLowerCase().contains('cereal') ||
                  food.name.toLowerCase().contains('pancake') ||
                  food.name.toLowerCase().contains('waffle') ||
                  food.category.toLowerCase().contains('breakfast'),
            )
            .toList();

      case 'lunch':
      case 'dinner':
        return unusedFoods
            .where(
              (food) =>
                  food.category.toLowerCase().contains('protein') ||
                  food.category.toLowerCase().contains('grain') ||
                  food.category.toLowerCase().contains('vegetable') ||
                  food.name.toLowerCase().contains('chicken') ||
                  food.name.toLowerCase().contains('fish') ||
                  food.name.toLowerCase().contains('beef') ||
                  food.name.toLowerCase().contains('rice') ||
                  food.name.toLowerCase().contains('pasta') ||
                  food.name.toLowerCase().contains('salad'),
            )
            .toList();

      case 'snack':
        return unusedFoods
            .where(
              (food) =>
                  food.calories < 250 &&
                  (food.category.toLowerCase().contains('fruit') ||
                      food.category.toLowerCase().contains('snack') ||
                      food.name.toLowerCase().contains('apple') ||
                      food.name.toLowerCase().contains('banana') ||
                      food.name.toLowerCase().contains('nuts') ||
                      food.name.toLowerCase().contains('bar')),
            )
            .toList();

      default:
        return unusedFoods;
    }
  }

  /// Get day of week name
  static String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  /// Save generated meal plans to storage
  static Future<void> saveMealPlans(List<MealPlan> mealPlans) async {
    for (final plan in mealPlans) {
      await StorageService.saveMealPlan(plan);
    }
  }

  /// Clear existing meal plans for date range
  static Future<void> clearMealPlansForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    await StorageService.deleteMealPlansInDateRange(startDate, endDate);
  }

  /// Generate smart meal plan based on user goals and preferences
  static Future<List<MealPlan>> generateSmartMealPlan({
    required int days,
    required DateTime startDate,
    bool balanceMacros = true,
    bool includeRecipes = true,
    bool prioritizeVariety = true,
  }) async {
    // This is an enhanced version that considers macro balance
    final profile = StorageService.getUserProfile();
    if (profile == null) {
      throw Exception('User profile not found');
    }

    final allFoods = StorageService.getAllFoodItems();
    final filteredFoods = _filterFoodsByDietType(allFoods, profile.dietType);

    if (filteredFoods.isEmpty) {
      throw Exception('No suitable foods found for your diet type');
    }

    // Generate basic meal plan
    final mealPlans = await generateMealPlan(
      days: days,
      startDate: startDate,
      includeRecipes: includeRecipes,
      avoidRepetition: prioritizeVariety,
    );

    // If macro balancing is enabled, try to adjust selections
    if (balanceMacros) {
      // This is a placeholder for future macro balancing logic
      // Could analyze daily totals and swap foods to better match targets
    }

    return mealPlans;
  }
}
