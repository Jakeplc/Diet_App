import 'package:uuid/uuid.dart';
import '../models/shopping_item.dart';
import '../models/meal_plan.dart';
import '../models/food_item.dart';
import 'storage_service.dart';

class ShoppingListService {
  /// Generate shopping list from meal plans
  static Future<List<ShoppingItem>> generateShoppingList({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get meal plans for the date range
    final allMealPlans = StorageService.getAllMealPlans();

    final relevantPlans = allMealPlans.where((plan) {
      return plan.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          plan.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    if (relevantPlans.isEmpty) {
      return [];
    }

    // Collect all food items from meal plans
    final Map<String, ShoppingItemData> itemMap = {};

    for (final plan in relevantPlans) {
      for (final foodId in plan.foodItemIds) {
        final food = StorageService.getFoodItemById(foodId);
        if (food != null) {
          final key = food.name.toLowerCase();

          if (itemMap.containsKey(key)) {
            // Increment quantity
            itemMap[key]!.quantity += 1.0;
            itemMap[key]!.mealPlanIds.add(plan.id);
          } else {
            // Add new item
            itemMap[key] = ShoppingItemData(
              name: food.name,
              category: _categorizeFood(food),
              quantity: 1.0,
              unit: _determineUnit(food),
              mealPlanIds: [plan.id],
            );
          }
        }
      }
    }

    // Convert to shopping items
    final shoppingItems = <ShoppingItem>[];
    const uuid = Uuid();

    itemMap.forEach((key, data) {
      shoppingItems.add(
        ShoppingItem(
          id: uuid.v4(),
          name: data.name,
          category: data.category,
          quantity: data.quantity,
          unit: data.unit,
          mealPlanIds: data.mealPlanIds,
        ),
      );
    });

    // Sort by category
    shoppingItems.sort((a, b) {
      final categoryOrder = _getCategoryOrder();
      final aOrder = categoryOrder[a.category] ?? 999;
      final bOrder = categoryOrder[b.category] ?? 999;

      if (aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }
      return a.name.compareTo(b.name);
    });

    return shoppingItems;
  }

  /// Generate shopping list from specific meal plans
  static Future<List<ShoppingItem>> generateFromMealPlans(
    List<MealPlan> mealPlans,
  ) async {
    if (mealPlans.isEmpty) {
      return [];
    }

    final Map<String, ShoppingItemData> itemMap = {};

    for (final plan in mealPlans) {
      for (final foodId in plan.foodItemIds) {
        final food = StorageService.getFoodItemById(foodId);
        if (food != null) {
          final key = food.name.toLowerCase();

          if (itemMap.containsKey(key)) {
            itemMap[key]!.quantity += 1.0;
            itemMap[key]!.mealPlanIds.add(plan.id);
          } else {
            itemMap[key] = ShoppingItemData(
              name: food.name,
              category: _categorizeFood(food),
              quantity: 1.0,
              unit: _determineUnit(food),
              mealPlanIds: [plan.id],
            );
          }
        }
      }
    }

    final shoppingItems = <ShoppingItem>[];
    const uuid = Uuid();

    itemMap.forEach((key, data) {
      shoppingItems.add(
        ShoppingItem(
          id: uuid.v4(),
          name: data.name,
          category: data.category,
          quantity: data.quantity,
          unit: data.unit,
          mealPlanIds: data.mealPlanIds,
        ),
      );
    });

    shoppingItems.sort((a, b) {
      final categoryOrder = _getCategoryOrder();
      final aOrder = categoryOrder[a.category] ?? 999;
      final bOrder = categoryOrder[b.category] ?? 999;

      if (aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }
      return a.name.compareTo(b.name);
    });

    return shoppingItems;
  }

  /// Categorize food item for shopping list
  static String _categorizeFood(FoodItem food) {
    final name = food.name.toLowerCase();
    final category = food.category.toLowerCase();

    // Produce
    if (category.contains('fruit') ||
        category.contains('vegetable') ||
        name.contains('apple') ||
        name.contains('banana') ||
        name.contains('orange') ||
        name.contains('lettuce') ||
        name.contains('tomato') ||
        name.contains('spinach') ||
        name.contains('broccoli')) {
      return 'Produce';
    }

    // Protein
    if (category.contains('protein') ||
        category.contains('meat') ||
        name.contains('chicken') ||
        name.contains('beef') ||
        name.contains('fish') ||
        name.contains('turkey') ||
        name.contains('pork') ||
        name.contains('egg')) {
      return 'Protein';
    }

    // Dairy
    if (category.contains('dairy') ||
        name.contains('milk') ||
        name.contains('cheese') ||
        name.contains('yogurt') ||
        name.contains('butter') ||
        name.contains('cream')) {
      return 'Dairy';
    }

    // Grains & Bread
    if (category.contains('grain') ||
        name.contains('bread') ||
        name.contains('rice') ||
        name.contains('pasta') ||
        name.contains('oat') ||
        name.contains('cereal') ||
        name.contains('flour')) {
      return 'Grains';
    }

    // Snacks
    if (category.contains('snack') ||
        name.contains('chip') ||
        name.contains('cookie') ||
        name.contains('cracker') ||
        name.contains('nut') ||
        name.contains('seed')) {
      return 'Snacks';
    }

    // Beverages
    if (category.contains('beverage') ||
        name.contains('juice') ||
        name.contains('soda') ||
        name.contains('water') ||
        name.contains('coffee') ||
        name.contains('tea')) {
      return 'Beverages';
    }

    // Frozen
    if (category.contains('frozen') || name.contains('frozen')) {
      return 'Frozen';
    }

    return 'Other';
  }

  /// Determine appropriate unit for food item
  static String _determineUnit(FoodItem food) {
    final name = food.name.toLowerCase();

    if (name.contains('egg')) return 'dozen';
    if (name.contains('milk') || name.contains('juice')) return 'gallon';
    if (name.contains('bread') || name.contains('loaf')) return 'loaf';
    if (name.contains('apple') ||
        name.contains('banana') ||
        name.contains('orange')) {
      return 'lbs';
    }
    if (name.contains('chicken') ||
        name.contains('beef') ||
        name.contains('fish')) {
      return 'lbs';
    }
    if (name.contains('cheese')) return 'oz';
    if (name.contains('yogurt')) return 'container';

    return 'serving';
  }

  /// Get category ordering for sorting
  static Map<String, int> _getCategoryOrder() {
    return {
      'Produce': 1,
      'Protein': 2,
      'Dairy': 3,
      'Grains': 4,
      'Frozen': 5,
      'Snacks': 6,
      'Beverages': 7,
      'Other': 8,
    };
  }

  /// Get all categories
  static List<String> getCategories() {
    return [
      'Produce',
      'Protein',
      'Dairy',
      'Grains',
      'Frozen',
      'Snacks',
      'Beverages',
      'Other',
    ];
  }

  /// Format shopping list as plain text for sharing
  static String formatAsText(List<ShoppingItem> items) {
    if (items.isEmpty) {
      return 'Shopping List is empty';
    }

    final buffer = StringBuffer();
    buffer.writeln('🛒 Shopping List');
    buffer.writeln('=' * 40);
    buffer.writeln();

    // Group by category
    final categories = getCategories();
    for (final category in categories) {
      final categoryItems = items
          .where((item) => item.category == category && !item.isChecked)
          .toList();

      if (categoryItems.isNotEmpty) {
        buffer.writeln('📌 $category');
        buffer.writeln('-' * 40);

        for (final item in categoryItems) {
          final quantityStr = item.quantity == item.quantity.toInt()
              ? item.quantity.toInt().toString()
              : item.quantity.toStringAsFixed(1);
          buffer.writeln('  ☐ ${item.name} - $quantityStr ${item.unit}');
        }
        buffer.writeln();
      }
    }

    // Show checked items separately
    final checkedItems = items.where((item) => item.isChecked).toList();
    if (checkedItems.isNotEmpty) {
      buffer.writeln('✓ Checked Items (${checkedItems.length})');
      buffer.writeln('-' * 40);
      for (final item in checkedItems) {
        buffer.writeln('  ☑ ${item.name}');
      }
    }

    return buffer.toString();
  }
}

/// Helper class for aggregating shopping items
class ShoppingItemData {
  final String name;
  final String category;
  double quantity;
  final String unit;
  final List<String> mealPlanIds;

  ShoppingItemData({
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.mealPlanIds,
  });
}
