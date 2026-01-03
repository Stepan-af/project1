/// Transport type for routes
enum TransportType {
  train,
  car,
  ferry;

  /// Human-readable name
  String get displayName {
    switch (this) {
      case TransportType.train:
        return 'Train';
      case TransportType.car:
        return 'Car';
      case TransportType.ferry:
        return 'Ferry';
    }
  }

  /// Parse from string (case-insensitive)
  static TransportType fromString(String value) {
    return TransportType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => TransportType.train,
    );
  }
}
