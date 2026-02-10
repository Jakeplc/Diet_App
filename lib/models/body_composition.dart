class BodyComposition {
  String id;
  DateTime timestamp;
  double? bodyFatPercentage;
  double? muscleMass; // kg or lbs
  double? boneMass; // kg or lbs
  double? waterPercentage;
  double? visceralFat; // rating 1-59
  double? bmr; // Basal Metabolic Rate

  // Body measurements in cm or inches
  double? neck;
  double? chest;
  double? waist;
  double? hips;
  double? bicepLeft;
  double? bicepRight;
  double? forearmLeft;
  double? forearmRight;
  double? thighLeft;
  double? thighRight;
  double? calfLeft;
  double? calfRight;

  String? notes;
  String? photoPath;

  BodyComposition({
    required this.id,
    required this.timestamp,
    this.bodyFatPercentage,
    this.muscleMass,
    this.boneMass,
    this.waterPercentage,
    this.visceralFat,
    this.bmr,
    this.neck,
    this.chest,
    this.waist,
    this.hips,
    this.bicepLeft,
    this.bicepRight,
    this.forearmLeft,
    this.forearmRight,
    this.thighLeft,
    this.thighRight,
    this.calfLeft,
    this.calfRight,
    this.notes,
    this.photoPath,
  });

  String get dateKey {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'bodyFatPercentage': bodyFatPercentage,
      'muscleMass': muscleMass,
      'boneMass': boneMass,
      'waterPercentage': waterPercentage,
      'visceralFat': visceralFat,
      'bmr': bmr,
      'neck': neck,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'bicepLeft': bicepLeft,
      'bicepRight': bicepRight,
      'forearmLeft': forearmLeft,
      'forearmRight': forearmRight,
      'thighLeft': thighLeft,
      'thighRight': thighRight,
      'calfLeft': calfLeft,
      'calfRight': calfRight,
      'notes': notes,
      'photoPath': photoPath,
    };
  }

  factory BodyComposition.fromMap(Map<String, dynamic> map) {
    return BodyComposition(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      bodyFatPercentage: map['bodyFatPercentage']?.toDouble(),
      muscleMass: map['muscleMass']?.toDouble(),
      boneMass: map['boneMass']?.toDouble(),
      waterPercentage: map['waterPercentage']?.toDouble(),
      visceralFat: map['visceralFat']?.toDouble(),
      bmr: map['bmr']?.toDouble(),
      neck: map['neck']?.toDouble(),
      chest: map['chest']?.toDouble(),
      waist: map['waist']?.toDouble(),
      hips: map['hips']?.toDouble(),
      bicepLeft: map['bicepLeft']?.toDouble(),
      bicepRight: map['bicepRight']?.toDouble(),
      forearmLeft: map['forearmLeft']?.toDouble(),
      forearmRight: map['forearmRight']?.toDouble(),
      thighLeft: map['thighLeft']?.toDouble(),
      thighRight: map['thighRight']?.toDouble(),
      calfLeft: map['calfLeft']?.toDouble(),
      calfRight: map['calfRight']?.toDouble(),
      notes: map['notes'],
      photoPath: map['photoPath'],
    );
  }

  BodyComposition copyWith({
    String? id,
    DateTime? timestamp,
    double? bodyFatPercentage,
    double? muscleMass,
    double? boneMass,
    double? waterPercentage,
    double? visceralFat,
    double? bmr,
    double? neck,
    double? chest,
    double? waist,
    double? hips,
    double? bicepLeft,
    double? bicepRight,
    double? forearmLeft,
    double? forearmRight,
    double? thighLeft,
    double? thighRight,
    double? calfLeft,
    double? calfRight,
    String? notes,
    String? photoPath,
  }) {
    return BodyComposition(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      muscleMass: muscleMass ?? this.muscleMass,
      boneMass: boneMass ?? this.boneMass,
      waterPercentage: waterPercentage ?? this.waterPercentage,
      visceralFat: visceralFat ?? this.visceralFat,
      bmr: bmr ?? this.bmr,
      neck: neck ?? this.neck,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      bicepLeft: bicepLeft ?? this.bicepLeft,
      bicepRight: bicepRight ?? this.bicepRight,
      forearmLeft: forearmLeft ?? this.forearmLeft,
      forearmRight: forearmRight ?? this.forearmRight,
      thighLeft: thighLeft ?? this.thighLeft,
      thighRight: thighRight ?? this.thighRight,
      calfLeft: calfLeft ?? this.calfLeft,
      calfRight: calfRight ?? this.calfRight,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  // Calculate waist-to-hip ratio (WHR)
  double? get waistToHipRatio {
    if (waist != null && hips != null && hips! > 0) {
      return waist! / hips!;
    }
    return null;
  }

  // Get WHR category
  String getWHRCategory(String gender) {
    final whr = waistToHipRatio;
    if (whr == null) return 'Unknown';

    if (gender.toLowerCase() == 'male') {
      if (whr < 0.90) return 'Low Risk';
      if (whr < 0.95) return 'Moderate Risk';
      return 'High Risk';
    } else {
      if (whr < 0.80) return 'Low Risk';
      if (whr < 0.85) return 'Moderate Risk';
      return 'High Risk';
    }
  }

  // Get body fat percentage category
  String getBodyFatCategory(String gender, int age) {
    if (bodyFatPercentage == null) return 'Unknown';

    final bf = bodyFatPercentage!;

    if (gender.toLowerCase() == 'male') {
      if (age < 40) {
        if (bf < 8) return 'Essential Fat';
        if (bf < 20) return 'Fitness';
        if (bf < 25) return 'Average';
        return 'Obese';
      } else {
        if (bf < 8) return 'Essential Fat';
        if (bf < 22) return 'Fitness';
        if (bf < 28) return 'Average';
        return 'Obese';
      }
    } else {
      if (age < 40) {
        if (bf < 14) return 'Essential Fat';
        if (bf < 24) return 'Fitness';
        if (bf < 32) return 'Average';
        return 'Obese';
      } else {
        if (bf < 14) return 'Essential Fat';
        if (bf < 25) return 'Fitness';
        if (bf < 35) return 'Average';
        return 'Obese';
      }
    }
  }

  // Get visceral fat category
  String getVisceralFatCategory() {
    if (visceralFat == null) return 'Unknown';

    if (visceralFat! <= 12) return 'Healthy';
    if (visceralFat! <= 15) return 'Excess';
    return 'High';
  }
}
