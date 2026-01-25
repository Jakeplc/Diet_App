import 'package:flutter/material.dart';
import '../services/extended_achievement_service.dart';

class ExtendedAchievementsScreen extends StatefulWidget {
  final bool isPremium;

  const ExtendedAchievementsScreen({required this.isPremium, super.key});

  @override
  State<ExtendedAchievementsScreen> createState() =>
      _ExtendedAchievementsScreenState();
}

class _ExtendedAchievementsScreenState
    extends State<ExtendedAchievementsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Consistency',
    'Nutrition',
    'Fitness',
    'Weight Loss',
    'Community',
    'Health',
    'Premium',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements (30+)'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          FutureBuilder<int>(
            future: ExtendedAchievementService.getTotalProgress(),
            builder: (context, snapshot) {
              final progress = snapshot.data ?? 0;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.amber.shade400, Colors.orange.shade400],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Achievement Progress',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$progress%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress / 100,
                                  minHeight: 8,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.3,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Keep grinding! 💪',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories
                    .map(
                      (cat) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(cat),
                          selected: _selectedCategory == cat,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = cat);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AchievementBadge>>(
              future: _selectedCategory == 'All'
                  ? ExtendedAchievementService.getAllBadges()
                  : ExtendedAchievementService.getBadgesByCategory(
                      _selectedCategory,
                    ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final badges = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return _AchievementBadgeWidget(badge: badge);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadgeWidget extends StatelessWidget {
  final AchievementBadge badge;

  const _AchievementBadgeWidget({required this.badge});

  @override
  Widget build(BuildContext context) {
    final color = _getRarityColor(badge.rarity);

    return GestureDetector(
      onTap: () => _showBadgeDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: badge.isUnlocked
              ? color.withOpacity(0.15)
              : Colors.grey.shade200,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(badge.icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: badge.isUnlocked ? Colors.black87 : Colors.grey.shade700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (badge.isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge.rarity,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(
                '🔒 Locked',
                style: TextStyle(fontSize: 9, color: Colors.grey.shade700),
              ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(badge.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Text(badge.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(badge.description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              _DetailRow('Category', badge.category),
              _DetailRow('Rarity', badge.rarity.toUpperCase()),
              _DetailRow(
                'Status',
                badge.isUnlocked ? 'Unlocked ✓' : 'Locked 🔒',
              ),
              if (badge.isUnlocked && badge.unlockedDate != null)
                _DetailRow(
                  'Unlocked',
                  '${badge.unlockedDate!.month}/${badge.unlockedDate!.day}/${badge.unlockedDate!.year}',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (badge.isUnlocked)
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${badge.title} shared!')),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
