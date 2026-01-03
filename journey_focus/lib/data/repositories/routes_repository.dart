import '../datasources/routes_local_datasource.dart';
import '../../domain/entities/route_entity.dart';
import '../../domain/enums/transport_type.dart';

/// Repository for routes
/// Provides business-level access to route data
class RoutesRepository {
  final RoutesLocalDatasource _datasource;

  RoutesRepository({RoutesLocalDatasource? datasource})
      : _datasource = datasource ?? RoutesLocalDatasource();

  /// Get all routes as domain entities
  Future<List<RouteEntity>> getAllRoutes() async {
    final models = await _datasource.getAllRoutes();
    return models.map((m) => m.toEntity()).toList();
  }

  /// Get routes filtered by transport type
  Future<List<RouteEntity>> getRoutesByTransport(
    TransportType transport,
  ) async {
    final allRoutes = await getAllRoutes();
    return allRoutes.where((r) => r.transport == transport).toList();
  }

  /// Search routes by title (case-insensitive)
  Future<List<RouteEntity>> searchRoutes(String query) async {
    final allRoutes = await getAllRoutes();
    final lowerQuery = query.toLowerCase();
    return allRoutes
        .where((r) => r.title.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get a specific route by ID
  Future<RouteEntity?> getRouteById(String id) async {
    final model = await _datasource.getRouteById(id);
    return model?.toEntity();
  }

  /// Filter routes by transport type and search query
  Future<List<RouteEntity>> filterRoutes({
    TransportType? transport,
    String? searchQuery,
  }) async {
    var routes = await getAllRoutes();

    // Filter by transport type if specified
    if (transport != null) {
      routes = routes.where((r) => r.transport == transport).toList();
    }

    // Filter by search query if specified
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      routes = routes
          .where((r) => r.title.toLowerCase().contains(lowerQuery))
          .toList();
    }

    return routes;
  }
}
