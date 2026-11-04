import 'package:flutter_test/flutter_test.dart';

import 'package:waypoint/data/models/stop_model.dart';
import 'package:waypoint/services/smart_duration_service.dart';

void main() {
  late SmartDurationService durationService;

  setUp(() {
    durationService = SmartDurationService();
  });

  const plannedStop = StopModel(
    id: 'stop-1',
    tripId: 'trip-1',
    name: 'Eiffel Tower',
    location: 'Paris',
    plannedDuration: 120,
  );

  const completedStop = StopModel(
    id: 'stop-2',
    tripId: 'trip-1',
    name: 'Louvre Museum',
    location: 'Paris',
    plannedDuration: 120,
    actualDuration: 150,
  );

  test('suggests planned duration when actual duration is unavailable', () {
    final result = durationService.suggestDuration(plannedStop);

    expect(result, 120);
  });

  test('suggests actual duration when available', () {
    final result = durationService.suggestDuration(completedStop);

    expect(result, 150);
  });

  test('calculates positive duration difference', () {
    final result = durationService.calculateDurationDifference(completedStop);

    expect(result, 30);
  });

  test('calculates negative duration difference', () {
    const stop = StopModel(
      id: 'stop-3',
      tripId: 'trip-1',
      name: 'Arc de Triomphe',
      location: 'Paris',
      plannedDuration: 120,
      actualDuration: 90,
    );

    final result = durationService.calculateDurationDifference(stop);

    expect(result, -30);
  });

  test('rejects duration difference when actual duration is unavailable', () {
    expect(
      () => durationService.calculateDurationDifference(plannedStop),
      throwsA(isA<StateError>()),
    );
  });

  test('provides feedback when more time is spent than planned', () {
    final result = durationService.getDurationFeedback(completedStop);

    expect(result, 'You spent 30 minutes longer than planned.');
  });

  test('provides feedback when less time is spent than planned', () {
    const stop = StopModel(
      id: 'stop-4',
      tripId: 'trip-1',
      name: 'Arc de Triomphe',
      location: 'Paris',
      plannedDuration: 120,
      actualDuration: 90,
    );

    final result = durationService.getDurationFeedback(stop);

    expect(result, 'You spent 30 minutes less than planned.');
  });

  test('formats minutes into hours and minutes', () {
    expect(durationService.formatDuration(90), '1 hours 30 minutes');
  });

  test('formats exact hours', () {
    expect(durationService.formatDuration(120), '2 hours');
  });

  test('formats minutes without hours', () {
    expect(durationService.formatDuration(45), '45 minutes');
  });

  test('rejects negative duration formatting', () {
    expect(
      () => durationService.formatDuration(-10),
      throwsA(isA<ArgumentError>()),
    );
  });
}
