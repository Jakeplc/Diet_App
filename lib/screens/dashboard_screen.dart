import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/food_log.dart';
import '../models/water_log.dart';
import '../models/glp_log.dart';
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
  List<GlpLog> _glpLogs = [];
  bool _isPremium = false;

  static const double _waterQuickAddFallbackMl = 250.0;

  String _formatWaterAmount(double ml) {
    if (_profile?.measurementSystem == 'imperial') {
      final oz = ml / 29.5735;
      return '${oz.toStringAsFixed(0)} oz';
    }
    return '${ml.toStringAsFixed(0)} ml';
  }

  double _getWaterQuickAddAmount() {
    final value = StorageService.getSetting(
      StorageService.waterQuickAddAmountKey,
      defaultValue: _waterQuickAddFallbackMl,
    );
    if (value is num && value > 0) return value.toDouble();
    return _waterQuickAddFallbackMl;
  }

  Future<void> _addWaterLog(double amountMl) async {
    if (_profile == null) return;

    final log = WaterLog(
      id: const Uuid().v4(),
      amount: amountMl,
      timestamp: DateTime.now(),
    );

    await StorageService.saveWaterLog(log);
    await _loadData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_formatWaterAmount(amountMl)} added'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            await StorageService.deleteWaterLog(log.id);
            if (mounted) {
              await _loadData();
            }
          },
        ),
      ),
    );
  }

  double _getMacroTarget(String key, double fallback) {
    final value = StorageService.getSetting(key, defaultValue: fallback);
    if (value is num) return value.toDouble();
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = StorageService.getUserProfile();
    final logs = StorageService.getFoodLogsForDate(DateTime.now());
    final water = StorageService.getWaterLogsForDate(DateTime.now());
    final glpLogs = StorageService.getGlpLogs();
    final premium = await PremiumService.isPremium();

    setState(() {
      _profile = profile;
      _todayLogs = logs;
      _todayWater = water;
      _glpLogs = glpLogs;
      _isPremium = premium;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeScreen(),
      FoodLoggingScreen(onLogSaved: _loadData),
      const MealPlanningScreen(),
      const ProgressScreen(),
      SettingsScreen(onThemeChange: widget.onThemeChange),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            _loadData();
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedHome03),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedRestaurant01),
            label: 'Log Food',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
            label: 'Meal Plan',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedAnalytics02),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedSettings02),
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

    final proteinTarget = _getMacroTarget(
      StorageService.macroProteinTargetKey,
      _profile!.proteinTarget,
    );
    final carbsTarget = _getMacroTarget(
      StorageService.macroCarbsTargetKey,
      _profile!.carbsTarget,
    );
    final fatsTarget = _getMacroTarget(
      StorageService.macroFatsTargetKey,
      _profile!.fatsTarget,
    );

    final insight = CalorieCalculatorService.generateDailyInsight(
      caloriesConsumed: caloriesConsumed,
      caloriesTarget: _profile!.dailyCalorieTarget,
      proteinConsumed: proteinConsumed,
      proteinTarget: proteinTarget,
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
                          color: AppTheme.bannerIcon.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryOrange.withValues(
                              alpha: 0.3,
                            ),
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
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
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.6),
                    ),
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

                _buildGlpTrackerCard(),
                const SizedBox(height: 20),

                // Macros Card
                _buildMacrosCard(
                  proteinConsumed,
                  carbsConsumed,
                  fatsConsumed,
                  proteinTarget,
                  carbsTarget,
                  fatsTarget,
                ),
                const SizedBox(height: 20),

                // Today's Meals
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Meals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
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
          const HugeIcon(
            icon: HugeIcons.strokeRoundedFire,
            color: AppTheme.caloriesRing,
            size: 32,
          ),
          const SizedBox(height: 5),
          Text(
            '${consumed.toInt()}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            '/ ${target.toInt()}',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      progressColor: AppTheme.caloriesRing,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.outline.withValues(alpha: 0.4),
      circularStrokeCap: CircularStrokeCap.round,
      footer: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Text(
              'Calories',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildWaterCircle(double consumed, double target) {
    final percentage = (consumed / target).clamp(0.0, 1.0);
    final glasses = (consumed / 250).toInt(); // 250ml = 1 glass

    return CircularPercentIndicator(
      radius: 80,
      lineWidth: 12,
      percent: percentage,
      center: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _addWaterLog(_getWaterQuickAddAmount()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedDroplet,
              color: Color.fromARGB(255, 60, 146, 237),
              size: 32,
            ),
            const SizedBox(height: 5),
            Text(
              '$glasses',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              'glasses',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      progressColor: AppTheme.waterRing,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.outline.withValues(alpha: 0.4),
      circularStrokeCap: CircularStrokeCap.round,
      footer: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Text(
              'Water',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
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
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutrients',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildMacroCircle(
                    'Protein',
                    protein,
                    proteinTarget,
                    AppTheme.proteinBlue,
                  ),
                ),
                Expanded(
                  child: _buildMacroCircle(
                    'Carbs',
                    carbs,
                    carbsTarget,
                    AppTheme.carbsAmber,
                  ),
                ),
                Expanded(
                  child: _buildMacroCircle(
                    'Fats',
                    fats,
                    fatsTarget,
                    AppTheme.fatsRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlpTrackerCard() {
    final scheme = Theme.of(context).colorScheme;
    final logs = _glpLogs.take(3).toList();

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'GLP-1 Tracker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _showGlpLogDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _showGlpHistoryDialog,
                      icon: const Icon(Icons.history),
                      label: const Text('History'),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (logs.isEmpty)
              Text(
                'No doses logged yet.',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else
              ...logs.asMap().entries.map((entry) {
                final index = entry.key;
                final log = entry.value;
                final showNotes = index == 0 && log.notes != null;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${log.doseAmount.toStringAsFixed(2)} ${log.doseUnit}',
                  ),
                  subtitle: showNotes
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatGlpDate(log.date)),
                            Text(
                              log.notes!,
                              style: TextStyle(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Text(_formatGlpDate(log.date)),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: scheme.error),
                    onPressed: () => _deleteGlpLog(log),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatGlpDate(DateTime date) {
    final local = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(local).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${local.month}/${local.day}/${local.year}';
  }

  Future<void> _showGlpLogDialog() async {
    const units = ['mg', 'mL', 'IU'];
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    var selectedUnit = units.first;
    var selectedDate = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add GLP-1 Dose'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Dose amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                ),
                items: units
                    .map(
                      (unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedUnit = value);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 2,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_formatGlpDate(selectedDate)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final amount = double.tryParse(amountController.text.trim());
      if (amount == null || amount <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter a valid dose amount')),
          );
        }
        return;
      }

      final log = GlpLog(
        id: const Uuid().v4(),
        doseAmount: amount,
        doseUnit: selectedUnit,
        date: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      await StorageService.saveGlpLog(log);
      await _loadData();
    }
  }

  void _showGlpHistoryDialog() {
    final logs = List<GlpLog>.from(_glpLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GLP-1 History'),
        content: SizedBox(
          width: double.maxFinite,
          child: logs.isEmpty
              ? const Text('No doses logged yet.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: logs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${log.doseAmount.toStringAsFixed(2)} ${log.doseUnit}',
                      ),
                      subtitle: log.notes == null
                          ? Text(_formatGlpDate(log.date))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_formatGlpDate(log.date)),
                                Text(
                                  log.notes!,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGlpLog(GlpLog log) async {
    await StorageService.deleteGlpLog(log.id);
    await _loadData();
  }

  Widget _buildMacroCircle(
    String name,
    double consumed,
    double target,
    Color color,
  ) {
    final percentage = (consumed / target).clamp(0.0, 1.0);

    return CircularPercentIndicator(
      radius: 58,
      lineWidth: 10,
      percent: percentage,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${consumed.toInt()}g',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            '/ ${target.toInt()}g',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      progressColor: color,
      backgroundColor: AppTheme.ringTrack,
      circularStrokeCap: CircularStrokeCap.round,
      footer: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
          ),
        ),
      ),
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
              '${log.mealType.toUpperCase()} â€¢ ${log.calories.toInt()} cal',
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
