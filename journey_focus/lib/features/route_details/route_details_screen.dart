import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Route details screen - shows route info with map preview
/// TODO: Implement in Step 6
class RouteDetailsScreen extends StatelessWidget {
  final String routeId;

  const RouteDetailsScreen({
    super.key,
    required this.routeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Route Details'),
      ),
      body: Center(
        child: Text(
          'Route Details Screen\nRoute ID: $routeId\n(To be implemented in Step 6)',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
