// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

// Web / fallback implementation for ExportService.
// On web we can't write to a local filesystem path, so we generate the CSV and
// trigger a browser download.
//
// This file is selected by conditional export in export_service.dart
// (export_service_io.dart is used for dart.library.io platforms).

import 'dart:convert';
import 'dart:html' as html;

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../models/food_log.dart';
import '../models/meal_plan.dart';
import '../models/recipe.dart';
import '../models/weight_log.dart';
import 'storage_service.dart';

class ExportService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

  /// Helper method to get all food logs from all dates
  static List<FoodLog> _getAllFoodLogs() {
    final allLogs = <FoodLog>[];
    final now = DateTime.now();

    // Get logs from past 365 days
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final logsForDate = StorageService.getFoodLogsForDate(date);
      allLogs.addAll(logsForDate);
    }

    return allLogs;
  }

  /// Export food logs to CSV (downloads in browser)
  static Future<String> exportFoodLogs({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final logs = _getAllFoodLogs();

    // Filter by date range if provided
    final filteredLogs = logs.where((log) {
      final logDate = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );
      if (startDate != null && logDate.isBefore(startDate)) return false;
      if (endDate != null && logDate.isAfter(endDate)) return false;
      return true;
    }).toList();

    // Sort by date (newest first)
    filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final csvData = <List<dynamic>>[
      [
        'Date',
        'Time',
        'Food Name',
        'Meal Type',
        'Servings',
        'Calories',
        'Protein (g)',
        'Carbs (g)',
        'Fat (g)',
        'Notes',
      ],
    ];

    for (final log in filteredLogs) {
      csvData.add([
        _dateFormat.format(log.timestamp),
        _dateTimeFormat.format(log.timestamp),
        log.foodName,
        log.mealType,
        log.servings,
        log.calories,
        log.protein,
        log.carbs,
        log.fats,
        log.notes ?? '',
      ]);
    }

    return _downloadCSVFile('food_logs', csvData);
  }

  /// Export weight logs to CSV (downloads in browser)
  static Future<String> exportWeightLogs() async {
    final List<WeightLog> logs = StorageService.getAllWeightLogs();

    // Sort by date (newest first)
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final csvData = <List<dynamic>>[
      ['Date', 'Time', 'Weight (kg)', 'Weight (lbs)', 'Notes'],
    ];

    for (final log in logs) {
      final weightLbs = log.weight * 2.20462; // Convert kg to lbs
      csvData.add([
        _dateFormat.format(log.timestamp),
        _dateTimeFormat.format(log.timestamp),
        log.weight.toStringAsFixed(1),
        weightLbs.toStringAsFixed(1),
        log.notes ?? '',
      ]);
    }

    return _downloadCSVFile('weight_logs', csvData);
  }

  /// Export meal plans to CSV (downloads in browser)
  static Future<String> exportMealPlans() async {
    final List<MealPlan> mealPlans = StorageService.getAllMealPlans();

    // Sort by date and meal type
    mealPlans.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.mealType.compareTo(b.mealType);
    });

    final csvData = <List<dynamic>>[
      ['Date', 'Day of Week', 'Meal Type', 'Plan Name', 'Food Item Count'],
    ];

    for (final plan in mealPlans) {
      final dayOfWeek = DateFormat('EEEE').format(plan.date);
      csvData.add([
        _dateFormat.format(plan.date),
        dayOfWeek,
        plan.mealType,
        plan.name,
        plan.foodItemIds.length,
      ]);
    }

    return _downloadCSVFile('meal_plans', csvData);
  }

  /// Export recipes to CSV (downloads in browser)
  static Future<String> exportRecipes() async {
    final List<Recipe> recipes = StorageService.getAllRecipes();

    // Sort by creation date (newest first)
    recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final csvData = <List<dynamic>>[
      [
        'Recipe Name',
        'Created Date',
        'Ingredients Count',
        'Total Calories',
        'Total Protein (g)',
        'Total Carbs (g)',
        'Total Fat (g)',
        'Has Instructions',
      ],
    ];

    for (final recipe in recipes) {
      csvData.add([
        recipe.name,
        _dateFormat.format(recipe.createdAt),
        recipe.ingredients.length,
        recipe.totalCalories.toStringAsFixed(1),
        recipe.totalProtein.toStringAsFixed(1),
        recipe.totalCarbs.toStringAsFixed(1),
        recipe.totalFat.toStringAsFixed(1),
        recipe.instructions?.isNotEmpty == true ? 'Yes' : 'No',
      ]);
    }

    return _downloadCSVFile('recipes', csvData);
  }

  /// Export all data in a comprehensive report (downloads in browser)
  static Future<String> exportAllData() async {
    final foodLogs = _getAllFoodLogs();
    final weightLogs = StorageService.getAllWeightLogs();
    final mealPlans = StorageService.getAllMealPlans();
    final recipes = StorageService.getAllRecipes();
    final profile = StorageService.getUserProfile();

    // Calculate statistics
    final totalCalories = foodLogs.fold(0.0, (sum, log) => sum + log.calories);
    final avgDailyCalories = foodLogs.isNotEmpty
        ? totalCalories / foodLogs.length
        : 0.0;

    final csvData = <List<dynamic>>[
      ['Diet App - Complete Data Export'],
      ['Generated:', _dateTimeFormat.format(DateTime.now())],
      [''],
      ['User Profile'],
      ['Name:', profile?.name ?? 'Not set'],
      ['Age:', profile?.age.toString() ?? 'Not set'],
      ['Height (cm):', profile?.height.toString() ?? 'Not set'],
      ['Current Weight (kg):', profile?.weight.toString() ?? 'Not set'],
      ['Activity Level:', profile?.activityLevel ?? 'Not set'],
      ['Goal:', profile?.goal ?? 'Not set'],
      [
        'Daily Calorie Target:',
        profile?.dailyCalorieTarget.toString() ?? 'Not set',
      ],
      [''],
      ['Statistics'],
      ['Total Food Log Entries:', foodLogs.length.toString()],
      ['Total Weight Log Entries:', weightLogs.length.toString()],
      ['Total Meal Plans:', mealPlans.length.toString()],
      ['Total Recipes:', recipes.length.toString()],
      ['Total Calories Logged:', totalCalories.toStringAsFixed(1)],
      ['Average Daily Calories:', avgDailyCalories.toStringAsFixed(1)],
      [''],
    ];

    // Add unique tracking days
    final Set<String> uniqueDates = {};
    for (final log in foodLogs) {
      uniqueDates.add(_dateFormat.format(log.timestamp));
    }
    csvData.add(['Days with Food Logs:', uniqueDates.length.toString()]);

    // Add recent weight trend
    if (weightLogs.length >= 2) {
      final recentWeight = weightLogs.first.weight;
      final oldWeight = weightLogs.last.weight;
      final weightChange = recentWeight - oldWeight;
      csvData.add(['Weight Change (kg):', weightChange.toStringAsFixed(1)]);
    }

    return _downloadCSVFile('complete_export', csvData);
  }

  static Future<String> _downloadCSVFile(
    String baseName,
    List<List<dynamic>> csvData,
  ) async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = '${baseName}_$timestamp.csv';

    final csvString = const ListToCsvConverter().convert(csvData);
    _downloadTextFile(fileName, csvString, mimeType: 'text/csv;charset=utf-8');

    return fileName;
  }

  static void _downloadTextFile(
    String fileName,
    String contents, {
    required String mimeType,
  }) {
    final bytes = utf8.encode(contents);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}
