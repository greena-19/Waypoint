
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/trip_model.dart';
import '../../data/repositories/trip_repository.dart';

class TripSummary {
  final String id;
  final String name;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String tripType;
  final double budget;

  const TripSummary({
    required this.id,
    required this.name,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.tripType,
    required this.budget,
  });

  TripSummary copyWith({
    String? name,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? tripType,
    double? budget,
  }) {
    return TripSummary(
      id: id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tripType: tripType ?? this.tripType,
      budget: budget ?? this.budget,
    );
  }

  factory TripSummary.fromModel(TripModel model) {
    return TripSummary(
      id: model.id,
      name: model.name,
      destination: model.destination,
      startDate: model.startDate,
      endDate: model.endDate,
      tripType: model.tripType,
      budget: model.budget,
    );
  }

  TripModel toModel() {
    return TripModel(
      id: id,
      name: name,
      destination: destination,
      startDate: startDate,
      endDate: endDate,
      tripType: tripType,
      budget: budget,
    );
  }
}

class TripsNotifier extends Notifier<List<TripSummary>> {
  final TripRepository _repository = TripRepository();

  @override
  List<TripSummary> build() => [];

  Future<void> loadTrips() async {
    final savedTrips = await _repository.getAllTrips();

    state = savedTrips
        .map((trip) => TripSummary.fromModel(trip))
        .toList();
  }

  Future<void> addTrip(TripSummary trip) async {
    await _repository.insertTrip(trip.toModel());

    state = [...state, trip];
  }

  Future<void> updateTrip(int index, TripSummary updatedTrip) async {
    if (index < 0 || index >= state.length) return;

    await _repository.updateTrip(updatedTrip.toModel());

    final updatedTrips = [...state];
    updatedTrips[index] = updatedTrip;
    state = updatedTrips;
  }

  Future<void> deleteTrip(int index) async {
    if (index < 0 || index >= state.length) return;

    final trip = state[index];

    await _repository.deleteTrip(trip.id);

    state = [
      for (var i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
}

final tripsProvider = NotifierProvider<TripsNotifier, List<TripSummary>>(
  TripsNotifier.new,
);
