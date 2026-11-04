import '../database/app_database.dart';
import '../models/trip_model.dart';

class TripRepository {
  final AppDatabase _appDatabase;

  TripRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<void> insertTrip(TripModel trip) async {
    final db = await _appDatabase.database;
    await db.insert('trips', trip.toMap());
  }

  Future<List<TripModel>> getAllTrips() async {
    final db = await _appDatabase.database;
    final result = await db.query('trips', orderBy: 'start_date ASC');
    return result.map(TripModel.fromMap).toList();
  }

  Future<TripModel?> getTripById(String id) async {
    final db = await _appDatabase.database;
    final result = await db.query(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return TripModel.fromMap(result.first);
  }

  Future<void> updateTrip(TripModel trip) async {
    final db = await _appDatabase.database;
    await db.update(
      'trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<void> deleteTrip(String id) async {
    final db = await _appDatabase.database;
    await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }
}
