import 'package:hive/hive.dart';
import '../models/body_composition.dart';

class BodyCompositionService {
  static const String _boxName = 'body_composition';

  /// Initialize the service
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  /// Save body composition entry
  static Future<void> saveEntry(BodyComposition entry) async {
    await init();
    final box = Hive.box(_boxName);
    await box.put(entry.id, entry.toMap());
  }

  /// Get all body composition entries
  static List<BodyComposition> getAllEntries() {
    final box = Hive.box(_boxName);
    final entries = <BodyComposition>[];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        entries.add(BodyComposition.fromMap(Map<String, dynamic>.from(data)));
      }
    }

    // Sort by timestamp descending
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// Get entries within date range
  static List<BodyComposition> getEntriesInRange(DateTime start, DateTime end) {
    final allEntries = getAllEntries();
    return allEntries.where((entry) {
      return entry.timestamp.isAfter(start) && entry.timestamp.isBefore(end);
    }).toList();
  }

  /// Get latest entry
  static BodyComposition? getLatestEntry() {
    final entries = getAllEntries();
    return entries.isEmpty ? null : entries.first;
  }

  /// Delete entry
  static Future<void> deleteEntry(String id) async {
    await init();
    final box = Hive.box(_boxName);
    await box.delete(id);
  }

  /// Get statistics for a metric over time
  static Map<String, dynamic> getMetricStats(String metric, int days) {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final entries = getEntriesInRange(startDate, DateTime.now());

    if (entries.isEmpty) {
      return {
        'current': null,
        'average': null,
        'min': null,
        'max': null,
        'change': null,
        'trend': 'stable',
      };
    }

    final values = entries
        .map((e) => _getMetricValue(e, metric))
        .where((v) => v != null)
        .map((v) => v!)
        .toList();

    if (values.isEmpty) {
      return {
        'current': null,
        'average': null,
        'min': null,
        'max': null,
        'change': null,
        'trend': 'stable',
      };
    }

    values.sort();
    final current = values.last;
    final first = values.first;
    final average = values.reduce((a, b) => a + b) / values.length;
    final change = current - first;

    String trend = 'stable';
    if (change > 0.5) trend = 'increasing';
    if (change < -0.5) trend = 'decreasing';

    return {
      'current': current,
      'average': average,
      'min': values.first,
      'max': values.last,
      'change': change,
      'trend': trend,
    };
  }

  static double? _getMetricValue(BodyComposition entry, String metric) {
    switch (metric) {
      case 'bodyFat':
        return entry.bodyFatPercentage;
      case 'muscleMass':
        return entry.muscleMass;
      case 'waterPercentage':
        return entry.waterPercentage;
      case 'visceralFat':
        return entry.visceralFat;
      case 'waist':
        return entry.waist;
      case 'hips':
        return entry.hips;
      case 'chest':
        return entry.chest;
      case 'neck':
        return entry.neck;
      case 'bicep':
        return entry.bicepLeft;
      case 'thigh':
        return entry.thighLeft;
      default:
        return null;
    }
  }

  /// Get chart data for a metric
  static List<Map<String, dynamic>> getChartData(String metric, int days) {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final entries = getEntriesInRange(startDate, DateTime.now());

    return entries
        .map((entry) {
          return {
            'date': entry.timestamp,
            'value': _getMetricValue(entry, metric),
          };
        })
        .where((point) => point['value'] != null)
        .toList();
  }

  /// Calculate lean body mass
  static double? calculateLeanBodyMass(
    double weight,
    double? bodyFatPercentage,
  ) {
    if (bodyFatPercentage == null) return null;
    return weight * (1 - bodyFatPercentage / 100);
  }

  /// Calculate body fat mass
  static double? calculateBodyFatMass(
    double weight,
    double? bodyFatPercentage,
  ) {
    if (bodyFatPercentage == null) return null;
    return weight * (bodyFatPercentage / 100);
  }

  /// Estimate body fat percentage using Navy method (for males)
  static double estimateBodyFatNavyMale(
    double height, // cm
    double waist, // cm
    double neck, // cm
  ) {
    // Navy formula for males
    final heightInches = height / 2.54;
    final waistInches = waist / 2.54;
    final neckInches = neck / 2.54;

    final bf =
        86.010 * (waistInches - neckInches).abs() / heightInches - 70.041;
    return bf.clamp(3.0, 50.0);
  }

  /// Estimate body fat percentage using Navy method (for females)
  static double estimateBodyFatNavyFemale(
    double height, // cm
    double waist, // cm
    double neck, // cm
    double hips, // cm
  ) {
    // Navy formula for females
    final heightInches = height / 2.54;
    final waistInches = waist / 2.54;
    final neckInches = neck / 2.54;
    final hipsInches = hips / 2.54;

    final bf =
        163.205 * (waistInches + hipsInches - neckInches) / heightInches -
        97.684;
    return bf.clamp(10.0, 60.0);
  }

  /// Clear all data
  static Future<void> clearAll() async {
    await init();
    final box = Hive.box(_boxName);
    await box.clear();
  }
}
