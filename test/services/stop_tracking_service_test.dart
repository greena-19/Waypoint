import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

import 'package:waypoint/data/database/app_database.dart';
import 'package:waypoint/data/models/trip_model.dart';
import 'package:waypoint/data/models/stop_model.dart';
import 'package:waypoint/data/repositories/trip_repository.dart';
import 'package:waypoint/data/repositories/stop_repository.dart';
import 'package:waypoint/services/stop_tracking_service.dart';

void main() {
  late TripRepository tripRepository;
  late StopRepository stopRepository;
  late StopTrackingService trackingService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await AppDatabase.instance.closeDatabase();

    final databasePath = await getDatabasesPath();
    await deleteDatabase(p.join(databasePath, 'waypoint.db'));

    tripRepository = TripRepository();
    stopRepository = StopRepository();

    trackingService = StopTrackingService(stopRepository: stopRepository);

    await tripRepository.insertTrip(
      TripModel(
        id: 'trip-1',
        name: 'Paris Trip',
        destination: 'Paris',
        startDate: DateTime(2026, 11, 10),
        endDate: DateTime(2026, 11, 17),
        tripType: 'Day Trip',
        budget: 500,
      ),
    );

    await stopRepository.insertStop(
      const StopModel(
        id: 'stop-1',
        tripId: 'trip-1',
        name: 'Eiffel Tower',
        location: 'Paris',
        plannedDuration: 120,
      ),
    );
  });

  tearDown(() async {
    await AppDatabase.instance.closeDatabase();
  });

  test('check-in records time and changes status', () async {
    await trackingService.checkIn('stop-1');

    final stop = await stopRepository.getStopById('stop-1');

    expect(stop, isNotNull);
    expect(stop!.checkInTime, isNotNull);
    expect(stop.status, 'in_progress');
  });

  test('check-out records time and completes the stop', () async {
    await trackingService.checkIn('stop-1');
    await trackingService.checkOut('stop-1');

    final stop = await stopRepository.getStopById('stop-1');

    expect(stop, isNotNull);
    expect(stop!.checkInTime, isNotNull);
    expect(stop.checkOutTime, isNotNull);
    expect(stop.actualDuration, isNotNull);
    expect(stop.actualDuration, greaterThanOrEqualTo(0));
    expect(stop.status, 'completed');
  });

  test('check-in fails for an unknown stop', () async {
    expect(
      () => trackingService.checkIn('unknown-stop'),
      throwsA(isA<StateError>()),
    );
  });

  test('check-out fails if the stop has not been checked in', () async {
    expect(
      () => trackingService.checkOut('stop-1'),
      throwsA(isA<StateError>()),
    );
  });

  test('repeated check-in is rejected', () async {
    await trackingService.checkIn('stop-1');

    expect(() => trackingService.checkIn('stop-1'), throwsA(isA<StateError>()));
  });

  test('repeated check-out is rejected', () async {
    await trackingService.checkIn('stop-1');
    await trackingService.checkOut('stop-1');

    expect(
      () => trackingService.checkOut('stop-1'),
      throwsA(isA<StateError>()),
    );
  });
}
