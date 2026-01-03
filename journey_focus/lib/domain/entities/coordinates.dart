/// Represents a geographic coordinate (latitude/longitude)
class Coordinates {
  final double lat;
  final double lon;

  const Coordinates({
    required this.lat,
    required this.lon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coordinates &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lon == other.lon;

  @override
  int get hashCode => lat.hashCode ^ lon.hashCode;

  @override
  String toString() => 'Coordinates(lat: $lat, lon: $lon)';
}
