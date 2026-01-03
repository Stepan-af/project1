import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/routes_repository.dart';
import '../../navigation/app_router.dart';
import 'routes_list_controller.dart';
import 'widgets/route_card.dart';
import 'widgets/search_bar.dart';
import 'widgets/transport_filter.dart';

/// Routes list screen - displays all available journey routes
class RoutesListScreen extends StatefulWidget {
  const RoutesListScreen({super.key});

  @override
  State<RoutesListScreen> createState() => _RoutesListScreenState();
}

class _RoutesListScreenState extends State<RoutesListScreen> {
  late final RoutesListController _controller;

  @override
  void initState() {
    super.initState();
    final routesRepository = context.read<RoutesRepository>();
    _controller = RoutesListController(routesRepository: routesRepository);
    _controller.loadRoutes();
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
        title: const Text('Journey Focus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.statistics);
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_controller.error != null) {
            return _buildErrorState(_controller.error!);
          }

          return Column(
            children: [
              // Search bar
              RoutesSearchBar(
                query: _controller.searchQuery,
                onQueryChanged: _controller.setSearchQuery,
              ),

              // Transport filter
              TransportFilter(
                selectedTransport: _controller.selectedTransport,
                onTransportSelected: _controller.setTransportFilter,
              ),

              const SizedBox(height: 8),

              // Routes list
              Expanded(
                child: _controller.routes.isEmpty
                    ? _buildEmptyState()
                    : _buildRoutesList(),
              ),
            ],
          );
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
              onPressed: _controller.loadRoutes,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No routes found',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.routes.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final route = _controller.routes[index];
        return RouteCard(
          route: route,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.routeDetails,
              arguments: route.id,
            );
          },
        );
      },
    );
  }
}
