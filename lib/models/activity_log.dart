class ActivityLog {
  final String id;
  final String activityType; // running, walking, cycling, workout, etc.
  final DateTime date;
  final int durationMinutes;
  final int caloriesBurned;
  final int steps; // if applicable
  final double distance; // in km
  final String source; // apple_health, google_fit, manual
  final String intensity; // light, moderate, vigorous
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.activityType,
    required this.date,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.steps,
    required this.distance,
    required this.source,
    required this.intensity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activityType': activityType,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'steps': steps,
      'distance': distance,
      'source': source,
      'intensity': intensity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ActivityLog fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'],
      activityType: map['activityType'],
      date: DateTime.parse(map['date']),
      durationMinutes: map['durationMinutes'],
      caloriesBurned: map['caloriesBurned'],
      steps: map['steps'] ?? 0,
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      source: map['source'],
      intensity: map['intensity'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class WearableDevice {
  final String id;
  final String name;
  final String platform; // apple_health, google_fit
  final bool isConnected;
  final DateTime? lastSyncTime;
  final String icon; // emoji

  WearableDevice({
    required this.id,
    required this.name,
    required this.platform,
    required this.isConnected,
    this.lastSyncTime,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'platform': platform,
      'isConnected': isConnected,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'icon': icon,
    };
  }

  static WearableDevice fromMap(Map<String, dynamic> map) {
    return WearableDevice(
      id: map['id'],
      name: map['name'],
      platform: map['platform'],
      isConnected: map['isConnected'],
      lastSyncTime: map['lastSyncTime'] != null
          ? DateTime.parse(map['lastSyncTime'])
          : null,
      icon: map['icon'],
    );
  }
}
