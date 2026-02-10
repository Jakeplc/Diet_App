import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/body_composition.dart';
import '../models/user_profile.dart';
import '../services/body_composition_service.dart';
import '../services/storage_service.dart';

class BodyCompositionScreen extends StatefulWidget {
  const BodyCompositionScreen({super.key});

  @override
  State<BodyCompositionScreen> createState() => _BodyCompositionScreenState();
}

class _BodyCompositionScreenState extends State<BodyCompositionScreen> {
  List<BodyComposition> _entries = [];
  UserProfile? _profile;
  String _selectedMetric = 'bodyFat';
  final int _selectedDays = 30;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await BodyCompositionService.init();
    final entries = BodyCompositionService.getAllEntries();
    final profile = StorageService.getUserProfile();

    setState(() {
      _entries = entries;
      _profile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Composition'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade700, Colors.purple.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // Premium notice
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
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
                              'Premium Feature: Advanced body composition tracking',
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

                  // Latest measurements card
                  if (_entries.isNotEmpty) _buildLatestCard(),

                  // Metric selector
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Track Metric',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildMetricChip(
                                'bodyFat',
                                'Body Fat %',
                                Icons.fitness_center,
                              ),
                              _buildMetricChip(
                                'muscleMass',
                                'Muscle Mass',
                                Icons.self_improvement,
                              ),
                              _buildMetricChip(
                                'waist',
                                'Waist',
                                Icons.straighten,
                              ),
                              _buildMetricChip(
                                'hips',
                                'Hips',
                                Icons.straighten,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Chart
                  if (_entries.length >= 2) _buildChartCard(),

                  // Stats cards
                  if (_entries.isNotEmpty) _buildStatsCards(),

                  // Empty state
                  if (_entries.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assessment,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No measurements yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first entry',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntry,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildMetricChip(String metric, String label, IconData icon) {
    final isSelected = _selectedMetric == metric;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.purple,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedMetric = metric);
        }
      },
      selectedColor: Colors.purple,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
    );
  }

  Widget _buildLatestCard() {
    final latest = _entries.first;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest Measurements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDate(latest.timestamp),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                if (latest.bodyFatPercentage != null)
                  _buildMeasurementItem(
                    'Body Fat',
                    '${latest.bodyFatPercentage!.toStringAsFixed(1)}%',
                    Icons.fitness_center,
                    Colors.orange,
                  ),
                if (latest.muscleMass != null)
                  _buildMeasurementItem(
                    'Muscle',
                    '${latest.muscleMass!.toStringAsFixed(1)} kg',
                    Icons.self_improvement,
                    Colors.blue,
                  ),
                if (latest.waist != null)
                  _buildMeasurementItem(
                    'Waist',
                    '${latest.waist!.toStringAsFixed(1)} cm',
                    Icons.straighten,
                    Colors.red,
                  ),
                if (latest.waterPercentage != null)
                  _buildMeasurementItem(
                    'Water',
                    '${latest.waterPercentage!.toStringAsFixed(1)}%',
                    Icons.water_drop,
                    Colors.cyan,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    final chartData = BodyCompositionService.getChartData(
      _selectedMetric,
      _selectedDays,
    );

    if (chartData.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['value'] as double?) ?? 0,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats = BodyCompositionService.getMetricStats(
      _selectedMetric,
      _selectedDays,
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Average',
                stats['average']?.toStringAsFixed(1) ?? '--',
                Icons.analytics,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Change',
                stats['change'] != null
                    ? '${stats['change'] > 0 ? '+' : ''}${stats['change'].toStringAsFixed(1)}'
                    : '--',
                stats['trend'] == 'increasing'
                    ? Icons.trending_up
                    : stats['trend'] == 'decreasing'
                    ? Icons.trending_down
                    : Icons.trending_flat,
                stats['trend'] == 'increasing'
                    ? Colors.green
                    : stats['trend'] == 'decreasing'
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _addEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddEntrySheet(
        onSave: () {
          _loadData();
        },
        profile: _profile,
      ),
    );
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _HistoryScreen(entries: _entries, profile: _profile),
      ),
    ).then((_) => _loadData());
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _AddEntrySheet extends StatefulWidget {
  final VoidCallback onSave;
  final UserProfile? profile;

  const _AddEntrySheet({required this.onSave, this.profile});

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _waterController = TextEditingController();
  final _visceralFatController = TextEditingController();
  final _neckController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _waterController.dispose();
    _visceralFatController.dispose();
    _neckController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Body Composition',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Body Composition',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bodyFatController,
                        decoration: const InputDecoration(
                          labelText: 'Body Fat %',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _muscleMassController,
                        decoration: const InputDecoration(
                          labelText: 'Muscle (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _waterController,
                        decoration: const InputDecoration(
                          labelText: 'Water %',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _visceralFatController,
                        decoration: const InputDecoration(
                          labelText: 'Visceral Fat',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  'Measurements (cm)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _neckController,
                        decoration: const InputDecoration(
                          labelText: 'Neck',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _chestController,
                        decoration: const InputDecoration(
                          labelText: 'Chest',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _waistController,
                        decoration: const InputDecoration(
                          labelText: 'Waist',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _hipsController,
                        decoration: const InputDecoration(
                          labelText: 'Hips',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() async {
    final entry = BodyComposition(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      bodyFatPercentage: _parseDouble(_bodyFatController.text),
      muscleMass: _parseDouble(_muscleMassController.text),
      waterPercentage: _parseDouble(_waterController.text),
      visceralFat: _parseDouble(_visceralFatController.text),
      neck: _parseDouble(_neckController.text),
      chest: _parseDouble(_chestController.text),
      waist: _parseDouble(_waistController.text),
      hips: _parseDouble(_hipsController.text),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    await BodyCompositionService.saveEntry(entry);
    widget.onSave();
    if (mounted) Navigator.pop(context);
  }

  double? _parseDouble(String text) {
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }
}

class _HistoryScreen extends StatelessWidget {
  final List<BodyComposition> entries;
  final UserProfile? profile;

  const _HistoryScreen({required this.entries, this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Measurement History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Icon(Icons.assessment, color: Colors.purple.shade700),
              ),
              title: Text(_formatDate(entry.timestamp)),
              subtitle: _buildSubtitle(entry),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEntry(context, entry),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubtitle(BodyComposition entry) {
    final items = <String>[];
    if (entry.bodyFatPercentage != null) {
      items.add('BF: ${entry.bodyFatPercentage!.toStringAsFixed(1)}%');
    }
    if (entry.muscleMass != null) {
      items.add('Muscle: ${entry.muscleMass!.toStringAsFixed(1)} kg');
    }
    if (entry.waist != null) {
      items.add('Waist: ${entry.waist!.toStringAsFixed(1)} cm');
    }

    return Text(items.isEmpty ? 'No measurements' : items.join(' â€¢ '));
  }

  void _deleteEntry(BuildContext context, BodyComposition entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await BodyCompositionService.deleteEntry(entry.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
