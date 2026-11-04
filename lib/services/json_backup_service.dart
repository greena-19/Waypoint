
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../data/database/app_database.dart';
import '../data/models/stop_model.dart';
import '../data/models/trip_model.dart';
import '../data/repositories/stop_repository.dart';
import '../data/repositories/trip_repository.dart';

class JsonBackupService {
  final TripRepository _tripRepository;
  final StopRepository _stopRepository;
  final AppDatabase _appDatabase;

  JsonBackupService({
    TripRepository? tripRepository,
    StopRepository? stopRepository,
    AppDatabase? appDatabase,
  })  : _tripRepository = tripRepository ?? TripRepository(),
        _stopRepository = stopRepository ?? StopRepository(),
        _appDatabase = appDatabase ?? AppDatabase.instance;

  /// Exports every trip and its stops as a JSON string.
  Future<String> exportBackup() async {
    final trips = await _tripRepository.getAllTrips();
    final backupTrips = <Map<String, dynamic>>[];

    for (final trip in trips) {
      final stops = await _stopRepository.getStopsForTrip(trip.id);

      backupTrips.add({
        'trip': trip.toMap(),
        'stops': stops.map((stop) => stop.toMap()).toList(),
      });
    }

    final backup = {
      'app': 'Waypoint',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'trips': backupTrips,
    };

    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  /// Validates and imports a Waypoint JSON backup atomically.
  Future<int> importBackup(String jsonString) async {
    final dynamic decoded;

    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw const FormatException('The backup file is not valid JSON.');
    }

    if (decoded is! Map<String, dynamic> ||
        decoded['app'] != 'Waypoint' ||
        decoded['version'] != 1 ||
        decoded['trips'] is! List) {
      throw const FormatException(
        'Invalid or unsupported Waypoint backup.',
      );
    }

    final backupTrips = decoded['trips'] as List<dynamic>;
    final parsedTrips = <MapEntry<TripModel, List<StopModel>>>[];

    // Validate the entire backup before writing anything.
    for (final item in backupTrips) {
      if (item is! Map<String, dynamic> ||
          item['trip'] is! Map<String, dynamic> ||
          item['stops'] is! List) {
        throw const FormatException('Invalid trip data in backup.');
      }

      final trip = TripModel.fromMap(
        Map<String, dynamic>.from(item['trip'] as Map),
      );

      final stops = <StopModel>[];

      for (final stopData in item['stops'] as List<dynamic>) {
        if (stopData is! Map<String, dynamic>) {
          throw const FormatException('Invalid stop data in backup.');
        }

        final stop = StopModel.fromMap(
          Map<String, dynamic>.from(stopData),
        );

        if (stop.tripId != trip.id) {
          throw const FormatException(
            'A stop belongs to a different trip in the backup.',
          );
        }

        stops.add(stop);
      }

      parsedTrips.add(MapEntry(trip, stops));
    }

    // Import all records in one transaction.
    final db = await _appDatabase.database;

    await db.transaction((txn) async {
      for (final entry in parsedTrips) {
        final trip = entry.key;

        await txn.insert(
          'trips',
          trip.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (final stop in entry.value) {
          await txn.insert(
            'stops',
            stop.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });

    return parsedTrips.length;
  }
}
