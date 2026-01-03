import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/route_entity.dart';
import '../../../domain/entities/coordinates.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/polyline_utils.dart';

/// Session map widget with animated marker movement
/// The marker position is controlled by progress (0.0 to 1.0)
class SessionMap extends StatefulWidget {
  final RouteEntity route;

  /// Progress along the route (0.0 = start, 1.0 = end)
  final double progress;

  const SessionMap({
    super.key,
    required this.route,
    required this.progress,
  });

  @override
  State<SessionMap> createState() => _SessionMapState();
}

class _SessionMapState extends State<SessionMap>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;

  /// Current animated marker position
  Coordinates? _currentPosition;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _updateMarkerPosition();
  }

  @override
  void didUpdateWidget(SessionMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update marker position when progress changes
    if (oldWidget.progress != widget.progress) {
      _updateMarkerPosition();
    }
  }

  void _updateMarkerPosition() {
    _currentPosition = PolylineUtils.getPositionAtProgress(
      widget.route.polyline,
      widget.progress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _calculateCenter(),
        initialZoom: AppConstants.sessionMapZoom,
        interactionOptions: const InteractionOptions(
          // Disable rotation for cleaner experience
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        onMapReady: _fitBounds,
      ),
      children: [
        // OpenStreetMap tile layer
        TileLayer(
          urlTemplate: AppConstants.osmTileUrl,
          userAgentPackageName: AppConstants.tileUserAgent,
          maxZoom: 19,
        ),

        // Route polyline (background)
        PolylineLayer(
          polylines: [
            Polyline(
              points: _convertPolyline(widget.route.polyline),
              color: AppColors.routePolylineBackground,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          ],
        ),

        // Traveled portion of route (highlighted)
        if (_currentPosition != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _getTraveledPolyline(),
                color: AppColors.accent,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            ],
          ),

        // Remaining portion of route
        PolylineLayer(
          polylines: [
            Polyline(
              points: _convertPolyline(widget.route.polyline),
              color: AppColors.routePolyline.withValues(alpha: 0.5),
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          ],
        ),

        // Markers
        MarkerLayer(
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  LatLng _calculateCenter() {
    final center = PolylineUtils.calculateCenter(widget.route.polyline);
    return LatLng(center.lat, center.lon);
  }

  List<LatLng> _convertPolyline(List<Coordinates> polyline) {
    return polyline.map((c) => LatLng(c.lat, c.lon)).toList();
  }

  /// Get the portion of the polyline that has been traveled
  List<LatLng> _getTraveledPolyline() {
    if (_currentPosition == null) return [];

    final cumulativeDistances =
        PolylineUtils.computeCumulativeDistances(widget.route.polyline);
    final totalDistance = cumulativeDistances.last;
    final targetDistance = totalDistance * widget.progress;

    final traveledPoints = <LatLng>[];

    for (int i = 0; i < widget.route.polyline.length; i++) {
      if (cumulativeDistances[i] <= targetDistance) {
        traveledPoints.add(LatLng(
          widget.route.polyline[i].lat,
          widget.route.polyline[i].lon,
        ));
      } else {
        break;
      }
    }

    // Add current position as last point
    traveledPoints.add(LatLng(
      _currentPosition!.lat,
      _currentPosition!.lon,
    ));

    return traveledPoints;
  }

  void _fitBounds() {
    final bbox = PolylineUtils.calculateBoundingBox(widget.route.polyline);

    final bounds = LatLngBounds(
      LatLng(bbox[0], bbox[1]),
      LatLng(bbox[2], bbox[3]),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Start marker (subtle when journey started)
    markers.add(
      Marker(
        point: LatLng(widget.route.start.lat, widget.route.start.lon),
        width: 24,
        height: 24,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.markerStart.withValues(alpha: 0.6),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.trip_origin,
            color: Colors.white,
            size: 12,
          ),
        ),
      ),
    );

    // End marker (destination)
    markers.add(
      Marker(
        point: LatLng(widget.route.end.lat, widget.route.end.lon),
        width: 28,
        height: 28,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.markerEnd,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.markerEnd.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.flag,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    );

    // Current position marker (animated)
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(_currentPosition!.lat, _currentPosition!.lon),
          width: 44,
          height: 44,
          child: const _AnimatedCurrentMarker(),
        ),
      );
    }

    return markers;
  }
}

/// Animated marker for current position during session
class _AnimatedCurrentMarker extends StatefulWidget {
  const _AnimatedCurrentMarker();

  @override
  State<_AnimatedCurrentMarker> createState() => _AnimatedCurrentMarkerState();
}

class _AnimatedCurrentMarkerState extends State<_AnimatedCurrentMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Inner marker
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}
