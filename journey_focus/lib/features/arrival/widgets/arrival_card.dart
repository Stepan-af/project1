import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../shared/widgets/app_card.dart';

/// Card displaying arrival information
class ArrivalCard extends StatelessWidget {
  final String routeTitle;
  final Duration actualDuration;
  final int currentStreak;

  const ArrivalCard({
    super.key,
    required this.routeTitle,
    required this.actualDuration,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 48,
              color: AppColors.success,
            ),
          ),

          const SizedBox(height: 24),

          // "You have arrived" message
          Text(
            'You have arrived',
            style: AppTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Route title
          Text(
            routeTitle,
            style: AppTypography.titleLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                actualDuration.toReadableString(),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // Streak (if > 0)
          if (currentStreak > 0) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 20,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$currentStreak day streak!',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
