import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/route_model.dart';

/// Local data source for routes
/// Loads predefined routes from bundled JSON asset
class RoutesLocalDatasource {
  static const String _routesAssetPath = 'assets/data/routes.json';

  List<RouteModel>? _cachedRoutes;

  /// Load all routes from bundled JSON asset
  Future<List<RouteModel>> getAllRoutes() async {
    // Return cached routes if available
    if (_cachedRoutes != null) {
      return _cachedRoutes!;
    }

    // Load JSON from assets
    final jsonString = await rootBundle.loadString(_routesAssetPath);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final routesList = jsonData['routes'] as List;

    // Parse and cache routes
    _cachedRoutes = routesList
        .map((json) => RouteModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return _cachedRoutes!;
  }

  /// Get a specific route by ID
  Future<RouteModel?> getRouteById(String id) async {
    final routes = await getAllRoutes();
    try {
      return routes.firstWhere((route) => route.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear cache (for testing purposes)
  void clearCache() {
    _cachedRoutes = null;
  }
}
