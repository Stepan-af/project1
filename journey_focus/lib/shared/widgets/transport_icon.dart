import 'package:flutter/material.dart';
import '../../domain/enums/transport_type.dart';
import '../../core/theme/app_colors.dart';

/// Widget that displays an icon for a transport type
class TransportIcon extends StatelessWidget {
  final TransportType transport;
  final double size;
  final Color? color;

  const TransportIcon({
    super.key,
    required this.transport,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIcon(),
      size: size,
      color: color ?? _getDefaultColor(),
    );
  }

  IconData _getIcon() {
    switch (transport) {
      case TransportType.train:
        return Icons.train_rounded;
      case TransportType.car:
        return Icons.directions_car_rounded;
      case TransportType.ferry:
        return Icons.directions_boat_rounded;
    }
  }

  Color _getDefaultColor() {
    switch (transport) {
      case TransportType.train:
        return AppColors.trainColor;
      case TransportType.car:
        return AppColors.carColor;
      case TransportType.ferry:
        return AppColors.ferryColor;
    }
  }
}
