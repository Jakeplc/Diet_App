import 'package:flutter/material.dart';
import '../models/sleep_log.dart';
import '../services/sleep_step_service.dart';

class SleepTrackingScreen extends StatefulWidget {
  final bool isPremium;

  const SleepTrackingScreen({required this.isPremium, super.key});

  @override
  State<SleepTrackingScreen> createState() => _SleepTrackingScreenState();
}

class _SleepTrackingScreenState extends State<SleepTrackingScreen> {
  late Future<Map<String, dynamic>> _sleepStatsFuture;
  late Future<List<SleepLog>> _sleepLogsFuture;

  int selectedQuality = 3; // good

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _sleepStatsFuture = SleepTrackingService.getSleepStats(30);
    _sleepLogsFuture = SleepTrackingService.getSleepLogs(30);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sleep Tracking'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _refreshData());
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade400, Colors.indigo.shade400],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.dark_mode, color: Colors.white, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Sleep Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _sleepStatsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          );
                        }

                        final stats = snapshot.data!;
                        final avgHours =
                            (stats['averageDuration'] as int) ~/ 60;
                        final avgMinutes =
                            (stats['averageDuration'] as int) % 60;

                        return Column(
                          children: [
                            Text(
                              '${avgHours}h ${avgMinutes}m',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Average per night',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatCard(
                                  title: 'Nights',
                                  value: '${stats['totalNights']}',
                                ),
                                _StatCard(
                                  title: 'Best Night',
                                  value:
                                      '${(stats['bestNight'] as int) ~/ 60}h',
                                ),
                                _StatCard(
                                  title: 'Score',
                                  value: '${stats['qualityScore']}',
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sleep History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<SleepLog>>(
                      future: _sleepLogsFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final logs = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            final hours = log.durationMinutes ~/ 60;
                            final minutes = log.durationMinutes % 60;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${log.date.month}/${log.date.day}/${log.date.year}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getQualityColor(
                                              log.quality,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            '${SleepTrackingService.getQualityEmoji(log.quality)} ${log.quality}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$hours hours $minutes minutes',
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${SleepTrackingService.formatTime(log.bedtime)} - ${SleepTrackingService.formatTime(log.wakeTime)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (log.tags.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Wrap(
                                          spacing: 6,
                                          children: log.tags
                                              .map(
                                                (tag) => Chip(
                                                  label: Text(tag),
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  labelStyle: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showSleepDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Log Sleep'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSleepDialog() {
    int bedtime = 2300;
    int wakeTime = 630;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Sleep'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Bedtime:'),
                Text(
                  SleepTrackingService.formatTime(bedtime),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: bedtime.toDouble(),
                  min: 1900,
                  max: 2359,
                  onChanged: (v) => setState(() => bedtime = v.toInt()),
                ),
                const SizedBox(height: 16),
                const Text('Wake Time:'),
                Text(
                  SleepTrackingService.formatTime(wakeTime),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: wakeTime.toDouble(),
                  min: 500,
                  max: 900,
                  onChanged: (v) => setState(() => wakeTime = v.toInt()),
                ),
                const SizedBox(height: 16),
                const Text('Sleep Quality:'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['poor', 'fair', 'good', 'excellent']
                      .asMap()
                      .entries
                      .map(
                        (e) => GestureDetector(
                          onTap: () => setState(() => selectedQuality = e.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: selectedQuality == e.key
                                  ? _getQualityColor(e.value)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${SleepTrackingService.getQualityEmoji(e.value)} ${e.value}',
                              style: TextStyle(
                                color: selectedQuality == e.key
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final qualityList = ['poor', 'fair', 'good', 'excellent'];
                final log = SleepLog(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  date: DateTime.now(),
                  durationMinutes: _calculateDuration(bedtime, wakeTime),
                  bedtime: bedtime,
                  wakeTime: wakeTime,
                  quality: qualityList[selectedQuality],
                  deepSleepMinutes:
                      (_calculateDuration(bedtime, wakeTime) * 0.3).toInt(),
                  remMinutes: (_calculateDuration(bedtime, wakeTime) * 0.2)
                      .toInt(),
                  source: 'manual',
                  tags: [],
                  createdAt: DateTime.now(),
                );

                await SleepTrackingService.logSleep(log);
                if (!context.mounted) return;
                setState(() => _refreshData());
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateDuration(int bedtime, int wakeTime) {
    int startMinutes = (bedtime ~/ 100) * 60 + (bedtime % 100);
    int endMinutes = (wakeTime ~/ 100) * 60 + (wakeTime % 100);

    if (endMinutes <= startMinutes) {
      endMinutes += 24 * 60;
    }

    return endMinutes - startMinutes;
  }

  Color _getQualityColor(String quality) {
    switch (quality) {
      case 'poor':
        return Colors.red;
      case 'fair':
        return Colors.amber;
      case 'good':
        return Colors.blue;
      case 'excellent':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
