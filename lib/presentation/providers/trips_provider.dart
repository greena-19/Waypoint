import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

class TripsNotifier extends Notifier<List<TripSummary>> {
  @override
  List<TripSummary> build() => [];

  void addTrip(TripSummary trip) {
    state = [...state, trip];
  }

  void updateTrip(int index, TripSummary updatedTrip) {
    if (index < 0 || index >= state.length) return;

    final updatedTrips = [...state];
    updatedTrips[index] = updatedTrip;
    state = updatedTrips;
  }

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
