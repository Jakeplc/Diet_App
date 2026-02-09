// Web / fallback implementation for NotificationService.
// flutter_local_notifications is not supported on web in the same way as mobile.

class NotificationService {
  static Future<void> init() async {}

  // Legacy name kept for compatibility with older calls.
  static Future<void> initialize() async {
    await init();
  }

  static Future<void> scheduleMealReminders({
    bool breakfast = true,
    bool lunch = true,
    bool dinner = true,
    bool water = true,
  }) async {}

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {}

  static Future<void> cancelAllNotifications() async {}

  // Legacy no-op helpers kept for compatibility.
  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {}

  static Future<void> cancel(int id) async {}

  static Future<void> cancelAll() async {}
}
