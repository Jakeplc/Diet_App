import 'package:flutter/material.dart';

class HealthReport {
  final DateTime generatedDate;
  final double averageCalories;
  final int totalWorkouts;
  final double averageWeight;
  final int waterIntake;
  final String healthScore;
  final String recommendations;

  HealthReport({
    required this.generatedDate,
    required this.averageCalories,
    required this.totalWorkouts,
    required this.averageWeight,
    required this.waterIntake,
    required this.healthScore,
    required this.recommendations,
  });
}

class AnalyticsService {
  static Future<HealthReport> generateWeeklyReport() async {
    // Simulate analytics calculation
    await Future.delayed(const Duration(milliseconds: 500));

    return HealthReport(
      generatedDate: DateTime.now(),
      averageCalories: 1850,
      totalWorkouts: 4,
      averageWeight: 75.5,
      waterIntake: 8,
      healthScore: '8.5/10',
      recommendations: '''
âœ… Great consistency this week! You logged meals 6 out of 7 days.

ðŸ’§ Water Intake: Aim for 9-10 glasses daily. You're at 8 average.

ðŸƒ Activity: 4 workouts is excellent! Keep up the momentum.

ðŸ½ï¸ Calories: On average, 1850 cal/day. Slightly under your 1900 target.

ðŸ“ˆ Recommendations:
  â€¢ Increase water intake slightly
  â€¢ Add 1 more workout next week
  â€¢ Maintain current calorie tracking consistency
  â€¢ Focus on protein intake in meals
      ''',
    );
  }

  static Future<HealthReport> generateMonthlyReport() async {
    // Simulate analytics calculation
    await Future.delayed(const Duration(milliseconds: 500));

    return HealthReport(
      generatedDate: DateTime.now(),
      averageCalories: 1875,
      totalWorkouts: 16,
      averageWeight: 74.2,
      waterIntake: 8,
      healthScore: '8.8/10',
      recommendations: '''
ðŸŽ‰ Outstanding progress this month!

ðŸ“Š Monthly Summary:
  â€¢ Consistent logging: 28/30 days (93%)
  â€¢ Average daily calories: 1,875
  â€¢ Total workouts: 16
  â€¢ Weight change: -1.3 kg
  â€¢ Water intake: 8 glasses/day

â­ Key Achievements:
  â€¢ 7-day logging streak
  â€¢ 4 workouts week consistency
  â€¢ Met macros target 18/30 days

ðŸŽ¯ Next Month Goals:
  â€¢ Increase workout frequency to 5/week
  â€¢ Improve water intake to 10 glasses/day
  â€¢ Maintain 95%+ logging consistency
  â€¢ Focus on protein: 35% of daily calories

ðŸ’ª Keep up the excellent work!
      ''',
    );
  }

  static Future<Map<String, dynamic>> getTrendAnalysis(int days) async {
    return {
      'caloriesTrend': 'Stable (+50 cal from last week)',
      'weightTrend': 'Declining (-0.8 kg this week)',
      'activityTrend': 'Increasing (2 more workouts)',
      'macroBalance': 'Protein: 28% | Carbs: 45% | Fats: 27%',
      'consistency': '92% (23/25 days logged)',
      'healthScore': '8.7/10 (up 0.3 from last week)',
    };
  }

  static Future<List<Map<String, dynamic>>> getPredictiveGoal(
    double currentWeight,
    double goalWeight,
    int daysActive,
  ) async {
    final weightLost = (currentWeight - goalWeight).abs();
    final avgWeeklyLoss = daysActive > 0 ? weightLost / (daysActive / 7) : 0;
    final weeksRemaining = avgWeeklyLoss > 0
        ? (currentWeight - goalWeight).abs() / avgWeeklyLoss
        : 0;

    return [
      {
        'title': 'Estimated Goal Date',
        'value': 'Week ${weeksRemaining.toStringAsFixed(0)}',
        'icon': 'calendar',
        'color': Colors.purple,
      },
      {
        'title': 'Weekly Loss Rate',
        'value': '${avgWeeklyLoss.toStringAsFixed(2)} kg/week',
        'icon': 'trending_down',
        'color': Colors.green,
      },
      {
        'title': 'Days to Goal',
        'value': '${(weeksRemaining * 7).toStringAsFixed(0)} days',
        'icon': 'timer',
        'color': Colors.orange,
      },
    ];
  }
}
