import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/extensions/duration_extensions.dart';
import '../../services/statistics_service.dart';
import 'statistics_controller.dart';
import 'widgets/stat_card.dart';

/// Statistics screen - shows focus session history and streaks
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final StatisticsController _controller;

  @override
  void initState() {
    super.initState();
    final statisticsService = context.read<StatisticsService>();
    _controller = StatisticsController(statisticsService: statisticsService);
    _controller.loadStatistics();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.refresh,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_controller.error != null) {
            return _buildErrorState(_controller.error!);
          }

          return _buildStatisticsUI();
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _controller.refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsUI() {
    final stats = _controller.statistics;

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Today section
            Text(
              'Today',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Sessions',
                    value: '${stats.todaySessions}',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Focus Time',
                    value: stats.todayFocusTime.toReadableString(),
                    icon: Icons.access_time,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Last 7 days section
            Text(
              'Last 7 Days',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Sessions',
                    value: '${stats.weekSessions}',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Focus Time',
                    value: stats.weekFocusTime.toReadableString(),
                    icon: Icons.access_time,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // All time section
            Text(
              'All Time',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Sessions',
                    value: '${stats.allTimeSessions}',
                    icon: Icons.history,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Total Focus Time',
                    value: stats.allTimeFocusTime.toReadableString(),
                    icon: Icons.timer,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Current streak
            Text(
              'Current Streak',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 12),
            StatCard(
              title: 'Days',
              value: '${stats.currentStreak}',
              subtitle: stats.currentStreak > 0
                  ? 'Keep it up! 🔥'
                  : 'Start your journey today',
              icon: Icons.local_fire_department,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
