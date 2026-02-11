// Web / fallback implementation for PremiumService.
// Keeps the app running in Chrome without dart:io / Platform calls.

class PremiumService {
  static Future<void> initialize() async {}

  static Future<bool> isPremium() async => false;

  static List<String> getPremiumBenefits() {
    return [
      '🚫 Remove all ads',
      '📊 Advanced analytics & detailed reports',
      '🔬 Track micronutrients (vitamins & minerals)',
      '🤖 AI-powered meal suggestions',
      '📸 Unlimited food photo recognition',
      '☁️ Cloud sync across devices',
      '🍽️ Unlimited custom recipes',
      '📈 Export data to CSV/PDF',
      '⏰ Smart reminders & coaching tips',
      '💪 Workout & activity tracking',
      '👥 Share meal plans with friends',
      '🎯 Custom macro ratio targets',
    ];
  }

  static Future<bool> purchasePremium(String productId) async => false;

  static Future<bool> restorePurchases() async => false;

  static Future<bool> canUseFeature(String featureName) async => false;

  static Future<bool> shouldShowAds() async => true;

  // Optional compatibility helpers used by some screens.
  static Future<void> setPremium(bool value) async {}

  static Future<void> setPremiumExpiry(DateTime? expiry) async {}

  static Future<DateTime?> getPremiumExpiry() async => null;

  static Future<void> clearPremium() async {}
}
