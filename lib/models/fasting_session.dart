/// Model for an intermittent fasting session
class FastingSession {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final int targetDurationHours;
  final String fastingType; // '16:8', '18:6', '20:4', '24:0', 'custom'
  final bool isActive;
  final bool wasCompleted;

  FastingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.targetDurationHours,
    required this.fastingType,
    required this.isActive,
    this.wasCompleted = false,
  });

  /// Calculate the target end time
  DateTime get targetEndTime =>
      startTime.add(Duration(hours: targetDurationHours));

  /// Get the elapsed duration
  Duration get elapsedDuration {
    final now = DateTime.now();
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return now.difference(startTime);
  }

  /// Get the remaining duration
  Duration get remainingDuration {
    final now = DateTime.now();
    final target = targetEndTime;
    if (now.isAfter(target)) {
      return Duration.zero;
    }
    return target.difference(now);
  }

  /// Check if the fast is complete
  bool get isComplete {
    final now = DateTime.now();
    return now.isAfter(targetEndTime) || (endTime != null && wasCompleted);
  }

  /// Get progress percentage (0-100)
  double get progressPercentage {
    final elapsed = elapsedDuration.inMinutes;
    final target = targetDurationHours * 60;
    final progress = (elapsed / target * 100).clamp(0, 100);
    return progress.toDouble();
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'targetDurationHours': targetDurationHours,
      'fastingType': fastingType,
      'isActive': isActive,
      'wasCompleted': wasCompleted,
    };
  }

  /// Create from Map
  factory FastingSession.fromMap(Map<String, dynamic> map) {
    return FastingSession(
      id: map['id'] ?? '',
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      targetDurationHours: map['targetDurationHours'] ?? 16,
      fastingType: map['fastingType'] ?? '16:8',
      isActive: map['isActive'] ?? false,
      wasCompleted: map['wasCompleted'] ?? false,
    );
  }

  /// Create a copy with updated fields
  FastingSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? targetDurationHours,
    String? fastingType,
    bool? isActive,
    bool? wasCompleted,
  }) {
    return FastingSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      targetDurationHours: targetDurationHours ?? this.targetDurationHours,
      fastingType: fastingType ?? this.fastingType,
      isActive: isActive ?? this.isActive,
      wasCompleted: wasCompleted ?? this.wasCompleted,
    );
  }
}

/// Predefined fasting schedules
class FastingPreset {
  final String name;
  final int fastingHours;
  final int eatingHours;
  final String description;
  final String difficulty;

  const FastingPreset({
    required this.name,
    required this.fastingHours,
    required this.eatingHours,
    required this.description,
    required this.difficulty,
  });

  String get displayName => '$fastingHours:$eatingHours';

  static const List<FastingPreset> presets = [
    FastingPreset(
      name: '16:8 (Beginner)',
      fastingHours: 16,
      eatingHours: 8,
      description:
          'Fast for 16 hours, eat within 8 hours. Great for beginners.',
      difficulty: 'Easy',
    ),
    FastingPreset(
      name: '18:6 (Intermediate)',
      fastingHours: 18,
      eatingHours: 6,
      description: 'Fast for 18 hours, eat within 6 hours. More challenging.',
      difficulty: 'Medium',
    ),
    FastingPreset(
      name: '20:4 (Advanced)',
      fastingHours: 20,
      eatingHours: 4,
      description: 'Fast for 20 hours, eat within 4 hours. The Warrior Diet.',
      difficulty: 'Hard',
    ),
    FastingPreset(
      name: '23:1 (OMAD)',
      fastingHours: 23,
      eatingHours: 1,
      description: 'One meal a day. Very advanced fasting protocol.',
      difficulty: 'Very Hard',
    ),
    FastingPreset(
      name: '12:12 (Easy Start)',
      fastingHours: 12,
      eatingHours: 12,
      description:
          'Fast for 12 hours, eat for 12 hours. Perfect for beginners.',
      difficulty: 'Very Easy',
    ),
    FastingPreset(
      name: '14:10 (Moderate)',
      fastingHours: 14,
      eatingHours: 10,
      description: 'Fast for 14 hours, eat within 10 hours. Steady progress.',
      difficulty: 'Easy',
    ),
  ];
}
