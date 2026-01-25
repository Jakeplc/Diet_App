import '../models/sleep_log.dart';

class SleepTrackingService {
  // Simulated sleep data
  static final List<SleepLog> _sleepLogs = [
    SleepLog(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 3)),
      durationMinutes: 450, // 7.5 hours
      bedtime: 2300,
      wakeTime: 630,
      quality: 'excellent',
      deepSleepMinutes: 135,
      remMinutes: 90,
      source: 'manual',
      tags: ['good_hydration', 'light_exercise'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    SleepLog(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 2)),
      durationMinutes: 420, // 7 hours
      bedtime: 2330,
      wakeTime: 700,
      quality: 'good',
      deepSleepMinutes: 120,
      remMinutes: 80,
      source: 'manual',
      tags: ['moderate_caffeine'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    SleepLog(
      id: '3',
      date: DateTime.now().subtract(const Duration(days: 1)),
      durationMinutes: 360, // 6 hours
      bedtime: 2400,
      wakeTime: 600,
      quality: 'fair',
      deepSleepMinutes: 100,
      remMinutes: 60,
      source: 'manual',
      tags: ['stress', 'late_meal'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static Future<void> logSleep(SleepLog sleep) async {
    _sleepLogs.add(sleep);
  }

  static Future<List<SleepLog>> getSleepLogs(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _sleepLogs.where((s) => s.date.isAfter(cutoffDate)).toList();
  }

  static Future<Map<String, dynamic>> getSleepStats(int days) async {
    final logs = await getSleepLogs(days);
    if (logs.isEmpty) {
      return {
        'averageDuration': 0,
        'totalNights': 0,
        'bestNight': 0,
        'qualityScore': 0,
      };
    }

    final totalMinutes = logs.fold<int>(
      0,
      (sum, log) => sum + log.durationMinutes,
    );
    final averageDuration = totalMinutes ~/ logs.length;

    final qualityScores = {'poor': 1, 'fair': 2, 'good': 3, 'excellent': 4};

    final totalQuality = logs.fold<int>(
      0,
      (sum, log) => sum + (qualityScores[log.quality] ?? 0),
    );
    final qualityScore = (totalQuality / logs.length).toStringAsFixed(1);

    final best = logs.fold<int>(
      0,
      (max, log) => log.durationMinutes > max ? log.durationMinutes : max,
    );

    return {
      'averageDuration': averageDuration,
      'totalNights': logs.length,
      'bestNight': best,
      'qualityScore': qualityScore,
    };
  }

  static String getQualityEmoji(String quality) {
    switch (quality) {
      case 'poor':
        return '😴';
      case 'fair':
        return '😐';
      case 'good':
        return '😊';
      case 'excellent':
        return '😴✨';
      default:
        return '😴';
    }
  }

  static String getQualityColor(String quality) {
    switch (quality) {
      case 'poor':
        return 'red';
      case 'fair':
        return 'amber';
      case 'good':
        return 'blue';
      case 'excellent':
        return 'green';
      default:
        return 'grey';
    }
  }

  static String formatTime(int time) {
    final hours = (time ~/ 100).toString().padLeft(2, '0');
    final minutes = (time % 100).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class StepCounterService {
  static final List<StepLog> _stepLogs = [
    StepLog(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 2)),
      steps: 8500,
      distance: 6.2,
      caloriesBurned: 350,
      source: 'google_fit',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    StepLog(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 1)),
      steps: 12000,
      distance: 8.5,
      caloriesBurned: 480,
      source: 'google_fit',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    StepLog(
      id: '3',
      date: DateTime.now(),
      steps: 5500,
      distance: 4.0,
      caloriesBurned: 220,
      source: 'google_fit',
      createdAt: DateTime.now(),
    ),
  ];

  static const int DAILY_GOAL = 10000;

  static Future<void> logSteps(StepLog steps) async {
    _stepLogs.add(steps);
  }

  static Future<List<StepLog>> getStepLogs(int days) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _stepLogs.where((s) => s.date.isAfter(cutoffDate)).toList();
  }

  static Future<StepLog?> getTodaySteps() async {
    try {
      final today = DateTime.now();
      return _stepLogs.firstWhere(
        (s) =>
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getStepStats(int days) async {
    final logs = await getStepLogs(days);
    if (logs.isEmpty) {
      return {
        'todaySteps': 0,
        'averageSteps': 0,
        'totalSteps': 0,
        'goalProgress': 0,
        'bestDay': 0,
      };
    }

    final today = await getTodaySteps();
    final totalSteps = logs.fold<int>(0, (sum, log) => sum + log.steps);
    final average = totalSteps ~/ logs.length;
    final best = logs.fold<int>(
      0,
      (max, log) => log.steps > max ? log.steps : max,
    );
    final goalProgress = ((today?.steps ?? 0) / DAILY_GOAL * 100).toInt();

    return {
      'todaySteps': today?.steps ?? 0,
      'averageSteps': average,
      'totalSteps': totalSteps,
      'goalProgress': goalProgress.clamp(0, 100),
      'bestDay': best,
    };
  }

  static int getGoalPercentage(int steps) {
    return ((steps / DAILY_GOAL) * 100).toInt().clamp(0, 100);
  }
}
