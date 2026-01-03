import 'package:flutter/material.dart';

import '../../../core/extensions/duration_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/route_entity.dart';
import '../../../domain/enums/transport_type.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/transport_icon.dart';

/// Card widget displaying a route
class RouteCard extends StatelessWidget {
  final RouteEntity route;
  final VoidCallback onTap;

  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Transport icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getTransportColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: TransportIcon(
                transport: route.transport,
                size: 28,
                color: _getTransportColor(),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Route info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  route.title,
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Description
                Text(
                  route.description,
                  style: AppTypography.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Duration
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      route.duration.toReadableString(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arrow icon
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Color _getTransportColor() {
    switch (route.transport) {
      case TransportType.train:
        return AppColors.trainColor;
      case TransportType.car:
        return AppColors.carColor;
      case TransportType.ferry:
        return AppColors.ferryColor;
    }
  }
}
