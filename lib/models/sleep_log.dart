class SleepLog {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final int bedtime; // 24-hour format (e.g., 2300 for 11 PM)
  final int wakeTime; // 24-hour format (e.g., 0700 for 7 AM)
  final String quality; // poor, fair, good, excellent
  final int? deepSleepMinutes;
  final int? remMinutes;
  final String source; // manual, wearable, apple_health, google_fit
  final List<String> tags; // exercise, caffeine, stress, etc.
  final DateTime createdAt;

  SleepLog({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.bedtime,
    required this.wakeTime,
    required this.quality,
    this.deepSleepMinutes,
    this.remMinutes,
    required this.source,
    this.tags = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'bedtime': bedtime,
      'wakeTime': wakeTime,
      'quality': quality,
      'deepSleepMinutes': deepSleepMinutes,
      'remMinutes': remMinutes,
      'source': source,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static SleepLog fromMap(Map<String, dynamic> map) {
    return SleepLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      durationMinutes: map['durationMinutes'],
      bedtime: map['bedtime'],
      wakeTime: map['wakeTime'],
      quality: map['quality'],
      deepSleepMinutes: map['deepSleepMinutes'],
      remMinutes: map['remMinutes'],
      source: map['source'],
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class StepLog {
  final String id;
  final DateTime date;
  final int steps;
  final double distance; // in km
  final int caloriesBurned;
  final String source; // google_fit, apple_health, manual
  final DateTime createdAt;

  StepLog({
    required this.id,
    required this.date,
    required this.steps,
    required this.distance,
    required this.caloriesBurned,
    required this.source,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'distance': distance,
      'caloriesBurned': caloriesBurned,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static StepLog fromMap(Map<String, dynamic> map) {
    return StepLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      steps: map['steps'],
      distance: (map['distance'] as num).toDouble(),
      caloriesBurned: map['caloriesBurned'],
      source: map['source'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
