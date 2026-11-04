import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/trip_stop.dart';

class StopsNotifier extends Notifier<List<TripStop>> {
  @override
  List<TripStop> build() {
    return [];
  }

  void addStop(TripStop stop) {
    state = [...state, stop];
  }

  void updateStop(TripStop updatedStop) {
    state = [
      for (final stop in state)
        if (stop.id == updatedStop.id) updatedStop else stop,
    ];
  }

  void deleteStop(String stopId) {
    state = state.where((stop) => stop.id != stopId).toList();
  }

  void deleteStopsForTrip(String tripId) {
    state = state.where((stop) => stop.tripId != tripId).toList();
  }
}

final stopsProvider = NotifierProvider<StopsNotifier, List<TripStop>>(
  StopsNotifier.new,
);
