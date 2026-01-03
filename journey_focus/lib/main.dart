import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/routes_repository.dart';
import 'services/session_engine.dart';
import 'services/share_service.dart';
import 'services/statistics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only for focus app)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  final sessionEngine = SessionEngine();
  final routesRepository = RoutesRepository();
  final statisticsService = StatisticsService();
  final shareService = ShareService();

  // Try to restore active session
  await _restoreSession(sessionEngine, routesRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionEngine),
        Provider.value(value: routesRepository),
        Provider.value(value: statisticsService),
        Provider.value(value: shareService),
      ],
      child: const JourneyFocusApp(),
    ),
  );
}

/// Restore active session from database if exists
///
/// If an active session is found, it will be restored.
/// The route is loaded asynchronously from the repository.
Future<void> _restoreSession(
  SessionEngine sessionEngine,
  RoutesRepository routesRepository,
) async {
  try {
    await sessionEngine.restoreSession((routeId) async {
      final route = await routesRepository.getRouteById(routeId);
      if (route == null) {
        throw StateError('Route not found: $routeId');
      }
      return route;
    });
  } catch (_) {
    // If restore fails (e.g., route not found, session expired), that's OK
    // User will start fresh or the session screen will handle it gracefully
  }
}
