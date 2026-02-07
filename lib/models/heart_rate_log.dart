class HeartRateLog {
  final String id;
  final DateTime timestamp;
  final int bpm; // beats per minute
  final String source; // 'manual', 'apple_health', 'google_fit', 'wearable'
  final String? activityType; // 'resting', 'light', 'moderate', 'intense'

  HeartRateLog({
    required this.id,
    required this.timestamp,
    required this.bpm,
    required this.source,
    this.activityType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'bpm': bpm,
      'source': source,
      'activityType': activityType,
    };
  }

  static HeartRateLog fromMap(Map<String, dynamic> map) {
    return HeartRateLog(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      bpm: map['bpm'] as int,
      source: map['source'] as String,
      activityType: map['activityType'] as String?,
    );
  }
}
