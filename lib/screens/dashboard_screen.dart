import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:hugeicons/hugeicons.dart';
import '../models/user_profile.dart';
import '../models/food_log.dart';
import '../models/water_log.dart';
import '../services/storage_service.dart';
import '../services/calorie_calculator_service.dart';
import '../services/premium_service.dart';
import '../theme/app_theme.dart';
import 'food_logging_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import 'meal_planning_screen.dart';
import '../widgets/ad_banner_widget.dart';

class DashboardScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChange;

  const DashboardScreen({super.key, this.onThemeChange});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  UserProfile? _profile;
  List<FoodLog> _todayLogs = [];
  List<WaterLog> _todayWater = [];
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = StorageService.getUserProfile();
    final logs = StorageService.getFoodLogsForDate(DateTime.now());
    final water = StorageService.getWaterLogsForDate(DateTime.now());
    final premium = await PremiumService.isPremium();

    setState(() {
      _profile = profile;
      _todayLogs = logs;
      _todayWater = water;
      _isPremium = premium;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeScreen(),
      const FoodLoggingScreen(),
      const MealPlanningScreen(),
      const ProgressScreen(),
      SettingsScreen(onThemeChange: widget.onThemeChange),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedHome03),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedRestaurant01),
            label: 'Log Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedCalendar03),
            label: 'Meal Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedAnalytics02),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(HugeIcons.strokeRoundedSettings02),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeScreen() {
    if (_profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate today's totals
    double caloriesConsumed = 0;
    double proteinConsumed = 0;
    double carbsConsumed = 0;
    double fatsConsumed = 0;

    for (var log in _todayLogs) {
      caloriesConsumed += log.calories;
      proteinConsumed += log.protein;
      carbsConsumed += log.carbs;
      fatsConsumed += log.fats;
    }

    double waterConsumed = 0;
    for (var log in _todayWater) {
      waterConsumed += log.amount;
    }

    final insight = CalorieCalculatorService.generateDailyInsight(
      caloriesConsumed: caloriesConsumed,
      caloriesTarget: _profile!.dailyCalorieTarget,
      proteinConsumed: proteinConsumed,
      proteinTarget: _profile!.proteinTarget,
      waterConsumed: waterConsumed,
      waterTarget: _profile!.waterTarget,
    );

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.bannerGradientStart,
                  AppTheme.bannerGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_profile!.currentStreak > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.bannerIcon.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryOrange.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.whatshot,
                              color: AppTheme.primaryOrange,
                              size: 30,
                            ),
                            Text(
                              '${_profile!.currentStreak}',
                              style: const TextStyle(
                                color: AppTheme.primaryOrange,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryOrange.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.accentOrange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          insight,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular Charts Row
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141B27),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildCalorieCircle(
                          caloriesConsumed,
                          _profile!.dailyCalorieTarget,
                        ),
                      ),
                      Expanded(
                        child: _buildWaterCircle(
                          waterConsumed,
                          _profile!.waterTarget,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Macros Card
                _buildMacrosCard(
                  proteinConsumed,
                  carbsConsumed,
                  fatsConsumed,
                  _profile!.proteinTarget,
                  _profile!.carbsTarget,
                  _profile!.fatsTarget,
                ),
                const SizedBox(height: 20),

                // Today's Meals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Meals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedIndex = 1);
                      },
                      child: const Text(
                        'Add Meal',
                        style: TextStyle(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildMealsList(),

                const SizedBox(height: 20),
                _buildCaloriesLeftFooter(
                  caloriesConsumed,
                  _profile!.dailyCalorieTarget,
                ),

                // Ad Banner (if not premium)
                if (!_isPremium) ...[
                  const SizedBox(height: 20),
                  const AdBannerWidget(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieCircle(double consumed, double target) {
    final percentage = (consumed / target).clamp(0.0, 1.0);
    final remaining = (target - consumed).toInt();

    return CircularPercentIndicator(
      radius: 80,
      lineWidth: 12,
      percent: percentage,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            HugeIcons.strokeRoundedFire,
            color: AppTheme.caloriesRing,
            size: 32,
          ),
          const SizedBox(height: 5),
          Text(
            '${consumed.toInt()}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          Text(
            '/ ${target.toInt()}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFCBD5E1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      progressColor: AppTheme.caloriesRing,
      backgroundColor: AppTheme.ringTrack,
      circularStrokeCap: CircularStrokeCap.round,
      footer: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            const Text(
              'Calories',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
                fontSize: 13,
              ),
            ),
            Text(
              '${remaining.toStringAsFixed(0)} left',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.caloriesRing,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesLeftFooter(double consumed, double target) {
    final remaining = (target - consumed).toInt();
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryOrange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              HugeIcons.strokeRoundedFire,
              color: AppTheme.primaryOrange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              remaining > 0 ? '$remaining left' : 'Over by ${-remaining}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: remaining > 0 ? AppTheme.successGreen : AppTheme.fatsRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCircle(double consumed, double target) {
    final percentage = (consumed / target).clamp(0.0, 1.0);
    final glasses = (consumed / 250).toInt(); // 250ml = 1 glass

    return CircularPercentIndicator(
      radius: 80,
      lineWidth: 12,
      percent: percentage,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            HugeIcons.strokeRoundedDroplet,
            color: AppTheme.waterRing,
            size: 32,
          ),
          const SizedBox(height: 5),
          Text(
            '$glasses',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          const Text(
            'glasses',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFCBD5E1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      progressColor: AppTheme.waterRing,
      backgroundColor: AppTheme.ringTrack,
      circularStrokeCap: CircularStrokeCap.round,
      footer: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            const Text(
              'Water',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFFFFF),
                fontSize: 13,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.waterRing,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosCard(
    double protein,
    double carbs,
    double fats,
    double proteinTarget,
    double carbsTarget,
    double fatsTarget,
  ) {
    return Card(
      color: AppTheme.cardDark,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Macronutrients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 20),
            _buildMacroBar(
              'Protein',
              protein,
              proteinTarget,
              AppTheme.proteinBlue,
            ),
            const SizedBox(height: 15),
            _buildMacroBar('Carbs', carbs, carbsTarget, AppTheme.carbsAmber),
            const SizedBox(height: 15),
            _buildMacroBar('Fats', fats, fatsTarget, AppTheme.fatsRed),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(
    String name,
    double consumed,
    double target,
    Color color,
  ) {
    final percentage = (consumed / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryDark,
              ),
            ),
            Text(
              '${consumed.toInt()}g / ${target.toInt()}g',
              style: const TextStyle(color: AppTheme.textMutedDark),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppTheme.outlineDark,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMealsList() {
    if (_todayLogs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.restaurant, size: 50, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                Text(
                  'No meals logged yet',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  child: const Text('Log Your First Meal'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: _todayLogs.map((log) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getMealColor(log.mealType),
              child: Icon(_getMealIcon(log.mealType), color: Colors.white),
            ),
            title: Text(log.foodName),
            subtitle: Text(
              '${log.mealType.toUpperCase()} • ${log.calories.toInt()} cal',
            ),
            trailing: Text(
              '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.fastfood;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
