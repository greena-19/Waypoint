import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripSummary {
  final String name;
  final String destination;

  const TripSummary({required this.name, required this.destination});
}

class TripsNotifier extends Notifier<List<TripSummary>> {
  @override
  List<TripSummary> build() => [];

  void addTrip(TripSummary trip) {
    state = [...state, trip];
  }
}

final tripsProvider = NotifierProvider<TripsNotifier, List<TripSummary>>(
  TripsNotifier.new,
);
