import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripSummary {
  final String name;
  final String destination;

  const TripSummary({required this.name, required this.destination});
}

class TripsNotifier extends Notifier<List<TripSummary>> {
  @override
  List<TripSummary> build() => [];

  // Add a new trip
  void addTrip(TripSummary trip) {
    state = [...state, trip];
  }

  // Update an existing trip
  void updateTrip(int index, TripSummary updatedTrip) {
    if (index < 0 || index >= state.length) return;

    final updatedTrips = [...state];
    updatedTrips[index] = updatedTrip;

    state = updatedTrips;
  }

  // Delete an existing trip
  void deleteTrip(int index) {
    if (index < 0 || index >= state.length) return;

    state = [
      for (var i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
}

final tripsProvider = NotifierProvider<TripsNotifier, List<TripSummary>>(
  TripsNotifier.new,
);
