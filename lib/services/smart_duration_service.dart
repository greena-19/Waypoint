import '../data/models/stop_model.dart';

class SmartDurationService {
  /// Returns the difference between actual and planned duration.
  /// Positive means extra time was spent.
  /// Negative means less time was spent.
  int calculateDurationDifference(StopModel stop) {
    if (stop.actualDuration == null) {
      throw StateError('Actual duration is not available yet.');
    }

    return stop.actualDuration! - stop.plannedDuration;
  }

  /// Returns a suggested duration for a stop.
  ///
  /// If actual duration is available, it uses that value.
  /// Otherwise, it uses the planned duration.
  int suggestDuration(StopModel stop) {
    final actualDuration = stop.actualDuration;

    if (actualDuration != null && actualDuration > 0) {
      return actualDuration;
    }

    return stop.plannedDuration;
  }

  /// Provides a readable comparison between planned and actual time.
  String getDurationFeedback(StopModel stop) {
    if (stop.actualDuration == null) {
      return 'No actual duration recorded yet.';
    }

    final difference = stop.actualDuration! - stop.plannedDuration;

    if (difference > 0) {
      return 'You spent $difference minutes longer than planned.';
    }

    if (difference < 0) {
      return 'You spent ${difference.abs()} minutes less than planned.';
    }

    return 'You spent exactly the planned amount of time.';
  }

  /// Converts minutes into hours and minutes for display.
  String formatDuration(int minutes) {
    if (minutes < 0) {
      throw ArgumentError('Duration cannot be negative.');
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '$remainingMinutes minutes';
    }

    if (remainingMinutes == 0) {
      return '$hours hours';
    }

    return '$hours hours $remainingMinutes minutes';
  }
}
