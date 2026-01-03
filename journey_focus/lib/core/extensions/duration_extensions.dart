/// Extension methods for Duration
extension DurationExtensions on Duration {
  /// Format duration as mm:ss
  String toMinutesSeconds() {
    final minutes = inMinutes.remainder(60).abs();
    final seconds = inSeconds.remainder(60).abs();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration as hh:mm:ss (for longer durations)
  String toHoursMinutesSeconds() {
    final hours = inHours.abs();
    final minutes = inMinutes.remainder(60).abs();
    final seconds = inSeconds.remainder(60).abs();

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format duration as human-readable string (e.g., "45 min", "1h 30min")
  String toReadableString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '$minutes min';
    }
  }
}
