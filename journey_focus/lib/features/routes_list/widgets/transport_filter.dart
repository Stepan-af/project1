import 'package:flutter/material.dart';
import '../../../domain/enums/transport_type.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Filter chips for transport types
class TransportFilter extends StatelessWidget {
  final TransportType? selectedTransport;
  final ValueChanged<TransportType?> onTransportSelected;

  const TransportFilter({
    super.key,
    this.selectedTransport,
    required this.onTransportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // All filter
          _FilterChip(
            label: 'All',
            isSelected: selectedTransport == null,
            onTap: () => onTransportSelected(null),
          ),

          const SizedBox(width: 8),

          // Transport type filters
          ...TransportType.values.map(
            (transport) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: transport.displayName,
                isSelected: selectedTransport == transport,
                onTap: () => onTransportSelected(transport),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: AppTypography.labelMedium.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
      ),
    );
  }
}
