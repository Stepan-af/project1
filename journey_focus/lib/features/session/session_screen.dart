import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/session_engine.dart';
import '../../navigation/app_router.dart';
import 'session_controller.dart';
import 'widgets/session_map.dart';
import 'widgets/countdown_timer.dart';
import 'widgets/progress_bar.dart';
import 'widgets/session_controls.dart';

/// Session screen - active focus session with timer and map
///
/// This screen should feel:
/// - quiet
/// - focused
/// - immersive
class SessionScreen extends StatefulWidget {
  final String routeId;

  const SessionScreen({
    super.key,
    required this.routeId,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> with WidgetsBindingObserver {
  late final SessionController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final sessionEngine = context.read<SessionEngine>();
    _controller = SessionController(sessionEngine: sessionEngine);
    _controller.initialize(widget.routeId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh time when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      context.read<SessionEngine>().refreshTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return _buildLoadingState();
        }

        if (_controller.error != null) {
          return _buildErrorState(_controller.error!);
        }

        if (_controller.route == null) {
          return _buildErrorState('Route not found');
        }

        // Check if session completed
        if (_controller.hasReachedEnd || !_controller.hasActiveSession) {
          // Navigate to arrival screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToArrival();
          });
        }

        return _buildSessionUI();
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Session'),
      ),
      body: Center(
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
      ),
    );
  }

  Widget _buildSessionUI() {
    final route = _controller.route!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with route title
            _buildHeader(route.title),

            // Map section (takes about 40% of screen)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SessionMap(
                    route: route,
                    progress: _controller.progress,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Timer section
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Countdown timer
                    CountdownTimer(
                      remainingSeconds: _controller.remainingSeconds,
                      isPaused: _controller.isPaused,
                    ),

                    const SizedBox(height: 24),

                    // Progress bar
                    SessionProgressBar(
                      progress: _controller.progress,
                    ),

                    const Spacer(),

                    // Controls
                    SessionControls(
                      isPaused: _controller.isPaused,
                      onPauseResume: _controller.togglePauseResume,
                      onFinishEarly: _showFinishConfirmation,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button (with confirmation)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _showCancelConfirmation,
            color: AppColors.textSecondary,
          ),

          Expanded(
            child: Text(
              title,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Placeholder for symmetry
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  void _showFinishConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish Early?'),
        content: const Text(
          'Are you sure you want to finish this session early? '
          'Your progress will still be saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finishSession();
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Session?'),
        content: const Text(
          'Are you sure you want to cancel this session? '
          'Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelSession();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Cancel Session'),
          ),
        ],
      ),
    );
  }

  Future<void> _finishSession() async {
    final session = await _controller.finishSession(completed: true);
    if (mounted) {
      _navigateToArrivalWithSession(session.actualDurationSeconds);
    }
  }

  Future<void> _cancelSession() async {
    await _controller.cancelSession();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _navigateToArrival() {
    final session = _controller.session;
    if (session != null) {
      _navigateToArrivalWithSession(session.actualDurationSeconds);
    }
  }

  void _navigateToArrivalWithSession(int actualDurationSeconds) {
    Navigator.pushReplacementNamed(
      context,
      AppRouter.arrival,
      arguments: ArrivalScreenArgs(
        routeId: widget.routeId,
        sessionId: _controller.session?.id ?? '',
        actualDurationSeconds: actualDurationSeconds,
      ),
    );
  }
}
