import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Routes list screen - displays all available journey routes
/// TODO: Implement in Step 6
class RoutesListScreen extends StatelessWidget {
  const RoutesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journey Focus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/statistics');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Routes List Screen\n(To be implemented in Step 6)',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
