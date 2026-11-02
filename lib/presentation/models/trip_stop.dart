class TripStop {
  final String id;
  final String tripId;
  final String name;
  final String location;
  final int plannedDurationMinutes;
  final String notes;

  const TripStop({
    required this.id,
    required this.tripId,
    required this.name,
    required this.location,
    required this.plannedDurationMinutes,
    this.notes = '',
  });

  TripStop copyWith({
    String? id,
    String? tripId,
    String? name,
    String? location,
    int? plannedDurationMinutes,
    String? notes,
  }) {
    return TripStop(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      location: location ?? this.location,
      plannedDurationMinutes:
          plannedDurationMinutes ?? this.plannedDurationMinutes,
      notes: notes ?? this.notes,
    );
  }
}
