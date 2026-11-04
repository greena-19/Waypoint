
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waypoint/data/database/app_database.dart';
import 'package:waypoint/data/models/trip_model.dart';
import 'package:waypoint/data/models/stop_model.dart';
import 'package:waypoint/data/repositories/trip_repository.dart';
import 'package:waypoint/data/repositories/stop_repository.dart';
import 'package:waypoint/services/json_backup_service.dart';

void main() {
  late TripRepository tripRepository;
  late StopRepository stopRepository;
  late JsonBackupService backupService;

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
    actualDuration: 135,
    checkInTime: DateTime(2026, 12, 1, 10),
    checkOutTime: DateTime(2026, 12, 1, 12, 15),
    status: 'completed',
  );

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await AppDatabase.instance.closeDatabase();

    final databasePath = await getDatabasesPath();
    await deleteDatabase('$databasePath/waypoint.db');

    tripRepository = TripRepository();
    stopRepository = StopRepository();

    backupService = JsonBackupService(
      tripRepository: tripRepository,
      stopRepository: stopRepository,
    );
  });

  tearDown(() async {
    await AppDatabase.instance.closeDatabase();
  });

  test('exports a valid Waypoint JSON backup', () async {
    await tripRepository.insertTrip(testTrip);
    await stopRepository.insertStop(testStop);

    final result = await backupService.exportBackup();
    final decoded = jsonDecode(result) as Map<String, dynamic>;

    expect(decoded['app'], 'Waypoint');
    expect(decoded['version'], 1);
    expect(decoded['exportedAt'], isNotNull);
    expect(decoded['trips'], hasLength(1));

    final exportedTrip = decoded['trips'][0];
    expect(exportedTrip['trip']['name'], 'Paris Holiday');
    expect(exportedTrip['stops'], hasLength(1));
    expect(exportedTrip['stops'][0]['name'], 'Eiffel Tower');
  });

  test('imports trips and stops from a valid backup', () async {
    final backup = jsonEncode({
      'app': 'Waypoint',
      'version': 1,
      'trips': [
        {
          'trip': testTrip.toMap(),
          'stops': [testStop.toMap()],
        },
      ],
    });

    final importedCount = await backupService.importBackup(backup);

    expect(importedCount, 1);

    final importedTrip = await tripRepository.getTripById('trip-1');
    final importedStop = await stopRepository.getStopById('stop-1');

    expect(importedTrip, isNotNull);
    expect(importedTrip!.name, 'Paris Holiday');
    expect(importedStop, isNotNull);
    expect(importedStop!.name, 'Eiffel Tower');
    expect(importedStop.actualDuration, 135);
    expect(importedStop.status, 'completed');
  });

  test('updates an existing trip and stop during import', () async {
    await tripRepository.insertTrip(testTrip);
    await stopRepository.insertStop(testStop);

    final updatedTrip = TripModel(
      id: 'trip-1',
      name: 'Updated Paris Holiday',
      destination: 'Paris',
      startDate: testTrip.startDate,
      endDate: testTrip.endDate,
      tripType: testTrip.tripType,
      budget: 2500,
    );

    final updatedStop = StopModel(
      id: 'stop-1',
      tripId: 'trip-1',
      name: 'Updated Eiffel Tower Visit',
      location: 'Paris',
      plannedDuration: 120,
      actualDuration: 150,
      status: 'completed',
    );

    final backup = jsonEncode({
      'app': 'Waypoint',
      'version': 1,
      'trips': [
        {
          'trip': updatedTrip.toMap(),
          'stops': [updatedStop.toMap()],
        },
      ],
    });

    await backupService.importBackup(backup);

    final resultTrip = await tripRepository.getTripById('trip-1');
    final resultStop = await stopRepository.getStopById('stop-1');

    expect(resultTrip!.name, 'Updated Paris Holiday');
    expect(resultTrip.budget, 2500);
    expect(resultStop!.name, 'Updated Eiffel Tower Visit');
    expect(resultStop.actualDuration, 150);
  });

  test('rejects invalid JSON', () async {
    expect(
      () => backupService.importBackup('{invalid json'),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a backup from another app', () async {
    final backup = jsonEncode({
      'app': 'OtherApp',
      'version': 1,
      'trips': [],
    });

    expect(
      () => backupService.importBackup(backup),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects an unsupported backup version', () async {
    final backup = jsonEncode({
      'app': 'Waypoint',
      'version': 99,
      'trips': [],
    });

    expect(
      () => backupService.importBackup(backup),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects a stop belonging to a different trip', () async {
    final mismatchedStop = StopModel(
      id: 'stop-2',
      tripId: 'another-trip',
      name: 'Invalid Stop',
      location: 'Paris',
      plannedDuration: 60,
    );

    final backup = jsonEncode({
      'app': 'Waypoint',
      'version': 1,
      'trips': [
        {
          'trip': testTrip.toMap(),
          'stops': [mismatchedStop.toMap()],
        },
      ],
    });

    expect(
      () => backupService.importBackup(backup),
      throwsA(isA<FormatException>()),
    );

    final trip = await tripRepository.getTripById('trip-1');
    expect(trip, isNull);
  });
}
