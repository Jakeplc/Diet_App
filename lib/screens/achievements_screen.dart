import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  AchievementCategory? _selectedCategory;
  bool _isLoading = true;
  int _unlockedCount = 0;
  double _completionPercentage = 0;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    final achievements = await AchievementService.getAllAchievements();
    final unlockedCount = await AchievementService.getUnlockedCount();
    final completionPercentage =
        await AchievementService.getCompletionPercentage();

    setState(() {
      _achievements = achievements;
      _unlockedCount = unlockedCount;
      _completionPercentage = completionPercentage;
      _isLoading = false;
    });
  }

  List<Achievement> get _filteredAchievements {
    if (_selectedCategory == null) return _achievements;
    return _achievements.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAchievements,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAchievements,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildCategoryFilter()),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: _filteredAchievements.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildAchievementCard(
                                _filteredAchievements[index],
                              ),
                              childCount: _filteredAchievements.length,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 48, color: Colors.amber[300]),
              const SizedBox(width: 12),
              Text(
                '$_unlockedCount / ${_achievements.length}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Achievements Unlocked',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _completionPercentage / 100,
              minHeight: 8,
              backgroundColor: Colors.white30,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[300]!),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_completionPercentage.toStringAsFixed(1)}% Complete',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('All', null),
          _buildFilterChip('Streak', AchievementCategory.streak),
          _buildFilterChip('Weight', AchievementCategory.weight),
          _buildFilterChip('Fasting', AchievementCategory.fasting),
          _buildFilterChip('Logging', AchievementCategory.logging),
          _buildFilterChip('Goals', AchievementCategory.goals),
          _buildFilterChip('Milestones', AchievementCategory.milestones),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, AchievementCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedCategory = selected ? category : null);
        },
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;

    return Card(
      elevation: isUnlocked ? 3 : 1,
      color: isUnlocked ? null : Colors.grey[300],
      child: InkWell(
        onTap: () => _showAchievementDetail(achievement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with overlay for locked
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: isUnlocked
                        ? achievement.color
                        : Colors.grey[400],
                    child: Icon(
                      achievement.icon,
                      size: 36,
                      color: isUnlocked ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  if (!isUnlocked)
                    Icon(Icons.lock, size: 24, color: Colors.grey[700]),
                ],
              ),
              const SizedBox(height: 12),
              // Name
              Text(
                achievement.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? null : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Progress or unlock date
              if (isUnlocked)
                Text(
                  'Unlocked!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                )
              else ...[
                Text(
                  '${achievement.currentProgress}/${achievement.requirement}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: achievement.progressPercentage / 100,
                  minHeight: 4,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No achievements in this category',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: achievement.color,
              child: Icon(achievement.icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                achievement.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (achievement.isUnlocked) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Unlocked',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              if (achievement.unlockedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  'On ${_formatDate(achievement.unlockedAt!)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ] else ...[
              Text(
                'Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: achievement.progressPercentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
              ),
              const SizedBox(height: 8),
              Text(
                '${achievement.currentProgress} / ${achievement.requirement}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ],
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
