import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareWeightProgress({
    required double currentWeight,
    required double goalWeight,
    required double weightLost,
    required int daysTracking,
  }) async {
    final String message =
        '''
🎯 Weight Loss Progress Update!

Current Weight: ${currentWeight.toStringAsFixed(1)} kg
Goal Weight: ${goalWeight.toStringAsFixed(1)} kg
Lost So Far: ${weightLost.toStringAsFixed(1)} kg
Days Tracking: $daysTracking days

I'm crushing my fitness goals with Diet Tracker! 💪
Download now: [App Link]
#FitnessJourney #HealthyLifestyle #DietTracker
    ''';

    await Share.share(message, subject: 'My Weight Loss Progress');
  }

  static Future<void> shareAchievements({
    required String achievementTitle,
    required String description,
    required DateTime unlockedDate,
  }) async {
    final String message =
        '''
🏆 Achievement Unlocked!

$achievementTitle
$description

Unlocked on: ${unlockedDate.toString().split(' ')[0]}

Join me on my fitness journey with Diet Tracker! 🚀
#Achievements #FitnessMilestone #DietTracker
    ''';

    await Share.share(
      message,
      subject: 'Achievement Unlocked: $achievementTitle',
    );
  }

  static Future<void> shareStreak({
    required int streakDays,
    required String goal,
  }) async {
    final String message =
        '''
🔥 $streakDays Day Streak!

I've been consistently tracking my diet for $streakDays days while working towards my $goal goal!

Stay consistent with Diet Tracker 💪
#DailyHabits #ConsistencyPays #DietTracker
    ''';

    await Share.share(message, subject: '$streakDays Day Streak!');
  }

  static Future<void> shareMacros({
    required int protein,
    required int carbs,
    required int fats,
    required int totalCalories,
  }) async {
    final String message =
        '''
📊 Today's Nutrition Summary

Total Calories: $totalCalories
Protein: $protein g
Carbs: $carbs g
Fats: $fats g

Tracking my nutrition with Diet Tracker! 🥗💪
#MacroTracking #NutritionGoals #DietTracker
    ''';

    await Share.share(message, subject: 'My Nutrition Summary');
  }
}
