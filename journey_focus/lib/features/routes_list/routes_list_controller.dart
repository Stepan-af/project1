import 'package:flutter/material.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/enums/transport_type.dart';
import '../../data/repositories/routes_repository.dart';

/// Controller for routes list screen
class RoutesListController extends ChangeNotifier {
  final RoutesRepository _routesRepository;

  List<RouteEntity> _allRoutes = [];
  List<RouteEntity> _filteredRoutes = [];
  TransportType? _selectedTransport;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _error;

  RoutesListController({RoutesRepository? routesRepository})
      : _routesRepository = routesRepository ?? RoutesRepository();

  // ============================================
  // GETTERS
  // ============================================

  List<RouteEntity> get routes => _filteredRoutes;
  TransportType? get selectedTransport => _selectedTransport;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> loadRoutes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allRoutes = await _routesRepository.getAllRoutes();
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load routes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // FILTERING
  // ============================================

  void setTransportFilter(TransportType? transport) {
    _selectedTransport = transport;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredRoutes = _allRoutes.where((route) {
      // Transport filter
      if (_selectedTransport != null &&
          route.transport != _selectedTransport) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!route.title.toLowerCase().contains(query) &&
            !route.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
