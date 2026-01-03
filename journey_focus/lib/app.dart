import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'navigation/app_router.dart';
import 'services/session_engine.dart';

/// Main app widget
class JourneyFocusApp extends StatelessWidget {
  const JourneyFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: _getInitialRoute(context),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }

  /// Get initial route based on whether there's an active session
  String _getInitialRoute(BuildContext context) {
    try {
      final sessionEngine = context.read<SessionEngine>();
      if (sessionEngine.hasActiveSession && sessionEngine.activeRoute != null) {
        // Resume active session
        return AppRouter.session;
      }
    } catch (_) {
      // If provider not available, go to routes list
    }
    return AppRouter.routesList;
  }
}
