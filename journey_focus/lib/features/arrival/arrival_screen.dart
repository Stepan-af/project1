import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/routes_repository.dart';
import '../../navigation/app_router.dart';
import '../../shared/widgets/app_button.dart';
import 'arrival_controller.dart';
import 'widgets/arrival_card.dart';

/// Arrival screen - shown when focus session completes
class ArrivalScreen extends StatefulWidget {
  final ArrivalScreenArgs args;

  const ArrivalScreen({
    super.key,
    required this.args,
  });

  @override
  State<ArrivalScreen> createState() => _ArrivalScreenState();
}

class _ArrivalScreenState extends State<ArrivalScreen> {
  late final ArrivalController _controller;

  @override
  void initState() {
    super.initState();
    final routesRepository = context.read<RoutesRepository>();
    _controller = ArrivalController(
      routeId: widget.args.routeId,
      actualDurationSeconds: widget.args.actualDurationSeconds,
      routesRepository: routesRepository,
    );
    _controller.loadData();
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
      body: SafeArea(
        child: ListenableBuilder(
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

            return _buildArrivalUI();
          },
        ),
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

  Widget _buildArrivalUI() {
    final route = _controller.route!;
    final duration = Duration(seconds: widget.args.actualDurationSeconds);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Arrival card
          ArrivalCard(
            routeTitle: route.title,
            actualDuration: duration,
            currentStreak: _controller.currentStreak,
          ),

          const SizedBox(height: 32),

          // Action buttons
          Column(
            children: [
              // Share button
              AppButton(
                label: 'Share',
                icon: Icons.share_rounded,
                onPressed: _controller.shareCompletion,
                isExpanded: true,
              ),

              const SizedBox(height: 12),

              // Repeat route button
              AppButton(
                label: 'Repeat Route',
                icon: Icons.repeat_rounded,
                style: AppButtonStyle.secondary,
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRouter.session,
                    arguments: route.id,
                  );
                },
                isExpanded: true,
              ),

              const SizedBox(height: 12),

              // Back to list button
              AppButton(
                label: 'Back to Routes',
                style: AppButtonStyle.text,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.routesList,
                    (route) => false,
                  );
                },
                isExpanded: true,
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
