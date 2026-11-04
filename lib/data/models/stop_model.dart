class StopModel {
  final String id;
  final String tripId;
  final String name;
  final String location;
  final int plannedDuration;
  final String notes;
  final int? actualDuration;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String status;

  const StopModel({
    required this.id,
    required this.tripId,
    required this.name,
    required this.location,
    required this.plannedDuration,
    this.notes = '',
    this.actualDuration,
    this.checkInTime,
    this.checkOutTime,
    this.status = 'planned',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'name': name,
      'location': location,
      'planned_duration': plannedDuration,
      'notes': notes,
      'actual_duration': actualDuration,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'status': status,
    };
  }

  factory StopModel.fromMap(Map<String, dynamic> map) {
    return StopModel(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      name: map['name'] as String,
      location: map['location'] as String,
      plannedDuration: map['planned_duration'] as int,
      notes: map['notes'] as String? ?? '',
      actualDuration: map['actual_duration'] as int?,
      checkInTime: map['check_in_time'] == null
          ? null
          : DateTime.parse(map['check_in_time'] as String),
      checkOutTime: map['check_out_time'] == null
          ? null
          : DateTime.parse(map['check_out_time'] as String),
      status: map['status'] as String? ?? 'planned',
    );
  }
}
