class MicronutrientData {
  // Vitamins
  double vitaminA; // mcg
  double vitaminC; // mg
  double vitaminD; // mcg
  double vitaminE; // mg
  double vitaminK; // mcg
  double vitaminB1; // thiamine, mg
  double vitaminB2; // riboflavin, mg
  double vitaminB3; // niacin, mg
  double vitaminB6; // mg
  double vitaminB9; // folate, mcg
  double vitaminB12; // mcg

  // Minerals
  double calcium; // mg
  double iron; // mg
  double magnesium; // mg
  double phosphorus; // mg
  double potassium; // mg
  double sodium; // mg
  double zinc; // mg
  double copper; // mg
  double manganese; // mg
  double selenium; // mcg

  MicronutrientData({
    this.vitaminA = 0,
    this.vitaminC = 0,
    this.vitaminD = 0,
    this.vitaminE = 0,
    this.vitaminK = 0,
    this.vitaminB1 = 0,
    this.vitaminB2 = 0,
    this.vitaminB3 = 0,
    this.vitaminB6 = 0,
    this.vitaminB9 = 0,
    this.vitaminB12 = 0,
    this.calcium = 0,
    this.iron = 0,
    this.magnesium = 0,
    this.phosphorus = 0,
    this.potassium = 0,
    this.sodium = 0,
    this.zinc = 0,
    this.copper = 0,
    this.manganese = 0,
    this.selenium = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'vitaminA': vitaminA,
      'vitaminC': vitaminC,
      'vitaminD': vitaminD,
      'vitaminE': vitaminE,
      'vitaminK': vitaminK,
      'vitaminB1': vitaminB1,
      'vitaminB2': vitaminB2,
      'vitaminB3': vitaminB3,
      'vitaminB6': vitaminB6,
      'vitaminB9': vitaminB9,
      'vitaminB12': vitaminB12,
      'calcium': calcium,
      'iron': iron,
      'magnesium': magnesium,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'sodium': sodium,
      'zinc': zinc,
      'copper': copper,
      'manganese': manganese,
      'selenium': selenium,
    };
  }

  factory MicronutrientData.fromMap(Map<String, dynamic> map) {
    return MicronutrientData(
      vitaminA: (map['vitaminA'] ?? 0).toDouble(),
      vitaminC: (map['vitaminC'] ?? 0).toDouble(),
      vitaminD: (map['vitaminD'] ?? 0).toDouble(),
      vitaminE: (map['vitaminE'] ?? 0).toDouble(),
      vitaminK: (map['vitaminK'] ?? 0).toDouble(),
      vitaminB1: (map['vitaminB1'] ?? 0).toDouble(),
      vitaminB2: (map['vitaminB2'] ?? 0).toDouble(),
      vitaminB3: (map['vitaminB3'] ?? 0).toDouble(),
      vitaminB6: (map['vitaminB6'] ?? 0).toDouble(),
      vitaminB9: (map['vitaminB9'] ?? 0).toDouble(),
      vitaminB12: (map['vitaminB12'] ?? 0).toDouble(),
      calcium: (map['calcium'] ?? 0).toDouble(),
      iron: (map['iron'] ?? 0).toDouble(),
      magnesium: (map['magnesium'] ?? 0).toDouble(),
      phosphorus: (map['phosphorus'] ?? 0).toDouble(),
      potassium: (map['potassium'] ?? 0).toDouble(),
      sodium: (map['sodium'] ?? 0).toDouble(),
      zinc: (map['zinc'] ?? 0).toDouble(),
      copper: (map['copper'] ?? 0).toDouble(),
      manganese: (map['manganese'] ?? 0).toDouble(),
      selenium: (map['selenium'] ?? 0).toDouble(),
    );
  }

  MicronutrientData operator +(MicronutrientData other) {
    return MicronutrientData(
      vitaminA: vitaminA + other.vitaminA,
      vitaminC: vitaminC + other.vitaminC,
      vitaminD: vitaminD + other.vitaminD,
      vitaminE: vitaminE + other.vitaminE,
      vitaminK: vitaminK + other.vitaminK,
      vitaminB1: vitaminB1 + other.vitaminB1,
      vitaminB2: vitaminB2 + other.vitaminB2,
      vitaminB3: vitaminB3 + other.vitaminB3,
      vitaminB6: vitaminB6 + other.vitaminB6,
      vitaminB9: vitaminB9 + other.vitaminB9,
      vitaminB12: vitaminB12 + other.vitaminB12,
      calcium: calcium + other.calcium,
      iron: iron + other.iron,
      magnesium: magnesium + other.magnesium,
      phosphorus: phosphorus + other.phosphorus,
      potassium: potassium + other.potassium,
      sodium: sodium + other.sodium,
      zinc: zinc + other.zinc,
      copper: copper + other.copper,
      manganese: manganese + other.manganese,
      selenium: selenium + other.selenium,
    );
  }

  MicronutrientData operator *(double servings) {
    return MicronutrientData(
      vitaminA: vitaminA * servings,
      vitaminC: vitaminC * servings,
      vitaminD: vitaminD * servings,
      vitaminE: vitaminE * servings,
      vitaminK: vitaminK * servings,
      vitaminB1: vitaminB1 * servings,
      vitaminB2: vitaminB2 * servings,
      vitaminB3: vitaminB3 * servings,
      vitaminB6: vitaminB6 * servings,
      vitaminB9: vitaminB9 * servings,
      vitaminB12: vitaminB12 * servings,
      calcium: calcium * servings,
      iron: iron * servings,
      magnesium: magnesium * servings,
      phosphorus: phosphorus * servings,
      potassium: potassium * servings,
      sodium: sodium * servings,
      zinc: zinc * servings,
      copper: copper * servings,
      manganese: manganese * servings,
      selenium: selenium * servings,
    );
  }

  // Recommended Daily Allowances (RDA) for adults
  static Map<String, double> getRDA({
    required String gender,
    required int age,
  }) {
    // Simplified RDAs for adult males/females
    final isMale = gender.toLowerCase() == 'male';

    return {
      'vitaminA': isMale ? 900 : 700, // mcg
      'vitaminC': isMale ? 90 : 75, // mg
      'vitaminD': 15, // mcg
      'vitaminE': 15, // mg
      'vitaminK': isMale ? 120 : 90, // mcg
      'vitaminB1': isMale ? 1.2 : 1.1, // mg
      'vitaminB2': isMale ? 1.3 : 1.1, // mg
      'vitaminB3': isMale ? 16 : 14, // mg
      'vitaminB6': age >= 50 ? 1.7 : 1.3, // mg
      'vitaminB9': 400, // mcg
      'vitaminB12': 2.4, // mcg
      'calcium': age >= 50 ? 1200 : 1000, // mg
      'iron': isMale ? 8 : (age >= 50 ? 8 : 18), // mg
      'magnesium': isMale ? 420 : 320, // mg
      'phosphorus': 700, // mg
      'potassium': 3400, // mg
      'sodium': 2300, // mg (upper limit)
      'zinc': isMale ? 11 : 8, // mg
      'copper': 0.9, // mg
      'manganese': isMale ? 2.3 : 1.8, // mg
      'selenium': 55, // mcg
    };
  }

  // Get nutrient display info
  static Map<String, Map<String, String>> getNutrientInfo() {
    return {
      'vitaminA': {
        'name': 'Vitamin A',
        'unit': 'mcg',
        'category': 'vitamin',
        'icon': 'ðŸ‘ï¸',
      },
      'vitaminC': {
        'name': 'Vitamin C',
        'unit': 'mg',
        'category': 'vitamin',
        'icon': 'ðŸŠ',
      },
      'vitaminD': {
        'name': 'Vitamin D',
        'unit': 'mcg',
        'category': 'vitamin',
        'icon': 'â˜€ï¸',
      },
      'vitaminE': {
        'name': 'Vitamin E',
        'unit': 'mg',
        'category': 'vitamin',
        'icon': 'ðŸ¥œ',
      },
      'vitaminK': {
        'name': 'Vitamin K',
        'unit': 'mcg',
        'category': 'vitamin',
        'icon': 'ðŸ¥¬',
      },
      'vitaminB1': {
        'name': 'Vitamin B1',
        'unit': 'mg',
        'category': 'vitamin',
        'icon': 'ðŸŒ¾',
      },
      'vitaminB2': {
        'name': 'Vitamin B2',
        'unit': 'mg',
        'category': 'vitamin',
        'icon': 'ðŸ¥›',
      },
      'vitaminB3': {
        'name': 'Vitamin B3',
        'unit': 'mg',
        'category': 'vitamin',
        'icon': 'ðŸ—',
      },
      'vitaminB6': {
        'name': 'Vitamin B6',
        'unit': 'mg',
        'category': 'vitamin',
        'icon': 'ðŸŸ',
      },
      'vitaminB9': {
        'name': 'Folate (B9)',
        'unit': 'mcg',
        'category': 'vitamin',
        'icon': 'ðŸ¥¦',
      },
      'vitaminB12': {
        'name': 'Vitamin B12',
        'unit': 'mcg',
        'category': 'vitamin',
        'icon': 'ðŸ¥©',
      },
      'calcium': {
        'name': 'Calcium',
        'unit': 'mg',
        'category': 'mineral',
        'icon': 'ðŸ¦´',
      },
      'iron': {
        'name': 'Iron',
        'unit': 'mg',
        'category': 'mineral',
        'icon': 'ðŸ©¸',
      },
      'magnesium': {
        'name': 'Magnesium',
        'unit': 'mg',
        'category': 'mineral',
        'icon': 'ðŸ’ª',
      },
      'phosphorus': {
        'name': 'Phosphorus',
        'unit': 'mg',
        'category': 'mineral',
        'icon': 'ðŸ§ ',
      },
      'potassium': {
        'name': 'Potassium',
        'unit': 'mg',
        'category': 'mineral',
        'icon': 'ðŸŒ',
      },
      'sodium': {
        'name': 'Sodium',
        'unit': 'mg',
        'category': 'mineral',
        'icon': 'ðŸ§‚',
      },
      'zinc': {
        'name': 'Zinc',
        'unit': 'mg',
        'category': 'mineral',
        'icon': 'ðŸ›¡ï¸',
      },
      'copper': {
        'name': 'Copper',
        'unit': 'mg',
        'category': 'mineral',
        'icon': 'âš¡',
      },
      'manganese': {
        'name': 'Manganese',
        'unit': 'mg',
        'category': 'mineral',
        'icon': 'ðŸ”‹',
      },
      'selenium': {
        'name': 'Selenium',
        'unit': 'mcg',
        'category': 'mineral',
        'icon': 'ðŸ”¬',
      },
    };
  }
}
