import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

import 'package:waypoint/data/database/app_database.dart';
import 'package:waypoint/data/models/trip_model.dart';
import 'package:waypoint/data/models/stop_model.dart';
import 'package:waypoint/data/repositories/trip_repository.dart';
import 'package:waypoint/data/repositories/stop_repository.dart';

void main() {
  late TripRepository tripRepository;
  late StopRepository stopRepository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final databasePath = await getDatabasesPath();
    await deleteDatabase(p.join(databasePath, 'waypoint.db'));

    tripRepository = TripRepository();
    stopRepository = StopRepository();
  });

  tearDown(() async {
    await AppDatabase.instance.closeDatabase();
  });

  final testTrip = TripModel(
    id: 'trip-1',
    name: 'Paris Holiday',
    destination: 'Paris',
    startDate: DateTime(2026, 12, 1),
    endDate: DateTime(2026, 12, 7),
    tripType: 'Leisure',
    budget: 1500,
  );

  final testStop = StopModel(
    id: 'stop-1',
    tripId: 'trip-1',
    name: 'Eiffel Tower',
    location: 'Paris',
    plannedDuration: 120,
  );

  test('creates trips and stops tables', () async {
    final db = await AppDatabase.instance.database;

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );

    final tableNames = tables.map((row) => row['name']).toList();

    expect(tableNames, contains('trips'));
    expect(tableNames, contains('stops'));
  });

  test('inserts and retrieves a trip', () async {
    await tripRepository.insertTrip(testTrip);

    final result = await tripRepository.getTripById('trip-1');

    expect(result, isNotNull);
    expect(result!.name, 'Paris Holiday');
    expect(result.destination, 'Paris');
  });

  test('updates a trip', () async {
    await tripRepository.insertTrip(testTrip);

    final updatedTrip = TripModel(
      id: 'trip-1',
      name: 'Updated Paris Holiday',
      destination: 'Paris',
      startDate: testTrip.startDate,
      endDate: testTrip.endDate,
      tripType: testTrip.tripType,
      budget: 2000,
    );

    await tripRepository.updateTrip(updatedTrip);

    final result = await tripRepository.getTripById('trip-1');

    expect(result!.name, 'Updated Paris Holiday');
    expect(result.budget, 2000);
  });

  test('deletes a trip', () async {
    await tripRepository.insertTrip(testTrip);
    await tripRepository.deleteTrip('trip-1');

    final result = await tripRepository.getTripById('trip-1');

    expect(result, isNull);
  });

  test('inserts and retrieves stops for a trip', () async {
    await tripRepository.insertTrip(testTrip);
    await stopRepository.insertStop(testStop);

    final stops = await stopRepository.getStopsForTrip('trip-1');

    expect(stops, hasLength(1));
    expect(stops.first.name, 'Eiffel Tower');
    expect(stops.first.plannedDuration, 120);
  });

  test('updates a stop', () async {
    await tripRepository.insertTrip(testTrip);
    await stopRepository.insertStop(testStop);

    final updatedStop = StopModel(
      id: 'stop-1',
      tripId: 'trip-1',
      name: 'Eiffel Tower',
      location: 'Paris',
      plannedDuration: 120,
      actualDuration: 150,
      status: 'completed',
    );

    await stopRepository.updateStop(updatedStop);

    final result = await stopRepository.getStopById('stop-1');

    expect(result!.actualDuration, 150);
    expect(result.status, 'completed');
  });

  test('deletes a stop', () async {
    await tripRepository.insertTrip(testTrip);
    await stopRepository.insertStop(testStop);

    await stopRepository.deleteStop('stop-1');

    final result = await stopRepository.getStopById('stop-1');

    expect(result, isNull);
  });

  test('deleting a trip also deletes its stops', () async {
    await tripRepository.insertTrip(testTrip);
    await stopRepository.insertStop(testStop);

    await tripRepository.deleteTrip('trip-1');

    final stops = await stopRepository.getStopsForTrip('trip-1');

    expect(stops, isEmpty);
  });
}
