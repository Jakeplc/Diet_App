import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/paywall_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage (Hive)
  await StorageService.init();

  // Initialize notifications
  await NotificationService.init();

  runApp(const DietApp());
}

class DietApp extends StatefulWidget {
  const DietApp({super.key});

  @override
  State<DietApp> createState() => _DietAppState();
}

class _DietAppState extends State<DietApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadThemeFromUserProfile();
  }

  void _loadThemeFromUserProfile() {
    final profile = StorageService.getUserProfile();
    if (profile != null) {
      setState(() {
        _themeMode = AppTheme.getThemeModeForGender(profile.gender);
      });
    }
  }

  void _setTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: SplashScreen(onThemeChange: _setTheme),
      routes: {
        '/onboarding': (context) => OnboardingScreen(onThemeChange: _setTheme),
        '/dashboard': (context) => DashboardScreen(onThemeChange: _setTheme),
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
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check if user has completed onboarding
    final profile = StorageService.getUserProfile();

    // Set theme based on user gender before navigation
    if (profile != null && widget.onThemeChange != null) {
      widget.onThemeChange!(AppTheme.getThemeModeForGender(profile.gender));
    }

    // Simulate splash delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      if (profile == null) {
        // First time user - show onboarding
        Navigator.of(context).pushReplacementNamed('/onboarding');
      } else {
        // Existing user - go to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                DashboardScreen(onThemeChange: widget.onThemeChange),
          ),
        );
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
