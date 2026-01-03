import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/duration_extensions.dart';

/// Large countdown timer display for session screen
class CountdownTimer extends StatelessWidget {
  /// Remaining time in seconds
  final int remainingSeconds;

  /// Whether the session is paused
  final bool isPaused;

  const CountdownTimer({
    super.key,
    required this.remainingSeconds,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: remainingSeconds);
    final timeString = duration.toHoursMinutesSeconds();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Time display
        AnimatedOpacity(
          opacity: isPaused ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            timeString,
            style: AppTypography.timerLarge.copyWith(
              color: isPaused ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Status indicator
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isPaused
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  key: const ValueKey('paused'),
                  children: [
                    Icon(
                      Icons.pause_circle_outline,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Paused',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                )
              : Text(
                  'remaining',
                  key: const ValueKey('remaining'),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
        ),
      ],
    );
  }
}
