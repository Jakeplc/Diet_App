import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/premium_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/paywall_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage (Hive)
  try {
    await StorageService.init();
  } catch (e) {
    debugPrint('Storage initialization failed: $e');
  }

  // Initialize notifications (guarded per platform)
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Notification initialization skipped: $e');
  }

  // Initialize premium service (Apple IAP)
  try {
    await PremiumService.initialize();
  } catch (e) {
    debugPrint('Premium service initialization failed: $e');
  }

  // Set custom error widget
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text('Error: ${details.exception}'))),
    );
  };

  runApp(const DietApp());
}

class DietApp extends StatefulWidget {
  const DietApp({super.key});

  @override
  State<DietApp> createState() => _DietAppState();
}

class _DietAppState extends State<DietApp> {
  EmberThemeMode _emberThemeMode = EmberThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeFromStorage();
  }

  void _loadThemeFromStorage() {
    // Load saved theme preference or default to light
    final profile = StorageService.getUserProfile();
    if (profile != null) {
      // Default to feminine if female, light otherwise
      setState(() {
        _emberThemeMode = profile.gender.toLowerCase() == 'female'
            ? EmberThemeMode.feminine
            : EmberThemeMode.light;
      });
    }
  }

  void _setTheme(EmberThemeMode mode) {
    setState(() {
      _emberThemeMode = mode;
    });
    // Could save preference to storage here
  }

  // Legacy support for ThemeMode
  void _setThemeLegacy(ThemeMode mode) {
    // Convert ThemeMode to EmberThemeMode
    setState(() {
      _emberThemeMode = mode == ThemeMode.light
          ? EmberThemeMode.light
          : EmberThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(_emberThemeMode),
      darkTheme: AppTheme.getTheme(_emberThemeMode),
      themeMode:
          ThemeMode.light, // Always use light mode since theme is baked in
      home: SplashScreen(onThemeChange: _setThemeLegacy),
      routes: {
        '/onboarding': (context) =>
            OnboardingScreen(onThemeChange: _setThemeLegacy),
        '/dashboard': (context) =>
            DashboardScreen(onThemeChange: _setThemeLegacy),
        '/paywall': (context) => const PaywallScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChange;

  const SplashScreen({super.key, this.onThemeChange});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Defer navigation until after first frame to avoid route controller issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });

    // Safety timeout: if still on splash after 10 seconds, force navigate to onboarding
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_isNavigating) {
        debugPrint('Splash timeout: forcing navigation to onboarding');
        _isNavigating = true;
        try {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  OnboardingScreen(onThemeChange: widget.onThemeChange),
            ),
          );
        } catch (e) {
          debugPrint('Timeout fallback failed: $e');
        }
      }
    });
  }

  Future<void> _initializeApp() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      // Check if user has completed onboarding
      final profile = StorageService.getUserProfile();
      debugPrint(
        'Profile check: ${profile != null ? "exists" : "null (first run)"}',
      );

      // Set theme based on user gender before navigation
      if (profile != null && widget.onThemeChange != null) {
        widget.onThemeChange!(AppTheme.getThemeModeForGender(profile.gender));
      }

      // Simulate splash delay
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) {
        debugPrint('Widget unmounted, skipping navigation');
        return;
      }

      if (profile == null) {
        // First time user - show onboarding
        debugPrint('Navigating to onboarding (no profile)');
        try {
          if (mounted) {
            await Navigator.of(context).pushReplacementNamed('/onboarding');
          }
        } catch (navError) {
          debugPrint(
            'Named route navigation failed: $navError, trying direct route',
          );
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    OnboardingScreen(onThemeChange: widget.onThemeChange),
              ),
            );
          }
        }
      } else {
        // Existing user - go to dashboard
        debugPrint('Navigating to dashboard (profile exists)');
        try {
          if (mounted) {
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    DashboardScreen(onThemeChange: widget.onThemeChange),
              ),
            );
          }
        } catch (navError) {
          debugPrint('Dashboard navigation failed: $navError');
          // Fallback to onboarding
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    OnboardingScreen(onThemeChange: widget.onThemeChange),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Splash initialization error: $e');
      if (mounted) {
        // Fallback to onboarding on any error
        try {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  OnboardingScreen(onThemeChange: widget.onThemeChange),
            ),
          );
        } catch (fallbackError) {
          debugPrint('Even fallback failed: $fallbackError');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.backgroundDark, AppTheme.cardDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon - Flame for Calories
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.whatshot, // Flame icon
                  size: 80,
                  color: AppTheme.primaryOrange,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Diet Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your Personal Nutrition Companion',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(color: AppTheme.primaryOrange),
            ],
          ),
        ),
      ),
    );
  }
}
