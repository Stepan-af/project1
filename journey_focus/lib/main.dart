import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/session_engine.dart';
import 'data/repositories/routes_repository.dart';

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

  // Try to restore active session
  await _restoreSession(sessionEngine, routesRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionEngine),
        Provider.value(value: routesRepository),
      ],
      child: const JourneyFocusApp(),
    ),
  );
}

/// Restore active session from database if exists
Future<void> _restoreSession(
  SessionEngine sessionEngine,
  RoutesRepository routesRepository,
) async {
  try {
    await sessionEngine.restoreSession((routeId) {
      // This is synchronous, but we preload routes
      // For now, return a placeholder - actual route will be loaded in session screen
      throw UnimplementedError('Route resolver not implemented for restore');
    });
  } catch (_) {
    // If restore fails, that's OK - user will start fresh
  }
}
