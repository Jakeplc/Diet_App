import '../models/activity_log.dart';

class HealthIntegrationService {
  // In production, this would use:
  // - health package for Apple Health
  // - google_fit package for Google Fit
  // For MVP, we'll simulate data

  static final List<WearableDevice> _availableDevices = [
    WearableDevice(
      id: 'apple_health',
      name: 'Apple Health',
      platform: 'apple_health',
      isConnected: false,
      icon: 'ðŸŽ',
    ),
    WearableDevice(
      id: 'google_fit',
      name: 'Google Fit',
      platform: 'google_fit',
      isConnected: false,
      icon: 'ðŸ”´',
    ),
  ];

  // Simulated activity data
  static final List<ActivityLog> _simulatedActivities = [
    ActivityLog(
      id: '1',
      activityType: 'Running',
      date: DateTime.now().subtract(const Duration(days: 2)),
      durationMinutes: 30,
      caloriesBurned: 350,
      steps: 5000,
      distance: 5.2,
      source: 'google_fit',
      intensity: 'vigorous',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ActivityLog(
      id: '2',
      activityType: 'Walking',
      date: DateTime.now().subtract(const Duration(days: 1)),
      durationMinutes: 45,
      caloriesBurned: 200,
      steps: 7500,
      distance: 3.2,
      source: 'google_fit',
      intensity: 'moderate',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ActivityLog(
      id: '3',
      activityType: 'Cycling',
      date: DateTime.now(),
      durationMinutes: 60,
      caloriesBurned: 400,
      steps: 0,
      distance: 15.0,
      source: 'apple_health',
      intensity: 'moderate',
      createdAt: DateTime.now(),
    ),
  ];

  // Get available wearable devices
  static Future<List<WearableDevice>> getAvailableDevices() async {
    // In production, check actual platform availability
    return _availableDevices;
  }

  // Connect to a wearable device
  static Future<bool> connectDevice(String deviceId) async {
    try {
      // In production, this would trigger OAuth flow for Google Fit
      // or request Apple Health permissions
      await Future.delayed(const Duration(seconds: 2)); // Simulate connection

      final index = _availableDevices.indexWhere((d) => d.id == deviceId);
      if (index != -1) {
        _availableDevices[index] = WearableDevice(
          id: _availableDevices[index].id,
          name: _availableDevices[index].name,
          platform: _availableDevices[index].platform,
          isConnected: true,
          lastSyncTime: DateTime.now(),
          icon: _availableDevices[index].icon,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Disconnect from a wearable device
  static Future<bool> disconnectDevice(String deviceId) async {
    try {
      final index = _availableDevices.indexWhere((d) => d.id == deviceId);
      if (index != -1) {
        _availableDevices[index] = WearableDevice(
          id: _availableDevices[index].id,
          name: _availableDevices[index].name,
          platform: _availableDevices[index].platform,
          isConnected: false,
          icon: _availableDevices[index].icon,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Sync activities from connected devices
  static Future<List<ActivityLog>> syncActivities() async {
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate sync

      // Update last sync time for connected devices
      for (int i = 0; i < _availableDevices.length; i++) {
        if (_availableDevices[i].isConnected) {
          _availableDevices[i] = WearableDevice(
            id: _availableDevices[i].id,
            name: _availableDevices[i].name,
            platform: _availableDevices[i].platform,
            isConnected: true,
            lastSyncTime: DateTime.now(),
            icon: _availableDevices[i].icon,
          );
        }
      }

      return _simulatedActivities;
    } catch (e) {
      return [];
    }
  }

  // Get recent activities
  static Future<List<ActivityLog>> getRecentActivities({int days = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _simulatedActivities
        .where((a) => a.date.isAfter(cutoffDate))
        .toList();
  }

  // Get total activity calories for a date range
  static Future<int> getTotalActivityCalories({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    int total = 0;
    for (final activity in _simulatedActivities) {
      if (activity.date.isAfter(startDate) && activity.date.isBefore(endDate)) {
        total += activity.caloriesBurned;
      }
    }
    return total;
  }

  // Get total steps for a date
  static Future<int> getDailySteps(DateTime date) async {
    int total = 0;
    for (final activity in _simulatedActivities) {
      if (activity.date.year == date.year &&
          activity.date.month == date.month &&
          activity.date.day == date.day) {
        total += activity.steps;
      }
    }
    return total;
  }

  // Get connected devices
  static List<WearableDevice> getConnectedDevices() {
    return _availableDevices.where((d) => d.isConnected).toList();
  }

  // Get device by ID
  static WearableDevice? getDevice(String deviceId) {
    try {
      return _availableDevices.firstWhere((d) => d.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  // Get activity stats for dashboard
  static Future<Map<String, dynamic>> getActivityStats() async {
    final today = DateTime.now();

    final weeklyActivities = await getRecentActivities(days: 7);
    final todayActivities = weeklyActivities
        .where(
          (a) =>
              a.date.year == today.year &&
              a.date.month == today.month &&
              a.date.day == today.day,
        )
        .toList();

    final totalCaloriesThisWeek = weeklyActivities.fold(
      0,
      (sum, activity) => sum + activity.caloriesBurned,
    );

    final totalStepsThisWeek = weeklyActivities.fold(
      0,
      (sum, activity) => sum + activity.steps,
    );

    return {
      'todayCalories': todayActivities.fold(
        0,
        (sum, a) => sum + a.caloriesBurned,
      ),
      'todayActivities': todayActivities.length,
      'weeklyCalories': totalCaloriesThisWeek,
      'weeklyActivities': weeklyActivities.length,
      'weeklySteps': totalStepsThisWeek,
      'averageDailyCalories': totalCaloriesThisWeek ~/ 7,
    };
  }
}
