/// App-wide constants
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'Journey Focus';

  /// Default map zoom level for route details
  static const double defaultMapZoom = 5.0;

  /// Map zoom level for session view
  static const double sessionMapZoom = 6.0;

  /// Timer update interval in milliseconds
  static const int timerUpdateIntervalMs = 1000;

  /// Animation duration for marker movement (smooth updates)
  static const int markerAnimationDurationMs = 200;

  /// Minimum session duration in minutes
  static const int minSessionDurationMinutes = 1;

  /// OpenStreetMap tile URL (free, open-source)
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// User agent for tile requests (required by OSM)
  static const String tileUserAgent = 'JourneyFocus/1.0';

  /// Maximum days to check for streak calculation (prevents infinite loops)
  static const int maxStreakDays = 365;

  /// Days in a week (for statistics)
  static const int daysInWeek = 7;
}
