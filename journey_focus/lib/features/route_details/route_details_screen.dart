import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/routes_repository.dart';
import '../../domain/enums/transport_type.dart';
import '../../navigation/app_router.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/transport_icon.dart';
import 'route_details_controller.dart';
import 'widgets/route_map.dart';

/// Route details screen - shows route info with map preview
class RouteDetailsScreen extends StatefulWidget {
  final String routeId;

  const RouteDetailsScreen({
    super.key,
    required this.routeId,
  });

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  late final RouteDetailsController _controller;

  @override
  void initState() {
    super.initState();
    final routesRepository = context.read<RoutesRepository>();
    _controller = RouteDetailsController(
      routeId: widget.routeId,
      routesRepository: routesRepository,
    );
    _controller.loadRoute();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Route Details'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_controller.error != null || _controller.route == null) {
            return _buildErrorState(_controller.error ?? 'Route not found');
          }

          return _buildRouteDetails(_controller.route!);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteDetails(route) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Map preview
          Container(
            height: 300,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: RouteMap(route: route),
            ),
          ),

          // Route info card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and transport
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        route.title,
                        style: AppTypography.headlineMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getTransportColor(route.transport)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TransportIcon(
                            transport: route.transport,
                            size: 16,
                            color: _getTransportColor(route.transport),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            route.transport.displayName,
                            style: AppTypography.labelSmall.copyWith(
                              color: _getTransportColor(route.transport),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Duration
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      route.duration.toReadableString(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  route.description,
                  style: AppTypography.bodyMedium,
                ),

                const SizedBox(height: 32),

                // Start Journey button
                AppButton(
                  label: 'Start Journey',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.session,
                      arguments: route.id,
                    );
                  },
                  isExpanded: true,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransportColor(TransportType transport) {
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
