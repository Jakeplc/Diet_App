import '../models/food_recognition.dart';

class FoodRecognitionService {
  // Simulated food database for recognition
  // In production, this would use TensorFlow Lite or Google ML Kit
  static final List<RecognizedFood> _foodDatabase = [
    RecognizedFood(
      id: '1',
      name: 'Chicken Breast',
      confidence: 0.95,
      caloriesPer100g: 165,
      protein: 31,
      carbs: 0,
      fats: 3.6,
      foodType: 'protein',
      servingSize: '100g (3.5 oz)',
      servingSizeGrams: 100,
    ),
    RecognizedFood(
      id: '2',
      name: 'Salmon',
      confidence: 0.92,
      caloriesPer100g: 208,
      protein: 20,
      carbs: 0,
      fats: 13,
      foodType: 'protein',
      servingSize: '100g (3.5 oz)',
      servingSizeGrams: 100,
    ),
    RecognizedFood(
      id: '3',
      name: 'Broccoli',
      confidence: 0.93,
      caloriesPer100g: 34,
      protein: 2.8,
      carbs: 7,
      fats: 0.4,
      foodType: 'vegetable',
      servingSize: '100g (cup)',
      servingSizeGrams: 100,
    ),
    RecognizedFood(
      id: '4',
      name: 'Brown Rice',
      confidence: 0.90,
      caloriesPer100g: 112,
      protein: 2.6,
      carbs: 24,
      fats: 0.9,
      foodType: 'grain',
      servingSize: '100g cooked',
      servingSizeGrams: 100,
    ),
    RecognizedFood(
      id: '5',
      name: 'Banana',
      confidence: 0.96,
      caloriesPer100g: 89,
      protein: 1.1,
      carbs: 23,
      fats: 0.3,
      foodType: 'fruit',
      servingSize: '1 medium (118g)',
      servingSizeGrams: 118,
    ),
    RecognizedFood(
      id: '6',
      name: 'Almonds',
      confidence: 0.88,
      caloriesPer100g: 579,
      protein: 21,
      carbs: 22,
      fats: 50,
      foodType: 'nut',
      servingSize: '28g (1 oz / 23 almonds)',
      servingSizeGrams: 28,
    ),
    RecognizedFood(
      id: '7',
      name: 'Apple',
      confidence: 0.94,
      caloriesPer100g: 52,
      protein: 0.3,
      carbs: 14,
      fats: 0.2,
      foodType: 'fruit',
      servingSize: '1 medium (182g)',
      servingSizeGrams: 182,
    ),
    RecognizedFood(
      id: '8',
      name: 'Egg',
      confidence: 0.91,
      caloriesPer100g: 155,
      protein: 13,
      carbs: 1.1,
      fats: 11,
      foodType: 'protein',
      servingSize: '1 large (50g)',
      servingSizeGrams: 50,
    ),
    RecognizedFood(
      id: '9',
      name: 'Sweet Potato',
      confidence: 0.89,
      caloriesPer100g: 86,
      protein: 1.6,
      carbs: 20,
      fats: 0.1,
      foodType: 'vegetable',
      servingSize: '100g baked',
      servingSizeGrams: 100,
    ),
    RecognizedFood(
      id: '10',
      name: 'Greek Yogurt',
      confidence: 0.92,
      caloriesPer100g: 59,
      protein: 10,
      carbs: 3.3,
      fats: 0.4,
      foodType: 'dairy',
      servingSize: '100g (3.5 oz)',
      servingSizeGrams: 100,
    ),
    RecognizedFood(
      id: '11',
      name: 'Avocado',
      confidence: 0.93,
      caloriesPer100g: 160,
      protein: 2,
      carbs: 9,
      fats: 15,
      foodType: 'fruit',
      servingSize: '100g (1/2 avocado)',
      servingSizeGrams: 100,
    ),
    RecognizedFood(
      id: '12',
      name: 'Spinach',
      confidence: 0.95,
      caloriesPer100g: 23,
      protein: 2.7,
      carbs: 3.6,
      fats: 0.4,
      foodType: 'vegetable',
      servingSize: '100g fresh',
      servingSizeGrams: 100,
    ),
    RecognizedFood(
      id: '13',
      name: 'Peanut Butter',
      confidence: 0.90,
      caloriesPer100g: 588,
      protein: 25,
      carbs: 20,
      fats: 50,
      foodType: 'nut',
      servingSize: '2 tbsp (32g)',
      servingSizeGrams: 32,
    ),
    RecognizedFood(
      id: '14',
      name: 'Blueberries',
      confidence: 0.91,
      caloriesPer100g: 57,
      protein: 0.7,
      carbs: 14,
      fats: 0.3,
      foodType: 'fruit',
      servingSize: '100g (3/4 cup)',
      servingSizeGrams: 100,
    ),
    RecognizedFood(
      id: '15',
      name: 'Oatmeal',
      confidence: 0.89,
      caloriesPer100g: 389,
      protein: 17,
      carbs: 66,
      fats: 6.9,
      foodType: 'grain',
      servingSize: '100g dry',
      servingSizeGrams: 100,
    ),
  ];

  // Recognize food from image (simulated AI)
  static Future<RecognitionResult> recognizeFood(String imagePath) async {
    final startTime = DateTime.now();

    // Simulate AI processing time
    await Future.delayed(const Duration(milliseconds: 1500));

    // Randomly select 2-4 foods from database as suggestions
    _foodDatabase.shuffle();
    final suggestionCount = 2 + (DateTime.now().millisecond % 3);
    final suggestions = _foodDatabase.take(suggestionCount).toList();

    final adjustedSuggestions = suggestions.asMap().entries.map((entry) {
      final index = entry.key;
      final food = entry.value;
      // First suggestion highest confidence, others lower
      final confidenceAdjustment = (1 - (index * 0.08));
      return RecognizedFood(
        id: food.id,
        name: food.name,
        confidence: (food.confidence * confidenceAdjustment).clamp(0.65, 0.99),
        caloriesPer100g: food.caloriesPer100g,
        protein: food.protein,
        carbs: food.carbs,
        fats: food.fats,
        foodType: food.foodType,
        servingSize: food.servingSize,
        servingSizeGrams: food.servingSizeGrams,
      );
    }).toList();

    final processingTime = DateTime.now()
        .difference(startTime)
        .inMilliseconds
        .toDouble();

    return RecognitionResult(
      suggestions: adjustedSuggestions,
      imagePath: imagePath,
      recognizedAt: DateTime.now(),
      processingTime: processingTime,
    );
  }

  // Get food details by ID
  static RecognizedFood? getFoodById(String id) {
    try {
      return _foodDatabase.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search foods by name
  static List<RecognizedFood> searchFoods(String query) {
    return _foodDatabase
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Get foods by type
  static List<RecognizedFood> getFoodsByType(String foodType) {
    return _foodDatabase.where((f) => f.foodType == foodType).toList();
  }

  // Get popular foods
  static List<RecognizedFood> getPopularFoods() {
    return _foodDatabase.take(10).toList();
  }

  // Calculate nutrition for custom serving size
  static Map<String, dynamic> calculateNutrition(
    RecognizedFood food,
    int servingSizeGrams,
  ) {
    final multiplier = servingSizeGrams / 100.0;

    return {
      'calories': (food.caloriesPer100g * multiplier).toInt(),
      'protein': (food.protein * multiplier).toStringAsFixed(1),
      'carbs': (food.carbs * multiplier).toStringAsFixed(1),
      'fats': (food.fats * multiplier).toStringAsFixed(1),
    };
  }

  // Get confidence level description
  static String getConfidenceLevel(double confidence) {
    if (confidence >= 0.90) return 'Very confident';
    if (confidence >= 0.80) return 'Confident';
    if (confidence >= 0.70) return 'Likely';
    return 'Uncertain';
  }
}
