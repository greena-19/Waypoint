import '../database/app_database.dart';
import '../models/stop_model.dart';

class StopRepository {
  final AppDatabase _appDatabase;

  StopRepository({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<void> insertStop(StopModel stop) async {
    final db = await _appDatabase.database;
    await db.insert('stops', stop.toMap());
  }

  Future<List<StopModel>> getStopsForTrip(String tripId) async {
    final db = await _appDatabase.database;

    final result = await db.query(
      'stops',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'rowid ASC',
    );

    return result.map(StopModel.fromMap).toList();
  }

  Future<StopModel?> getStopById(String id) async {
    final db = await _appDatabase.database;

    final result = await db.query(
      'stops',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return StopModel.fromMap(result.first);
  }

  Future<void> updateStop(StopModel stop) async {
    final db = await _appDatabase.database;

    await db.update(
      'stops',
      stop.toMap(),
      where: 'id = ?',
      whereArgs: [stop.id],
    );
  }

  Future<void> deleteStop(String id) async {
    final db = await _appDatabase.database;
    await db.delete('stops', where: 'id = ?', whereArgs: [id]);
  }
}
