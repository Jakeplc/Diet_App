import 'package:flutter/material.dart';
import '../models/heart_rate_log.dart';

class HeartRateService {
  static final List<HeartRateLog> _heartRateLogs = [
    HeartRateLog(
      id: '1',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      bpm: 68,
      source: 'manual',
      activityType: 'resting',
    ),
    HeartRateLog(
      id: '2',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      bpm: 145,
      source: 'wearable',
      activityType: 'intense',
    ),
    HeartRateLog(
      id: '3',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      bpm: 72,
      source: 'manual',
      activityType: 'resting',
    ),
    HeartRateLog(
      id: '4',
      timestamp: DateTime.now(),
      bpm: 78,
      source: 'wearable',
      activityType: 'light',
    ),
  ];

  static Future<void> logHeartRate(HeartRateLog log) async {
    _heartRateLogs.add(log);
  }

  static Future<List<HeartRateLog>> getHeartRateLogs(int hours) async {
    final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
    return _heartRateLogs
        .where((log) => log.timestamp.isAfter(cutoffTime))
        .toList();
  }

  static Future<Map<String, dynamic>> getHeartRateStats(int hours) async {
    final logs = await getHeartRateLogs(hours);
    if (logs.isEmpty) {
      return {
        'averageBpm': 0,
        'maxBpm': 0,
        'minBpm': 0,
        'restingBpm': 0,
        'hrv': 0,
      };
    }

    final bpms = logs.map((l) => l.bpm).toList();
    final average = bpms.reduce((a, b) => a + b) ~/ bpms.length;
    final max = bpms.reduce((a, b) => a > b ? a : b);
    final min = bpms.reduce((a, b) => a < b ? a : b);

    final restingLogs = logs.where((l) => l.activityType == 'resting').toList();
    final restingBpm = restingLogs.isNotEmpty
        ? restingLogs.map((l) => l.bpm).reduce((a, b) => a + b) ~/
              restingLogs.length
        : average;

    // HRV (Heart Rate Variability) - simplified calculation
    final hrv = (max - min).toDouble();

    return {
      'averageBpm': average,
      'maxBpm': max,
      'minBpm': min,
      'restingBpm': restingBpm,
      'hrv': hrv.toStringAsFixed(1),
      'totalReadings': logs.length,
    };
  }

  static String getHRZone(int bpm) {
    if (bpm < 100) return 'Resting';
    if (bpm < 120) return 'Light';
    if (bpm < 150) return 'Moderate';
    if (bpm < 170) return 'Intense';
    return 'Maximum';
  }

  static String getHRZoneEmoji(int bpm) {
    if (bpm < 100) return '😴';
    if (bpm < 120) return '🚶';
    if (bpm < 150) return '🏃';
    if (bpm < 170) return '🏋️';
    return '⚡';
  }

  static Color getHRZoneColor(int bpm) {
    if (bpm < 100) return Colors.blue;
    if (bpm < 120) return Colors.green;
    if (bpm < 150) return Colors.yellow;
    if (bpm < 170) return Colors.orange;
    return Colors.red;
  }
}
