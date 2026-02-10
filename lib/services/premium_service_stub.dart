// Web / fallback implementation for PremiumService.
// Keeps the app running in Chrome without dart:io / Platform calls.

class PremiumService {
  static Future<void> initialize() async {}

  static Future<bool> isPremium() async => false;

  static List<String> getPremiumBenefits() {
    return [
      'ðŸš« Remove all ads',
      'ðŸ“Š Advanced analytics & detailed reports',
      'ðŸ”¬ Track micronutrients (vitamins & minerals)',
      'ðŸ¤– AI-powered meal suggestions',
      'ðŸ“¸ Unlimited food photo recognition',
      'â˜ï¸ Cloud sync across devices',
      'ðŸ½ï¸ Unlimited custom recipes',
      'ðŸ“ˆ Export data to CSV/PDF',
      'â° Smart reminders & coaching tips',
      'ðŸ’ª Workout & activity tracking',
      'ðŸ‘¥ Share meal plans with friends',
      'ðŸŽ¯ Custom macro ratio targets',
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
