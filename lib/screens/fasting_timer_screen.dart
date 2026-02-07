import 'package:flutter/material.dart';
import 'dart:async';
import '../models/fasting_session.dart';
import '../services/fasting_service.dart';
import '../services/premium_service.dart';

class FastingTimerScreen extends StatefulWidget {
  const FastingTimerScreen({super.key});

  @override
  State<FastingTimerScreen> createState() => _FastingTimerScreenState();
}

class _FastingTimerScreenState extends State<FastingTimerScreen> {
  FastingSession? _activeSession;
  Timer? _timer;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeSession != null && _activeSession!.isActive) {
        setState(() {});
      }
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _activeSession = await FastingService.getActiveSession();
    _stats = await FastingService.getStatistics();
    _isPremium = await PremiumService.isPremium();
    setState(() => _isLoading = false);
  }

  Future<void> _showStartDialog() async {
    final preset = await showDialog<FastingPreset>(
      context: context,
      builder: (context) => const _FastingPresetDialog(),
    );

    if (preset != null) {
      final session = await FastingService.startFasting(
        targetHours: preset.fastingHours,
        fastingType: preset.displayName,
      );
      setState(() => _activeSession = session);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Started ${preset.fastingHours}-hour fast! 🎯'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _endFasting() async {
    if (_activeSession == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Fasting'),
        content: Text(
          _activeSession!.isComplete
              ? 'Congratulations! You completed your fast! 🎉'
              : 'Are you sure you want to end this fast early?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Fast'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FastingService.endFasting(_activeSession!.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _activeSession!.isComplete
                  ? 'Fast completed! Great job! 💪'
                  : 'Fast ended. Keep going! 👍',
            ),
            backgroundColor: _activeSession!.isComplete
                ? Colors.green
                : Colors.orange,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPremium) {
      return _buildPremiumRequired();
    }

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intermittent Fasting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_activeSession != null && _activeSession!.isActive)
                _buildActiveTimer()
              else
                _buildStartCard(),
              const SizedBox(height: 24),
              _buildStatsCard(),
              const SizedBox(height: 16),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumRequired() {
    return Scaffold(
      appBar: AppBar(title: const Text('Intermittent Fasting')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.amber[700]),
              const SizedBox(height: 24),
              const Text(
                'Premium Feature',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Intermittent fasting timer is a premium feature. Upgrade to unlock advanced fasting tracking and statistics!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  // Navigate to paywall would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Upgrade to Premium in Settings!'),
                    ),
                  );
                },
                icon: const Icon(Icons.star),
                label: const Text('Upgrade to Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTimer() {
    final session = _activeSession!;
    final progress = session.progressPercentage / 100;
    final isComplete = session.isComplete;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              isComplete ? 'Fast Complete! 🎉' : 'Fasting in Progress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isComplete ? Colors.green : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              session.fastingType,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isComplete
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDuration(session.elapsedDuration),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'elapsed',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (!isComplete) ...[
              Text(
                'Time Remaining',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDuration(session.remainingDuration),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Target: ${session.targetDurationHours} hours',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ] else ...[
              Text(
                'You fasted for ${session.elapsedDuration.inHours}h ${session.elapsedDuration.inMinutes.remainder(60)}m',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _endFasting,
                    icon: const Icon(Icons.stop),
                    label: Text(isComplete ? 'Complete' : 'End Early'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Ready to Start Fasting?',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a fasting schedule and begin your journey',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _showStartDialog,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Fasting'),
              style: FilledButton.styleFrom(minimumSize: const Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalCompleted = _stats['totalCompleted'] ?? 0;
    final totalHours = (_stats['totalHours'] ?? 0.0).toStringAsFixed(1);
    final avgHours = (_stats['averageHours'] ?? 0.0).toStringAsFixed(1);
    final streak = _stats['currentStreak'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.check_circle,
                    label: 'Completed',
                    value: '$totalCompleted',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.access_time,
                    label: 'Total Hours',
                    value: totalHours,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.trending_up,
                    label: 'Avg Hours',
                    value: avgHours,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.local_fire_department,
                    label: 'Streak',
                    value: '$streak days',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'About Intermittent Fasting',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Intermittent fasting involves cycling between periods of eating and fasting. Popular methods include 16:8 (fast 16 hours, eat within 8 hours) and 18:6.',
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              '💡 Tips for Success:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            _buildTip('Stay hydrated during fasting'),
            _buildTip('Start with easier schedules (12:12 or 14:10)'),
            _buildTip('Listen to your body'),
            _buildTip('Break your fast with nutritious foods'),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.grey[600])),
          Expanded(
            child: Text(tip, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Future<void> _showHistory() async {
    final history = await FastingService.getHistory();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.history, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Fasting History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: history.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timeline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No fasting history yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: history.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final session = history[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: session.wasCompleted
                                  ? Colors.green
                                  : Colors.orange,
                              child: Icon(
                                session.wasCompleted
                                    ? Icons.check
                                    : Icons.timelapse,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(session.fastingType),
                            subtitle: Text(
                              '${session.elapsedDuration.inHours}h ${session.elapsedDuration.inMinutes.remainder(60)}m • ${_formatDate(session.startTime)}',
                            ),
                            trailing: session.wasCompleted
                                ? const Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class _FastingPresetDialog extends StatelessWidget {
  const _FastingPresetDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Choose Fasting Schedule',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...FastingPreset.presets.map(
                    (preset) => _buildPresetTile(context, preset),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetTile(BuildContext context, FastingPreset preset) {
    Color? difficultyColor;
    switch (preset.difficulty) {
      case 'Very Easy':
        difficultyColor = Colors.green[700];
        break;
      case 'Easy':
        difficultyColor = Colors.lightGreen[700];
        break;
      case 'Medium':
        difficultyColor = Colors.orange[700];
        break;
      case 'Hard':
        difficultyColor = Colors.deepOrange[700];
        break;
      case 'Very Hard':
        difficultyColor = Colors.red[700];
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.pop(context, preset),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    preset.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor?.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      preset.difficulty,
                      style: TextStyle(
                        fontSize: 12,
                        color: difficultyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                preset.description,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
