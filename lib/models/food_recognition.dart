class RecognizedFood {
  final String id;
  final String name;
  final double confidence; // 0.0 to 1.0
  final int caloriesPer100g;
  final double protein;
  final double carbs;
  final double fats;
  final String foodType; // fruit, vegetable, protein, grain, etc.
  final String servingSize;
  final int servingSizeGrams;

  RecognizedFood({
    required this.id,
    required this.name,
    required this.confidence,
    required this.caloriesPer100g,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.foodType,
    required this.servingSize,
    required this.servingSizeGrams,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'confidence': confidence,
      'caloriesPer100g': caloriesPer100g,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'foodType': foodType,
      'servingSize': servingSize,
      'servingSizeGrams': servingSizeGrams,
    };
  }

  static RecognizedFood fromMap(Map<String, dynamic> map) {
    return RecognizedFood(
      id: map['id'],
      name: map['name'],
      confidence: map['confidence'],
      caloriesPer100g: map['caloriesPer100g'],
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fats: (map['fats'] as num).toDouble(),
      foodType: map['foodType'],
      servingSize: map['servingSize'],
      servingSizeGrams: map['servingSizeGrams'],
    );
  }
}

class RecognitionResult {
  final List<RecognizedFood> suggestions;
  final String imagePath;
  final DateTime recognizedAt;
  final double processingTime; // in milliseconds

  RecognitionResult({
    required this.suggestions,
    required this.imagePath,
    required this.recognizedAt,
    required this.processingTime,
  });
}
