import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';

/// Search bar for filtering routes
class RoutesSearchBar extends StatelessWidget {
  final String? query;
  final ValueChanged<String> onQueryChanged;

  const RoutesSearchBar({
    super.key,
    this.query,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: onQueryChanged,
        controller: query != null ? TextEditingController(text: query) : null,
        decoration: InputDecoration(
          hintText: 'Search routes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query != null && query!.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onQueryChanged(''),
                )
              : null,
        ),
        style: AppTypography.bodyMedium,
      ),
    );
  }
}
