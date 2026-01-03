import 'dart:math' as math;
import '../../domain/entities/coordinates.dart';

/// Utility class for polyline calculations
/// Handles marker position interpolation along the route
class PolylineUtils {
  PolylineUtils._();

  /// Calculate the total distance of a polyline in meters
  /// Uses Haversine formula for accurate distance calculation
  static double calculateTotalDistance(List<Coordinates> polyline) {
    if (polyline.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < polyline.length - 1; i++) {
      totalDistance += _haversineDistance(polyline[i], polyline[i + 1]);
    }
    return totalDistance;
  }

  /// Precompute cumulative distances for each point in the polyline
  /// Returns a list where each element is the cumulative distance from start
  /// to that point
  static List<double> computeCumulativeDistances(List<Coordinates> polyline) {
    if (polyline.isEmpty) return [];

    final List<double> cumulativeDistances = [0.0];

    for (int i = 1; i < polyline.length; i++) {
      final segmentDistance =
          _haversineDistance(polyline[i - 1], polyline[i]);
      cumulativeDistances.add(cumulativeDistances.last + segmentDistance);
    }

    return cumulativeDistances;
  }

  /// Get the position along the polyline for a given progress (0.0 to 1.0)
  ///
  /// This is the core function for marker animation:
  /// - progress = 0.0 → start position
  /// - progress = 1.0 → end position
  /// - progress = 0.5 → halfway point (by distance, not points)
  static Coordinates getPositionAtProgress(
    List<Coordinates> polyline,
    double progress,
  ) {
    if (polyline.isEmpty) {
      throw ArgumentError('Polyline cannot be empty');
    }

    if (polyline.length == 1) {
      return polyline.first;
    }

    // Clamp progress to valid range
    final clampedProgress = progress.clamp(0.0, 1.0);

    // Handle edge cases
    if (clampedProgress <= 0.0) return polyline.first;
    if (clampedProgress >= 1.0) return polyline.last;

    // Compute cumulative distances
    final cumulativeDistances = computeCumulativeDistances(polyline);
    final totalDistance = cumulativeDistances.last;

    if (totalDistance == 0) return polyline.first;

    // Calculate target distance
    final targetDistance = totalDistance * clampedProgress;

    // Find the segment containing the target distance
    int segmentIndex = 0;
    for (int i = 1; i < cumulativeDistances.length; i++) {
      if (cumulativeDistances[i] >= targetDistance) {
        segmentIndex = i - 1;
        break;
      }
    }

    // Get segment start and end points
    final segmentStart = polyline[segmentIndex];
    final segmentEnd = polyline[segmentIndex + 1];

    // Calculate how far along the segment we are
    final segmentStartDistance = cumulativeDistances[segmentIndex];
    final segmentEndDistance = cumulativeDistances[segmentIndex + 1];
    final segmentLength = segmentEndDistance - segmentStartDistance;

    if (segmentLength == 0) return segmentStart;

    final segmentProgress =
        (targetDistance - segmentStartDistance) / segmentLength;

    // Linear interpolation between segment points
    return _interpolate(segmentStart, segmentEnd, segmentProgress);
  }

  /// Haversine formula to calculate distance between two coordinates
  /// Returns distance in meters
  static double _haversineDistance(Coordinates c1, Coordinates c2) {
    const double earthRadius = 6371000; // meters

    final lat1Rad = _toRadians(c1.lat);
    final lat2Rad = _toRadians(c2.lat);
    final deltaLat = _toRadians(c2.lat - c1.lat);
    final deltaLon = _toRadians(c2.lon - c1.lon);

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Linear interpolation between two coordinates
  static Coordinates _interpolate(
    Coordinates start,
    Coordinates end,
    double t,
  ) {
    return Coordinates(
      lat: start.lat + (end.lat - start.lat) * t,
      lon: start.lon + (end.lon - start.lon) * t,
    );
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Calculate the bounding box for a polyline
  /// Returns [minLat, minLon, maxLat, maxLon]
  static List<double> calculateBoundingBox(List<Coordinates> polyline) {
    if (polyline.isEmpty) {
      return [0, 0, 0, 0];
    }

    double minLat = polyline.first.lat;
    double maxLat = polyline.first.lat;
    double minLon = polyline.first.lon;
    double maxLon = polyline.first.lon;

    for (final coord in polyline) {
      minLat = math.min(minLat, coord.lat);
      maxLat = math.max(maxLat, coord.lat);
      minLon = math.min(minLon, coord.lon);
      maxLon = math.max(maxLon, coord.lon);
    }

    return [minLat, minLon, maxLat, maxLon];
  }

  /// Calculate center point of a polyline's bounding box
  static Coordinates calculateCenter(List<Coordinates> polyline) {
    final bbox = calculateBoundingBox(polyline);
    return Coordinates(
      lat: (bbox[0] + bbox[2]) / 2,
      lon: (bbox[1] + bbox[3]) / 2,
    );
  }
}
