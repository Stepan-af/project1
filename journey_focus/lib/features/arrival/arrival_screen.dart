import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../navigation/app_router.dart';

/// Arrival screen - shown when focus session completes
/// TODO: Implement in Step 6
class ArrivalScreen extends StatelessWidget {
  final ArrivalScreenArgs args;

  const ArrivalScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          'Arrival Screen\nRoute ID: ${args.routeId}\n(To be implemented in Step 6)',
          style: AppTypography.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
