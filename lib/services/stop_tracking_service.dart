
import '../data/models/stop_model.dart';
import '../data/repositories/stop_repository.dart';

class StopTrackingService {
  final StopRepository _stopRepository;

  StopTrackingService({
    StopRepository? stopRepository,
  }) : _stopRepository = stopRepository ?? StopRepository();

  /// Records the check-in time for a stop.
  Future<void> checkIn(String stopId) async {
    final stop = await _stopRepository.getStopById(stopId);

    if (stop == null) {
      throw StateError('Stop not found.');
    }

    if (stop.checkInTime != null) {
      throw StateError('This stop has already been checked in.');
    }

    final updatedStop = StopModel(
      id: stop.id,
      tripId: stop.tripId,
      name: stop.name,
      location: stop.location,
      plannedDuration: stop.plannedDuration,
      actualDuration: stop.actualDuration,
      checkInTime: DateTime.now(),
      checkOutTime: stop.checkOutTime,
      status: 'in_progress',
    );

    await _stopRepository.updateStop(updatedStop);
  }

  /// Records the check-out time and calculates the actual duration.
  Future<void> checkOut(String stopId) async {
    final stop = await _stopRepository.getStopById(stopId);

    if (stop == null) {
      throw StateError('Stop not found.');
    }

    final checkInTime = stop.checkInTime;

    if (checkInTime == null) {
      throw StateError('Check in to this stop before checking out.');
    }

    if (stop.checkOutTime != null) {
      throw StateError('This stop has already been checked out.');
    }

    final checkOutTime = DateTime.now();
    final actualDuration = checkOutTime.difference(checkInTime).inMinutes;

    final updatedStop = StopModel(
      id: stop.id,
      tripId: stop.tripId,
      name: stop.name,
      location: stop.location,
      plannedDuration: stop.plannedDuration,
      actualDuration: actualDuration,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      status: 'completed',
    );

    await _stopRepository.updateStop(updatedStop);
  }
}
