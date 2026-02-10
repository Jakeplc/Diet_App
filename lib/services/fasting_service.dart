import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/fasting_session.dart';

class FastingService {
  static const String _boxName = 'fasting_sessions';
  static const String _activeSessionKey = 'active_session';
  static const _uuid = Uuid();

  /// Initialize the Hive box for fasting sessions
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  /// Start a new fasting session
  static Future<FastingSession> startFasting({
    required int targetHours,
    required String fastingType,
  }) async {
    await init();
    final box = Hive.box(_boxName);

    // End any active session first
    final activeSession = await getActiveSession();
    if (activeSession != null) {
      await endFasting(activeSession.id);
    }

    final session = FastingSession(
      id: _uuid.v4(),
      startTime: DateTime.now(),
      targetDurationHours: targetHours,
      fastingType: fastingType,
      isActive: true,
    );

    // Save as active session
    await box.put(_activeSessionKey, session.toMap());

    // Save to history
    await box.put('session_${session.id}', session.toMap());

    return session;
  }

  /// End the current fasting session
  static Future<FastingSession?> endFasting(String sessionId) async {
    await init();
    final box = Hive.box(_boxName);

    final sessionData = box.get('session_$sessionId');
    if (sessionData == null) return null;

    final session = FastingSession.fromMap(sessionData);
    final endedSession = session.copyWith(
      endTime: DateTime.now(),
      isActive: false,
      wasCompleted: session.isComplete,
    );

    // Update in history
    await box.put('session_$sessionId', endedSession.toMap());

    // Clear active session
    await box.delete(_activeSessionKey);

    return endedSession;
  }

  /// Get the current active fasting session
  static Future<FastingSession?> getActiveSession() async {
    await init();
    final box = Hive.box(_boxName);

    final sessionData = box.get(_activeSessionKey);
    if (sessionData == null) return null;

    final session = FastingSession.fromMap(sessionData);

    // Auto-end if session is really old (more than 48 hours)
    if (session.elapsedDuration.inHours > 48) {
      await endFasting(session.id);
      return null;
    }

    return session;
  }

  /// Update the active session (for UI refresh)
  static Future<FastingSession?> refreshActiveSession() async {
    return await getActiveSession();
  }

  /// Get all fasting sessions history
  static Future<List<FastingSession>> getHistory({int limit = 30}) async {
    await init();
    final box = Hive.box(_boxName);

    final sessions = <FastingSession>[];
    for (var key in box.keys) {
      if (key.toString().startsWith('session_')) {
        final sessionData = box.get(key);
        if (sessionData != null) {
          sessions.add(FastingSession.fromMap(sessionData));
        }
      }
    }

    // Sort by start time, newest first
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));

    return sessions.take(limit).toList();
  }

  /// Get completed fasting sessions count
  static Future<int> getCompletedCount() async {
    final history = await getHistory(limit: 1000);
    return history.where((s) => s.wasCompleted).length;
  }

  /// Get total fasting hours
  static Future<double> getTotalFastingHours() async {
    final history = await getHistory(limit: 1000);
    double totalHours = 0;
    for (var session in history) {
      totalHours += session.elapsedDuration.inMinutes / 60;
    }
    return totalHours;
  }

  /// Get average fasting duration
  static Future<double> getAverageFastingHours() async {
    final history = await getHistory(limit: 1000);
    if (history.isEmpty) return 0;

    double totalHours = 0;
    for (var session in history) {
      totalHours += session.elapsedDuration.inMinutes / 60;
    }
    return totalHours / history.length;
  }

  /// Get fasting streak (consecutive days with completed fasts)
  static Future<int> getCurrentStreak() async {
    final history = await getHistory(limit: 1000);
    if (history.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (var session in history) {
      if (!session.wasCompleted) continue;

      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (lastDate == null) {
        // First completed session
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final yesterday = todayDate.subtract(const Duration(days: 1));

        // Only count if it's today or yesterday
        if (sessionDate == todayDate || sessionDate == yesterday) {
          streak = 1;
          lastDate = sessionDate;
        } else {
          break; // Too old, no current streak
        }
      } else {
        // Check if consecutive day
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (sessionDate == expectedDate || sessionDate == lastDate) {
          if (sessionDate != lastDate) {
            streak++;
          }
          lastDate = sessionDate;
        } else {
          break; // Streak broken
        }
      }
    }

    return streak;
  }

  /// Delete a fasting session
  static Future<void> deleteSession(String sessionId) async {
    await init();
    final box = Hive.box(_boxName);
    await box.delete('session_$sessionId');

    // If it was the active session, clear that too
    final activeSession = await getActiveSession();
    if (activeSession?.id == sessionId) {
      await box.delete(_activeSessionKey);
    }
  }

  /// Clear all fasting history
  static Future<void> clearAllHistory() async {
    await init();
    final box = Hive.box(_boxName);
    await box.clear();
  }

  /// Get statistics for display
  static Future<Map<String, dynamic>> getStatistics() async {
    return {
      'totalCompleted': await getCompletedCount(),
      'totalHours': await getTotalFastingHours(),
      'averageHours': await getAverageFastingHours(),
      'currentStreak': await getCurrentStreak(),
    };
  }
}
