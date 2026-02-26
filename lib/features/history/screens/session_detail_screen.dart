import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/rep_log.dart';
import '../../../data/models/workout_session.dart';

class SessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;

  // In a real app these would be loaded from the repository.
  // For scaffold purposes we accept an optional list.
  final List<RepLog> repLogs;

  const SessionDetailScreen({
    super.key,
    required this.session,
    this.repLogs = const [],
  });

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, y – HH:mm').format(session.startedAt);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Session Detail',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E5FF33)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.exerciseType,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(dateStr,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _InfoChip(
                        label: '${session.totalReps} reps',
                        icon: Icons.repeat,
                      ),
                      const SizedBox(width: 10),
                      _InfoChip(
                        label: _formatDuration(session.durationSeconds),
                        icon: Icons.timer,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (repLogs.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Angle Progression',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _AngleChart(repLogs: repLogs),
              const SizedBox(height: 24),
              const Text(
                'Rep Breakdown',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...repLogs.map((log) => _RepLogTile(log: log)),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Center(
                  child: Text(
                    'No rep-level data available.',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF00E5FF1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00E5FF4D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF00E5FF), size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF00E5FF), fontSize: 12)),
        ],
      ),
    );
  }
}

class _AngleChart extends StatelessWidget {
  final List<RepLog> repLogs;

  const _AngleChart({required this.repLogs});

  @override
  Widget build(BuildContext context) {
    final bars = repLogs.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.jointAngleAtBottom,
            color: const Color(0xFF00E5FF),
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          barGroups: bars,
          backgroundColor: const Color(0xFF111111),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) => Text(
                  '${val.toInt() + 1}',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 10),
                ),
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
        ),
      ),
    );
  }
}

class _RepLogTile extends StatelessWidget {
  final RepLog log;

  const _RepLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF00E5FF1A)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${log.repNumber}',
              style: const TextStyle(
                  color: Color(0xFF00E5FF), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AngleStat(
                    label: 'Bottom',
                    angle: log.jointAngleAtBottom),
                _AngleStat(
                    label: 'Top', angle: log.jointAngleAtTop),
                Text(
                  '${log.durationMs}ms',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AngleStat extends StatelessWidget {
  final String label;
  final double angle;

  const _AngleStat({required this.label, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: Colors.white38, fontSize: 10)),
        Text(
          '${angle.toStringAsFixed(1)}°',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
