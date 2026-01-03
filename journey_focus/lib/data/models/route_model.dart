import '../../domain/entities/route_entity.dart';
import '../../domain/entities/coordinates.dart';
import '../../domain/enums/transport_type.dart';

/// Data transfer object for Route
/// Handles JSON serialization/deserialization
class RouteModel {
  final String id;
  final String title;
  final String transport;
  final int durationMinutes;
  final String description;
  final Map<String, double> start;
  final Map<String, double> end;
  final List<Map<String, double>> polyline;

  RouteModel({
    required this.id,
    required this.title,
    required this.transport,
    required this.durationMinutes,
    required this.description,
    required this.start,
    required this.end,
    required this.polyline,
  });

  /// Create from JSON map
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      transport: json['transport'] as String,
      durationMinutes: json['durationMinutes'] as int,
      description: json['description'] as String,
      start: Map<String, double>.from(json['start'] as Map),
      end: Map<String, double>.from(json['end'] as Map),
      polyline: (json['polyline'] as List)
          .map((p) => Map<String, double>.from(p as Map))
          .toList(),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'transport': transport,
      'durationMinutes': durationMinutes,
      'description': description,
      'start': start,
      'end': end,
      'polyline': polyline,
    };
  }

  /// Convert to domain entity
  RouteEntity toEntity() {
    return RouteEntity(
      id: id,
      title: title,
      transport: TransportType.fromString(transport),
      durationMinutes: durationMinutes,
      description: description,
      start: Coordinates(lat: start['lat']!, lon: start['lon']!),
      end: Coordinates(lat: end['lat']!, lon: end['lon']!),
      polyline: polyline
          .map((p) => Coordinates(lat: p['lat']!, lon: p['lon']!))
          .toList(),
    );
  }
}
