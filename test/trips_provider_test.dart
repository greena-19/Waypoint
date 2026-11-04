
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

import 'package:waypoint/data/database/app_database.dart';
import 'package:waypoint/presentation/providers/trips_provider.dart';

void main() {
  late ProviderContainer container;

  TripSummary createTestTrip({
    String id = 'trip-1',
    String name = 'Colorado Trip',
    String destination = 'Boulder',
    String tripType = 'weekend',
    double budget = 300,
  }) {
    return TripSummary(
      id: id,
      name: name,
      destination: destination,
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 11, 3),
      tripType: tripType,
      budget: budget,
    );
  }

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await AppDatabase.instance.closeDatabase();

    final databasePath = await getDatabasesPath();
    await deleteDatabase(p.join(databasePath, 'waypoint.db'));

    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await AppDatabase.instance.closeDatabase();
  });

  test('Trips list is initially empty', () {
    final trips = container.read(tripsProvider);

    expect(trips, isEmpty);
  });

  test('Adding a trip updates the list', () async {
    final notifier = container.read(tripsProvider.notifier);

    await notifier.addTrip(createTestTrip());

    final trips = container.read(tripsProvider);

    expect(trips.length, 1);
    expect(trips.first.id, 'trip-1');
    expect(trips.first.name, 'Colorado Trip');
    expect(trips.first.destination, 'Boulder');
    expect(trips.first.tripType, 'weekend');
    expect(trips.first.budget, 300);
    expect(trips.first.startDate, DateTime(2026, 11, 1));
    expect(trips.first.endDate, DateTime(2026, 11, 3));
  });

  test('Editing a trip updates its information', () async {
    final notifier = container.read(tripsProvider.notifier);

    await notifier.addTrip(createTestTrip());

    final originalTrip = container.read(tripsProvider).first;

    await notifier.updateTrip(
      0,
      originalTrip.copyWith(
        name: 'Colorado Adventure',
        destination: 'Denver',
      ),
    );

    final trips = container.read(tripsProvider);

    expect(trips.length, 1);
    expect(trips.first.name, 'Colorado Adventure');
    expect(trips.first.destination, 'Denver');

    expect(trips.first.id, 'trip-1');
    expect(trips.first.tripType, 'weekend');
    expect(trips.first.budget, 300);
    expect(trips.first.startDate, DateTime(2026, 11, 1));
    expect(trips.first.endDate, DateTime(2026, 11, 3));
  });

  test('Deleting a trip removes it from the list', () async {
    final notifier = container.read(tripsProvider.notifier);

    await notifier.addTrip(createTestTrip());

    await notifier.deleteTrip(0);

    expect(container.read(tripsProvider), isEmpty);
  });

  test('Invalid update index does not modify trips', () async {
    final notifier = container.read(tripsProvider.notifier);

    await notifier.addTrip(createTestTrip());

    await notifier.updateTrip(
      10,
      createTestTrip(
        id: 'trip-2',
        name: 'Invalid Trip',
        destination: 'Unknown',
      ),
    );

    final trips = container.read(tripsProvider);

    expect(trips.length, 1);
    expect(trips.first.name, 'Colorado Trip');
  });

  test('Invalid delete index does not remove trips', () async {
    final notifier = container.read(tripsProvider.notifier);

    await notifier.addTrip(createTestTrip());

    await notifier.deleteTrip(-1);

    expect(container.read(tripsProvider).length, 1);
  });

  test('Multiple trips can be added', () async {
    final notifier = container.read(tripsProvider.notifier);

    await notifier.addTrip(createTestTrip());

    await notifier.addTrip(
      createTestTrip(
        id: 'trip-2',
        name: 'New York Trip',
        destination: 'New York',
        tripType: 'multi_day',
        budget: 800,
      ),
    );

    final trips = container.read(tripsProvider);

    expect(trips.length, 2);
    expect(trips[0].name, 'Colorado Trip');
    expect(trips[1].name, 'New York Trip');
    expect(trips[1].budget, 800);
  });

  test('copyWith preserves unchanged trip details', () {
    final original = createTestTrip();

    final updated = original.copyWith(
      name: 'Updated Colorado Trip',
    );

    expect(updated.name, 'Updated Colorado Trip');
    expect(updated.id, original.id);
    expect(updated.destination, original.destination);
    expect(updated.startDate, original.startDate);
    expect(updated.endDate, original.endDate);
    expect(updated.tripType, original.tripType);
    expect(updated.budget, original.budget);
  });

  test('Saved trips can be loaded from SQLite', () async {
    final notifier = container.read(tripsProvider.notifier);

    await notifier.addTrip(createTestTrip());

    // Create a new provider to simulate loading saved data.
    final newContainer = ProviderContainer();

    try {
      await newContainer.read(tripsProvider.notifier).loadTrips();

      final trips = newContainer.read(tripsProvider);

      expect(trips.length, 1);
      expect(trips.first.name, 'Colorado Trip');
      expect(trips.first.destination, 'Boulder');
    } finally {
      newContainer.dispose();
    }
  });
}
