import 'package:flutter/material.dart';
import '../../domain/entities/route_entity.dart';
import '../../data/repositories/routes_repository.dart';

/// Controller for route details screen
class RouteDetailsController extends ChangeNotifier {
  final RoutesRepository _routesRepository;
  final String routeId;

  RouteEntity? _route;
  bool _isLoading = true;
  String? _error;

  RouteDetailsController({
    required this.routeId,
    RoutesRepository? routesRepository,
  }) : _routesRepository = routesRepository ?? RoutesRepository();

  // ============================================
  // GETTERS
  // ============================================

  RouteEntity? get route => _route;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> loadRoute() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _route = await _routesRepository.getRouteById(routeId);

      if (_route == null) {
        _error = 'Route not found';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load route: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
