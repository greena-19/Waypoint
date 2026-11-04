import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waypoint/presentation/models/trip_stop.dart';
import 'package:waypoint/presentation/providers/stops_provider.dart';

void main() {
  TripStop createStop({
    String id = 'stop-1',
    String tripId = 'trip-1',
    String name = 'Museum',
  }) {
    return TripStop(
      id: id,
      tripId: tripId,
      name: name,
      location: 'Atlanta',
      plannedDurationMinutes: 60,
      notes: 'Visit exhibits',
    );
  }

  group('StopsNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial stop list is empty', () {
      expect(container.read(stopsProvider), isEmpty);
    });

    test('Add a stop', () {
      final stop = createStop();

      container.read(stopsProvider.notifier).addStop(stop);

      expect(container.read(stopsProvider).length, 1);
      expect(container.read(stopsProvider).first.name, 'Museum');
    });

    test('Update an existing stop', () {
      final stop = createStop();

      container.read(stopsProvider.notifier).addStop(stop);

      container
          .read(stopsProvider.notifier)
          .updateStop(stop.copyWith(name: 'Art Museum'));

      expect(container.read(stopsProvider).first.name, 'Art Museum');
    });

    test('Delete a stop', () {
      final stop = createStop();

      container.read(stopsProvider.notifier).addStop(stop);
      container.read(stopsProvider.notifier).deleteStop(stop.id);

      expect(container.read(stopsProvider), isEmpty);
    });

    test('Stops are associated with the correct trip', () {
      container
          .read(stopsProvider.notifier)
          .addStop(createStop(id: 'stop-1', tripId: 'trip-1'));

      container
          .read(stopsProvider.notifier)
          .addStop(createStop(id: 'stop-2', tripId: 'trip-2'));

      final tripOneStops = container
          .read(stopsProvider)
          .where((stop) => stop.tripId == 'trip-1')
          .toList();

      expect(tripOneStops.length, 1);
      expect(tripOneStops.first.id, 'stop-1');
    });

    test('Delete all stops for one trip', () {
      container
          .read(stopsProvider.notifier)
          .addStop(createStop(id: 'stop-1', tripId: 'trip-1'));

      container
          .read(stopsProvider.notifier)
          .addStop(createStop(id: 'stop-2', tripId: 'trip-2'));

      container.read(stopsProvider.notifier).deleteStopsForTrip('trip-1');

      final remainingStops = container.read(stopsProvider);

      expect(remainingStops.length, 1);
      expect(remainingStops.first.tripId, 'trip-2');
    });

    test('copyWith preserves unchanged stop fields', () {
      final stop = createStop();

      final updatedStop = stop.copyWith(plannedDurationMinutes: 90);

      expect(updatedStop.id, stop.id);
      expect(updatedStop.tripId, stop.tripId);
      expect(updatedStop.name, stop.name);
      expect(updatedStop.location, stop.location);
      expect(updatedStop.notes, stop.notes);
      expect(updatedStop.plannedDurationMinutes, 90);
    });
  });
}
