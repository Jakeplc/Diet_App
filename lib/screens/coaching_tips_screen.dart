import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/coaching_tip.dart';
import '../services/coaching_service.dart';
import '../services/storage_service.dart';
import '../services/premium_service.dart';
import '../theme/app_theme.dart';

class CoachingTipsScreen extends StatefulWidget {
  const CoachingTipsScreen({super.key});

  @override
  State<CoachingTipsScreen> createState() => _CoachingTipsScreenState();
}

class _CoachingTipsScreenState extends State<CoachingTipsScreen> {
  UserProfile? _profile;
  List<CoachingTip> _personalizedTips = [];
  bool _isPremium = false;
  String _selectedCategory = 'all';
  final List<String> _categories = [
    'all',
    'nutrition',
    'hydration',
    'macros',
    'consistency',
    'timing',
    'general',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = StorageService.getUserProfile();
    final logs = StorageService.getFoodLogsForDate(DateTime.now());
    final premium = await PremiumService.isPremium();

    final tips = CoachingService.generatePersonalizedTips(
      userGoal: profile?.goal ?? 'maintain',
      recentLogs: logs,
      isPremium: premium,
    );

    setState(() {
      _profile = profile;
      _personalizedTips = tips;
      _isPremium = premium;
    });
  }

  List<CoachingTip> _getFilteredTips() {
    if (_selectedCategory == 'all') {
      return _personalizedTips;
    }
    return _personalizedTips
        .where((tip) => tip.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaching Tips'),
        centerTitle: true,
        elevation: 0,
      ),
      body: !_isPremium
          ? _buildPremiumLock()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.backgroundDark, AppTheme.cardDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 40)),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Personalized Coaching',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Custom tips for your ${_profile?.goal ?? 'goals'}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.info, color: Colors.blue, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Tips are personalized based on your goal, recent logs, and nutrition patterns.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: FilterChip(
                            label: Text(
                              category[0].toUpperCase() + category.substring(1),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade400,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            backgroundColor: Colors.grey.withOpacity(0.1),
                            selectedColor: Colors.blue.withOpacity(0.7),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Tips List
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (_getFilteredTips().isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Text('😊', style: TextStyle(fontSize: 60)),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'No tips in this category',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._getFilteredTips().map((tip) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: _buildTipCard(tip),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPremiumLock() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          const Text(
            'Personalized Coaching Tips',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Premium feature',
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Upgrade to Premium'),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(CoachingTip tip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(tip.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tip.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              tip.category,
                            ).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tip.category[0].toUpperCase() +
                                tip.category.substring(1),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getCategoryColor(tip.category),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tip.tip,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'nutrition':
        return Colors.green;
      case 'hydration':
        return Colors.cyan;
      case 'macros':
        return Colors.orange;
      case 'consistency':
        return Colors.purple;
      case 'timing':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }
}
