import 'package:flutter/material.dart';
import '../models/micronutrient_data.dart';
import '../services/storage_service.dart';

class MicronutrientsScreen extends StatefulWidget {
  const MicronutrientsScreen({super.key});

  @override
  State<MicronutrientsScreen> createState() => _MicronutrientsScreenState();
}

class _MicronutrientsScreenState extends State<MicronutrientsScreen> {
  MicronutrientData _todayTotals = MicronutrientData();
  Map<String, double> _rda = {};
  bool _isLoading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadMicronutrients();
  }

  Future<void> _loadMicronutrients() async {
    setState(() => _isLoading = true);

    try {
      // Get user profile for RDA calculation
      final profile = StorageService.getUserProfile();
      if (profile != null) {
        _rda = MicronutrientData.getRDA(
          gender: profile.gender,
          age: profile.age,
        );
      }

      // Calculate today's micronutrients from food logs
      final today = DateTime.now();
      final foodLogs = StorageService.getFoodLogsForDate(today);

      MicronutrientData dayTotal = MicronutrientData();

      for (var log in foodLogs) {
        // Get the food item
        final allFoods = StorageService.getAllFoodItems();
        final food = allFoods.firstWhere(
          (f) => f.id == log.foodItemId,
          orElse: () => allFoods.first,
        );

        // Add micronutrients if available
        if (food.micronutrients != null) {
          dayTotal = dayTotal + (food.micronutrients! * log.servings);
        }
      }

      setState(() {
        _todayTotals = dayTotal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<MapEntry<String, Map<String, String>>> _getFilteredNutrients() {
    final allNutrients = MicronutrientData.getNutrientInfo().entries.toList();

    if (_selectedCategory == 'All') {
      return allNutrients;
    }

    return allNutrients
        .where(
          (entry) => entry.value['category'] == _selectedCategory.toLowerCase(),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Micronutrients'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMicronutrients,
              child: CustomScrollView(
                slivers: [
                  // Category filter
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          _buildCategoryChip('All'),
                          _buildCategoryChip('Vitamin'),
                          _buildCategoryChip('Mineral'),
                        ],
                      ),
                    ),
                  ),

                  // Premium notice
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade100,
                            Colors.orange.shade100,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.stars, color: Colors.amber.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Premium Feature: Full micronutrient tracking',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Micronutrient list
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final nutrients = _getFilteredNutrients();
                      if (index >= nutrients.length) return null;

                      final entry = nutrients[index];
                      final key = entry.key;
                      final info = entry.value;

                      // Get current value from totals
                      final currentValue = _getCurrentValue(key);
                      final rdaValue = _rda[key] ?? 0;
                      final percentage = rdaValue > 0
                          ? (currentValue / rdaValue * 100).clamp(0, 200)
                          : 0;

                      return _buildNutrientCard(
                        icon: info['icon']!,
                        name: info['name']!,
                        current: currentValue,
                        target: rdaValue,
                        unit: info['unit']!,
                        percentage: percentage.toDouble(),
                      );
                    }, childCount: _getFilteredNutrients().length),
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedCategory = category);
      },
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildNutrientCard({
    required String icon,
    required String name,
    required double current,
    required double target,
    required String unit,
    required double percentage,
  }) {
    final isGood = percentage >= 50 && percentage < 100;
    final isExcellent = percentage >= 100;

    Color progressColor;
    Color bgColor;
    String status;

    if (isExcellent) {
      progressColor = Colors.green;
      bgColor = Colors.green.shade50;
      status = 'Excellent';
    } else if (isGood) {
      progressColor = Colors.orange;
      bgColor = Colors.orange.shade50;
      status = 'Good';
    } else {
      progressColor = Colors.red;
      bgColor = Colors.red.shade50;
      status = 'Low';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: progressColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${current.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} $unit',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: progressColor.withOpacity(1.0),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0, 1),
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}% of daily target',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  double _getCurrentValue(String key) {
    switch (key) {
      case 'vitaminA':
        return _todayTotals.vitaminA;
      case 'vitaminC':
        return _todayTotals.vitaminC;
      case 'vitaminD':
        return _todayTotals.vitaminD;
      case 'vitaminE':
        return _todayTotals.vitaminE;
      case 'vitaminK':
        return _todayTotals.vitaminK;
      case 'vitaminB1':
        return _todayTotals.vitaminB1;
      case 'vitaminB2':
        return _todayTotals.vitaminB2;
      case 'vitaminB3':
        return _todayTotals.vitaminB3;
      case 'vitaminB6':
        return _todayTotals.vitaminB6;
      case 'vitaminB9':
        return _todayTotals.vitaminB9;
      case 'vitaminB12':
        return _todayTotals.vitaminB12;
      case 'calcium':
        return _todayTotals.calcium;
      case 'iron':
        return _todayTotals.iron;
      case 'magnesium':
        return _todayTotals.magnesium;
      case 'phosphorus':
        return _todayTotals.phosphorus;
      case 'potassium':
        return _todayTotals.potassium;
      case 'sodium':
        return _todayTotals.sodium;
      case 'zinc':
        return _todayTotals.zinc;
      case 'copper':
        return _todayTotals.copper;
      case 'manganese':
        return _todayTotals.manganese;
      case 'selenium':
        return _todayTotals.selenium;
      default:
        return 0;
    }
  }
}
