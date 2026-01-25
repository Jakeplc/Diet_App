import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../services/storage_service.dart';
import '../services/fasting_service.dart';

class AchievementService {
  static const String _boxName = 'achievements';
  static List<Achievement> _cachedAchievements = [];

  /// Initialize the service
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    await _loadAchievements();
  }

  /// Load all achievements from storage
  static Future<void> _loadAchievements() async {
    final box = Hive.box(_boxName);
    _cachedAchievements = [];

    for (var achievement in AchievementDefinitions.all) {
      final savedData = box.get(achievement.id);
      if (savedData != null) {
        _cachedAchievements.add(Achievement.fromMap(savedData));
      } else {
        // Initialize with default
        _cachedAchievements.add(achievement);
      }
    }
  }

  /// Get all achievements with current progress
  static Future<List<Achievement>> getAllAchievements() async {
    await init();
    await _updateAllProgress();
    return List.from(_cachedAchievements);
  }

  /// Get unlocked achievements
  static Future<List<Achievement>> getUnlockedAchievements() async {
    final all = await getAllAchievements();
    return all.where((a) => a.isUnlocked).toList();
  }

  /// Get locked achievements
  static Future<List<Achievement>> getLockedAchievements() async {
    final all = await getAllAchievements();
    return all.where((a) => !a.isUnlocked).toList();
  }

  /// Get achievements by category
  static Future<List<Achievement>> getByCategory(
    AchievementCategory category,
  ) async {
    final all = await getAllAchievements();
    return all.where((a) => a.category == category).toList();
  }

  /// Update progress for all achievements and check for unlocks
  static Future<List<Achievement>> _updateAllProgress() async {
    final updates = <Achievement>[];

    // Calculate current stats
    final stats = await _calculateStats();

    for (int i = 0; i < _cachedAchievements.length; i++) {
      final achievement = _cachedAchievements[i];
      if (achievement.isUnlocked) continue; // Skip already unlocked

      int currentProgress = 0;

      // Calculate progress based on achievement type
      switch (achievement.id) {
        // Streak achievements
        case 'streak_3':
        case 'streak_7':
        case 'streak_30':
        case 'streak_100':
          currentProgress = stats['currentStreak'] ?? 0;
          break;

        // Weight loss achievements
        case 'weight_5lb':
        case 'weight_10lb':
        case 'weight_25lb':
        case 'weight_50lb':
          currentProgress = (stats['totalWeightLost'] ?? 0).toInt();
          break;

        // Fasting achievements
        case 'fast_first':
        case 'fast_10':
        case 'fast_50':
          currentProgress = stats['completedFasts'] ?? 0;
          break;

        // Logging achievements
        case 'log_100':
        case 'log_500':
        case 'log_1000':
          currentProgress = stats['totalLogs'] ?? 0;
          break;

        // Goal achievements
        case 'goal_reached':
          currentProgress = stats['goalReached'] ?? 0;
          break;
        case 'calorie_target_7':
        case 'calorie_target_30':
          currentProgress = stats['calorieTargetDays'] ?? 0;
          break;

        // Milestone achievements
        case 'water_30':
          currentProgress = stats['waterLogDays'] ?? 0;
          break;
        case 'scan_50':
          currentProgress = stats['barcodeScans'] ?? 0;
          break;
        case 'recipe_10':
          currentProgress = stats['recipesCreated'] ?? 0;
          break;
      }

      // Update achievement with new progress
      final updated = achievement.copyWith(currentProgress: currentProgress);

      // Check if should unlock
      if (updated.canUnlock) {
        final unlocked = updated.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        await _saveAchievement(unlocked);
        _cachedAchievements[i] = unlocked;
        updates.add(unlocked);

        // Send notification
        await _sendUnlockNotification(unlocked);
      } else if (currentProgress != achievement.currentProgress) {
        // Just update progress
        await _saveAchievement(updated);
        _cachedAchievements[i] = updated;
      }
    }

    return updates; // Return newly unlocked achievements
  }

  /// Calculate all stats needed for achievements
  static Future<Map<String, dynamic>> _calculateStats() async {
    final stats = <String, dynamic>{};

    try {
      // Current streak - count consecutive days with logs
      DateTime checkDate = DateTime.now();
      int streak = 0;
      for (int i = 0; i < 365; i++) {
        final logs = StorageService.getFoodLogsForDate(checkDate);
        if (logs.isNotEmpty) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }
      stats['currentStreak'] = streak;

      // Total weight lost
      final weightLogs = StorageService.getAllWeightLogs();
      if (weightLogs.isNotEmpty) {
        weightLogs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final startWeight = weightLogs.first.weight;
        final currentWeight = weightLogs.last.weight;
        stats['totalWeightLost'] = (startWeight - currentWeight).abs();
      } else {
        stats['totalWeightLost'] = 0;
      }

      // Fasting stats
      final fastingStats = await FastingService.getStatistics();
      stats['completedFasts'] = fastingStats['totalCompleted'] ?? 0;

      // Total logs - count logs from last 365 days
      int totalLogs = 0;
      for (int i = 0; i < 365; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        totalLogs += StorageService.getFoodLogsForDate(date).length;
      }
      stats['totalLogs'] = totalLogs;

      // Goal reached - simplified to 0 for now
      stats['goalReached'] = 0;

      // Calorie target days - simplified
      stats['calorieTargetDays'] = 0;

      // Water log days - simplified
      stats['waterLogDays'] = 0;

      // Barcode scans - simplified to 0 for now (requires FoodItem lookup)
      stats['barcodeScans'] = 0;

      // Recipes created (custom foods count)
      final allFoods = StorageService.getAllFoodItems();
      stats['recipesCreated'] = allFoods.where((food) => food.isCustom).length;
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating achievement stats: $e');
      }
    }

    return stats;
  }

  /// Save achievement to storage
  static Future<void> _saveAchievement(Achievement achievement) async {
    final box = Hive.box(_boxName);
    await box.put(achievement.id, achievement.toMap());
  }

  /// Send unlock notification
  static Future<void> _sendUnlockNotification(Achievement achievement) async {
    // Notification for achievement unlock - optional implementation
    if (kDebugMode) {
      print('Achievement unlocked: ${achievement.name}');
    }
  }

  /// Manually check for new unlocks (call after major events)
  static Future<List<Achievement>> checkForUnlocks() async {
    await init();
    return await _updateAllProgress();
  }

  /// Get total unlocked count
  static Future<int> getUnlockedCount() async {
    final unlocked = await getUnlockedAchievements();
    return unlocked.length;
  }

  /// Get completion percentage
  static Future<double> getCompletionPercentage() async {
    final all = await getAllAchievements();
    final unlocked = all.where((a) => a.isUnlocked).length;
    return (unlocked / all.length * 100);
  }

  /// Reset all achievements (for testing)
  static Future<void> resetAll() async {
    final box = Hive.box(_boxName);
    await box.clear();
    await _loadAchievements();
  }
}
