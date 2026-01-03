import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Statistics screen - shows focus session history and streaks
/// TODO: Implement in Step 6
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: const Center(
        child: Text(
          'Statistics Screen\n(To be implemented in Step 6)',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
