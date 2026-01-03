import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/route_entity.dart';
import '../../../domain/entities/coordinates.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/polyline_utils.dart';

/// Widget that displays a route on a map
/// Shows polyline, start marker, and end marker
class RouteMap extends StatefulWidget {
  final RouteEntity route;

  /// Optional current position (for session view)
  final Coordinates? currentPosition;

  /// Whether to show the current position marker
  final bool showCurrentPosition;

  /// Whether to fit the map to show the entire route
  final bool fitBounds;

  /// Map controller for external control
  final MapController? mapController;

  const RouteMap({
    super.key,
    required this.route,
    this.currentPosition,
    this.showCurrentPosition = false,
    this.fitBounds = true,
    this.mapController,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = widget.mapController ?? MapController();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _calculateCenter(),
        initialZoom: AppConstants.defaultMapZoom,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: () {
          if (widget.fitBounds) {
            _fitBounds();
          }
        },
      ),
      children: [
        // OpenStreetMap tile layer (free, open-source)
        TileLayer(
          urlTemplate: AppConstants.osmTileUrl,
          userAgentPackageName: AppConstants.tileUserAgent,
          maxZoom: 19,
        ),

        // Route polyline (background - thicker, lighter)
        PolylineLayer(
          polylines: [
            Polyline(
              points: _convertPolyline(widget.route.polyline),
              color: AppColors.routePolylineBackground,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          ],
        ),

        // Route polyline (foreground - thinner, darker)
        PolylineLayer(
          polylines: [
            Polyline(
              points: _convertPolyline(widget.route.polyline),
              color: AppColors.routePolyline,
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          ],
        ),

        // Markers layer
        MarkerLayer(
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  /// Calculate map center from route polyline
  LatLng _calculateCenter() {
    final center = PolylineUtils.calculateCenter(widget.route.polyline);
    return LatLng(center.lat, center.lon);
  }

  /// Convert domain Coordinates to LatLng for flutter_map
  List<LatLng> _convertPolyline(List<Coordinates> polyline) {
    return polyline.map((c) => LatLng(c.lat, c.lon)).toList();
  }

  /// Fit map bounds to show entire route with padding
  void _fitBounds() {
    final bbox = PolylineUtils.calculateBoundingBox(widget.route.polyline);

    final bounds = LatLngBounds(
      LatLng(bbox[0], bbox[1]), // Southwest (minLat, minLon)
      LatLng(bbox[2], bbox[3]), // Northeast (maxLat, maxLon)
    );

    // Fit bounds with padding
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  /// Build markers for start, end, and optionally current position
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Start marker (green)
    markers.add(
      Marker(
        point: LatLng(widget.route.start.lat, widget.route.start.lon),
        width: 32,
        height: 32,
        child: const _MapMarker(
          color: AppColors.markerStart,
          icon: Icons.trip_origin,
        ),
      ),
    );

    // End marker (red)
    markers.add(
      Marker(
        point: LatLng(widget.route.end.lat, widget.route.end.lon),
        width: 32,
        height: 32,
        child: const _MapMarker(
          color: AppColors.markerEnd,
          icon: Icons.location_on,
        ),
      ),
    );

    // Current position marker (if provided and enabled)
    if (widget.showCurrentPosition && widget.currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(
            widget.currentPosition!.lat,
            widget.currentPosition!.lon,
          ),
          width: 40,
          height: 40,
          child: const _CurrentPositionMarker(),
        ),
      );
    }

    return markers;
  }
}

/// Simple map marker widget
class _MapMarker extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MapMarker({
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}

/// Animated current position marker
class _CurrentPositionMarker extends StatelessWidget {
  const _CurrentPositionMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulse effect
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.markerCurrent.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        // Inner circle
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.markerCurrent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.markerCurrent.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
