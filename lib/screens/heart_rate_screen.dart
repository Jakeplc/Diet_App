import 'package:flutter/material.dart';
import '../services/heart_rate_service.dart';
import '../models/heart_rate_log.dart';

class HeartRateScreen extends StatefulWidget {
  final bool isPremium;

  const HeartRateScreen({required this.isPremium, super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen> {
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<List<HeartRateLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _statsFuture = HeartRateService.getHeartRateStats(24);
    _logsFuture = HeartRateService.getHeartRateLogs(24);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate'),
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
                    colors: [Colors.red.shade400, Colors.pink.shade400],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      );
                    }

                    final stats = snapshot.data!;
                    final avgBpm = stats['averageBpm'] as int;
                    final zone = HeartRateService.getHRZone(avgBpm);

                    return Column(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$avgBpm',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'BPM',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            zone,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatCard(
                              title: 'Max',
                              value: '${stats['maxBpm']}',
                              subtitle: 'BPM',
                            ),
                            _StatCard(
                              title: 'Min',
                              value: '${stats['minBpm']}',
                              subtitle: 'BPM',
                            ),
                            _StatCard(
                              title: 'Resting',
                              value: '${stats['restingBpm']}',
                              subtitle: 'BPM',
                            ),
                            _StatCard(
                              title: 'HRV',
                              value: '${stats['hrv']}',
                              subtitle: 'Var',
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Readings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<List<HeartRateLog>>(
                      future: _logsFuture,
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
                            final zone = HeartRateService.getHRZone(log.bpm);
                            final emoji = HeartRateService.getHRZoneEmoji(
                              log.bpm,
                            );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${log.bpm} BPM - $zone',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')} • ${log.source}',
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: HeartRateService.getHRZoneColor(
                                          log.bpm,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        zone,
                                        style: TextStyle(
                                          color:
                                              HeartRateService.getHRZoneColor(
                                                log.bpm,
                                              ),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                        onPressed: () => _showHeartRateDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Log Heart Rate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
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

  void _showHeartRateDialog() {
    int bpm = 70;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Log Heart Rate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: bpm.toDouble(),
                min: 40,
                max: 200,
                divisions: 160,
                label: '$bpm BPM',
                onChanged: (v) => setState(() => bpm = v.toInt()),
              ),
              const SizedBox(height: 12),
              Text(
                '$bpm BPM',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                HeartRateService.getHRZone(bpm),
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final log = HeartRateLog(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  timestamp: DateTime.now(),
                  bpm: bpm,
                  source: 'manual',
                  activityType: bpm < 100
                      ? 'resting'
                      : bpm < 150
                      ? 'moderate'
                      : 'intense',
                );

                HeartRateService.logHeartRate(log).then((_) {
                  setState(() => _refreshData());
                  Navigator.pop(context);
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 9),
        ),
      ],
    );
  }
}
