import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waypoint/presentation/providers/trips_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('Trips list is initially empty', () {
    final trips = container.read(tripsProvider);

    expect(trips, isEmpty);
  });

  test('Adding a trip updates the list', () {
    container
        .read(tripsProvider.notifier)
        .addTrip(
          const TripSummary(name: 'Colorado Trip', destination: 'Boulder'),
        );

    final trips = container.read(tripsProvider);

    expect(trips.length, 1);
    expect(trips.first.name, 'Colorado Trip');
    expect(trips.first.destination, 'Boulder');
  });

  test('Editing a trip updates its information', () {
    final notifier = container.read(tripsProvider.notifier);

    notifier.addTrip(
      const TripSummary(name: 'Colorado Trip', destination: 'Boulder'),
    );

    notifier.updateTrip(
      0,
      const TripSummary(name: 'Colorado Adventure', destination: 'Denver'),
    );

    final trips = container.read(tripsProvider);

    expect(trips.length, 1);
    expect(trips.first.name, 'Colorado Adventure');
    expect(trips.first.destination, 'Denver');
  });

  test('Deleting a trip removes it from the list', () {
    final notifier = container.read(tripsProvider.notifier);

    notifier.addTrip(
      const TripSummary(name: 'Colorado Trip', destination: 'Boulder'),
    );

    notifier.deleteTrip(0);

    expect(container.read(tripsProvider), isEmpty);
  });

  test('Invalid update index does not modify trips', () {
    final notifier = container.read(tripsProvider.notifier);

    notifier.addTrip(
      const TripSummary(name: 'Colorado Trip', destination: 'Boulder'),
    );

    notifier.updateTrip(
      10,
      const TripSummary(name: 'Invalid Trip', destination: 'Unknown'),
    );

    final trips = container.read(tripsProvider);

    expect(trips.length, 1);
    expect(trips.first.name, 'Colorado Trip');
  });

  test('Invalid delete index does not remove trips', () {
    final notifier = container.read(tripsProvider.notifier);

    notifier.addTrip(
      const TripSummary(name: 'Colorado Trip', destination: 'Boulder'),
    );

    notifier.deleteTrip(-1);

    expect(container.read(tripsProvider).length, 1);
  });
}
