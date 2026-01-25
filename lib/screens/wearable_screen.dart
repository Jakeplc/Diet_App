import 'package:flutter/material.dart';
import '../models/activity_log.dart';
import '../services/health_integration_service.dart';
import '../services/premium_service.dart';

class WearableScreen extends StatefulWidget {
  const WearableScreen({super.key});

  @override
  State<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends State<WearableScreen> {
  List<WearableDevice> _availableDevices = [];
  List<ActivityLog> _activities = [];
  bool _isPremium = false;
  bool _isSyncing = false;
  late Map<String, dynamic> _activityStats;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isPremium = await PremiumService.isPremium();
    final devices = await HealthIntegrationService.getAvailableDevices();
    final activities = await HealthIntegrationService.getRecentActivities();
    final stats = await HealthIntegrationService.getActivityStats();

    setState(() {
      _isPremium = isPremium;
      _availableDevices = devices;
      _activities = activities.take(10).toList(); // Show last 10
      _activityStats = stats;
    });
  }

  Future<void> _connectDevice(WearableDevice device) async {
    setState(() => _isSyncing = true);

    final success = await HealthIntegrationService.connectDevice(device.id);

    if (success) {
      await _syncActivities();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Connected to ${device.name}')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to connect device')));
    }

    setState(() => _isSyncing = false);
    await _loadData();
  }

  Future<void> _disconnectDevice(WearableDevice device) async {
    await HealthIntegrationService.disconnectDevice(device.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Disconnected from ${device.name}')));
    await _loadData();
  }

  Future<void> _syncActivities() async {
    setState(() => _isSyncing = true);

    await HealthIntegrationService.syncActivities();

    setState(() => _isSyncing = false);
    await _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activities synced successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPremium) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wearable Devices')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey.shade600),
              const SizedBox(height: 16),
              const Text(
                'Premium Feature',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Unlock wearable integration\nand activity tracking',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.star),
                label: const Text('Upgrade to Premium'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient Header
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Wearable Devices'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple[600]!, Colors.pink[400]!],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⌚', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text(
                        'Connected Health Devices',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity Stats
                  _buildStatsSection(),
                  const SizedBox(height: 24),

                  // Connected Devices
                  Text(
                    'Connected Devices',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ..._availableDevices.map(
                    (device) => _buildDeviceCard(device),
                  ),
                  const SizedBox(height: 24),

                  // Sync Button
                  if (HealthIntegrationService.getConnectedDevices().isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSyncing ? null : _syncActivities,
                        icon: _isSyncing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Recent Activities
                  Text(
                    'Recent Activities',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (_activities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No activities yet. Connect a device to see data.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final activity = _activities[index];
                        return _buildActivityCard(activity);
                      },
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

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[50]!, Colors.pink[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week Activity',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '🔥',
                  '${_activityStats['weeklyCalories']}',
                  'Calories',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '🚶',
                  '${_activityStats['weeklySteps']}',
                  'Steps',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  '💪',
                  '${_activityStats['weeklyActivities']}',
                  'Activities',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildDeviceCard(WearableDevice device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(device.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (device.isConnected && device.lastSyncTime != null)
                    Text(
                      'Last sync: ${device.lastSyncTime!.difference(DateTime.now()).inMinutes < 60 ? '${device.lastSyncTime!.difference(DateTime.now()).inMinutes.abs()} min ago' : 'Recently'}',
                      style: TextStyle(fontSize: 12, color: Colors.green[600]),
                    )
                  else
                    Text(
                      'Not connected',
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _isSyncing
                  ? null
                  : () {
                      if (device.isConnected) {
                        _disconnectDevice(device);
                      } else {
                        _connectDevice(device);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: device.isConnected
                    ? Colors.red[300]
                    : Colors.green[300],
              ),
              child: Text(
                device.isConnected ? 'Disconnect' : 'Connect',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityLog activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.activityType,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${activity.date.month}/${activity.date.day} • ${activity.durationMinutes} min',
                        style: TextStyle(color: Colors.grey[800], fontSize: 12),
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
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🔥 ${activity.caloriesBurned}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (activity.steps > 0)
                  Expanded(
                    child: _buildActivityStat('🚶 ${activity.steps} steps'),
                  ),
                if (activity.distance > 0)
                  Expanded(
                    child: _buildActivityStat(
                      '📍 ${activity.distance.toStringAsFixed(1)} km',
                    ),
                  ),
                Expanded(
                  child: _buildActivityStat(
                    '${activity.intensity[0].toUpperCase()}${activity.intensity.substring(1)} intensity',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityStat(String text) {
    return Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[800]));
  }
}
