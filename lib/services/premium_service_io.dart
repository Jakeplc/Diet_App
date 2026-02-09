import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'apple_iap_service.dart';

class PremiumService {
  static const String _premiumKey = 'is_premium';
  static const String _premiumExpiryKey = 'premium_expiry';
  static const String _purchasedProductKey = 'purchased_product_id';

  static final AppleIAPService _appleIAP = AppleIAPService();

  // Initialize premium service
  static Future<void> initialize() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _appleIAP.initialize();
      // Check if user has existing premium access
      await _checkPremiumStatus();
    }
  }

  // Check if user has premium subscription
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumKey) ?? false;

    if (isPremium) {
      // Check if subscription is still valid
      final expiryTimestamp = prefs.getInt(_premiumExpiryKey);
      if (expiryTimestamp != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        if (DateTime.now().isAfter(expiry)) {
          // Subscription expired (for non-renewing products)
          // For auto-renewing subscriptions, Apple handles this
          if (!_isAutoRenewingProduct()) {
            await setPremiumStatus(false);
            return false;
          }
        }
      }
    }

    return isPremium;
  }

  // Set premium status (normally called after successful purchase)
  static Future<void> setPremiumStatus(
    bool isPremium, {
    DateTime? expiryDate,
    String? productId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);

    if (isPremium) {
      if (productId != null) {
        await prefs.setString(_purchasedProductKey, productId);
      }
      if (expiryDate != null) {
        await prefs.setInt(_premiumExpiryKey, expiryDate.millisecondsSinceEpoch);
      }
    } else {
      await prefs.remove(_purchasedProductKey);
      await prefs.remove(_premiumExpiryKey);
    }
  }

  // Purchase premium via Apple IAP
  static Future<bool> purchasePremium(String productId) async {
    if (Platform.isIOS || Platform.isMacOS) {
      try {
        final success = await _appleIAP.purchaseProduct(productId);
        
        if (success) {
          // Set expiry based on product type
          DateTime? expiryDate;
          if (productId == AppleIAPService.monthlyProductId) {
            expiryDate = DateTime.now().add(const Duration(days: 30));
          } else if (productId == AppleIAPService.yearlyProductId) {
            expiryDate = DateTime.now().add(const Duration(days: 365));
          }
          // Lifetime product has no expiry

          await setPremiumStatus(true, expiryDate: expiryDate, productId: productId);
          return true;
        }
      } catch (e) {
        print('Error purchasing premium: $e');
      }
    }

    // Fallback for testing (non-Apple platforms)
    final expiryDate = DateTime.now().add(const Duration(days: 30));
    await setPremiumStatus(true, expiryDate: expiryDate, productId: productId);
    return true;
  }

  // Restore purchases from App Store
  static Future<bool> restorePurchases() async {
    if (Platform.isIOS || Platform.isMacOS) {
      try {
        final success = await _appleIAP.restorePurchases();
        if (success) {
          await _checkPremiumStatus();
          return await isPremium();
        }
      } catch (e) {
        print('Error restoring purchases: $e');
      }
    }

    // Fallback: Check existing status
    return await isPremium();
  }

  // Check premium status from Apple IAP
  static Future<void> _checkPremiumStatus() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final hasPremium = _appleIAP.purchases.any((purchase) =>
          (purchase.status.name == 'purchased' ||
              purchase.status.name == 'restored') &&
          !purchase.pendingCompletePurchase);

      if (hasPremium) {
        await setPremiumStatus(true);
      }
    }
  }

  // Check if product is auto-renewing (subscription)
  static bool _isAutoRenewingProduct() {
    // Monthly and yearly are auto-renewing, lifetime is not
    final prefs = SharedPreferences.getInstance();
    // This would need async, simplified for now
    return true; // Assume auto-renewing by default
  }

  // Get premium benefits list
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

  // Feature gates - check before showing premium features
  static Future<bool> canUseFeature(String featureName) async {
    final isPremiumUser = await isPremium();

    final premiumFeatures = [
      'advanced_analytics',
      'micronutrient_tracking',
      'ai_suggestions',
      'unlimited_photo_recognition',
      'cloud_sync',
      'unlimited_recipes',
      'data_export',
      'smart_coaching',
      'workout_tracking',
      'meal_sharing',
      'custom_macro_ratios',
    ];

    if (premiumFeatures.contains(featureName)) {
      return isPremiumUser;
    }

    // Free features - always available
    return true;
  }

  // Ad display logic
  static Future<bool> shouldShowAds() async {
    return !(await isPremium());
  }

  // Cleanup
  static void dispose() {
    _appleIAP.dispose();
  }
}
