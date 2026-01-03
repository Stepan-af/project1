import 'package:flutter/material.dart';
import '../features/routes_list/routes_list_screen.dart';
import '../features/route_details/route_details_screen.dart';
import '../features/session/session_screen.dart';
import '../features/arrival/arrival_screen.dart';
import '../features/statistics/statistics_screen.dart';

/// App navigation routes
class AppRouter {
  AppRouter._();

  // Route names
  static const String routesList = '/';
  static const String routeDetails = '/route-details';
  static const String session = '/session';
  static const String arrival = '/arrival';
  static const String statistics = '/statistics';

  /// Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routesList:
        return MaterialPageRoute(
          builder: (_) => const RoutesListScreen(),
        );

      case routeDetails:
        final routeId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => RouteDetailsScreen(routeId: routeId),
        );

      case session:
        final routeId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => SessionScreen(routeId: routeId),
        );

      case arrival:
        final args = settings.arguments as ArrivalScreenArgs;
        return MaterialPageRoute(
          builder: (_) => ArrivalScreen(args: args),
        );

      case statistics:
        return MaterialPageRoute(
          builder: (_) => const StatisticsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const RoutesListScreen(),
        );
    }
  }
}

/// Arguments for arrival screen
class ArrivalScreenArgs {
  final String routeId;
  final String sessionId;
  final int actualDurationSeconds;

  const ArrivalScreenArgs({
    required this.routeId,
    required this.sessionId,
    required this.actualDurationSeconds,
  });
}
