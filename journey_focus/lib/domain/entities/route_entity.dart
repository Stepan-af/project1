import 'coordinates.dart';
import '../enums/transport_type.dart';

/// Domain entity representing a journey route
class RouteEntity {
  final String id;
  final String title;
  final TransportType transport;
  final int durationMinutes;
  final String description;
  final Coordinates start;
  final Coordinates end;
  final List<Coordinates> polyline;

  const RouteEntity({
    required this.id,
    required this.title,
    required this.transport,
    required this.durationMinutes,
    required this.description,
    required this.start,
    required this.end,
    required this.polyline,
  });

  /// Duration as Duration object
  Duration get duration => Duration(minutes: durationMinutes);

  /// Duration in seconds (for session calculations)
  int get durationSeconds => durationMinutes * 60;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RouteEntity(id: $id, title: $title)';
}
