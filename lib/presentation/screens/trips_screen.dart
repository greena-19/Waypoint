
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/notification_service.dart';
import '../providers/trips_provider.dart';
import 'trip_detail_screen.dart';
import 'trip_editor_screen.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  int _getReminderId(String tripId) {
    var hash = 0x811c9dc5;

    for (final character in tripId.codeUnits) {
      hash = ((hash ^ character) * 0x01000193) & 0x7fffffff;
    }

    return hash;
  }

  Future<void> _syncTripReminder(TripSummary trip) async {
    final startDate = trip.startDate;

    final reminderTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day - 1,
      9,
    );

    final notificationService = NotificationService.instance;
    final reminderId = _getReminderId(trip.id);

    if (!reminderTime.isAfter(DateTime.now())) {
      await notificationService.cancelReminder(reminderId);
      return;
    }

    await notificationService.scheduleReminder(
      id: reminderId,
      title: 'Your trip is tomorrow!',
      body: 'Get ready for ${trip.name} in ${trip.destination}.',
      scheduledTime: reminderTime,
    );
  }

  Future<void> _editTrip(
    BuildContext context,
    WidgetRef ref,
    int index,
    TripSummary trip,
  ) async {
    final updatedTrip = await showDialog<TripSummary>(
      context: context,
      builder: (dialogContext) => _EditTripDialog(trip: trip),
    );

    if (!context.mounted || updatedTrip == null) return;

    try {
      await ref
          .read(tripsProvider.notifier)
          .updateTrip(index, updatedTrip);

      if (!context.mounted) return;

      String message = 'Trip updated successfully.';

      try {
        await _syncTripReminder(updatedTrip);
        message = 'Trip updated and reminder refreshed.';
      } catch (error) {
        message = 'Trip updated, but its reminder could not be refreshed.';
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update trip: $error'),
        ),
      );
    }
  }

  Future<void> _deleteTrip(
    BuildContext context,
    WidgetRef ref,
    int index,
    TripSummary trip,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text(
          'Are you sure you want to delete "${trip.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!context.mounted || shouldDelete != true) return;

    try {
      await ref
          .read(tripsProvider.notifier)
          .deleteTrip(index);

      if (!context.mounted) return;

      String message = 'Trip deleted successfully.';

      try {
        await NotificationService.instance.cancelReminder(
          _getReminderId(trip.id),
        );
        message = 'Trip deleted and its reminder cancelled.';
      } catch (error) {
        message = 'Trip deleted, but its reminder could not be cancelled.';
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete trip: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
      ),
      body: trips.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route, size: 80),
                  SizedBox(height: 16),
                  Text(
                    'Plan your first trip',
                    style: TextStyle(fontSize: 22),
                  ),
                  SizedBox(height: 8),
                  Text('Your adventures start here!'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(trip.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip.destination),
                        Text(
                          '${trip.startDate.month}/'
                          '${trip.startDate.day}/'
                          '${trip.startDate.year} - '
                          '${trip.endDate.month}/'
                          '${trip.endDate.day}/'
                          '${trip.endDate.year}',
                        ),
                        Text('Budget: \$${trip.budget.round()}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Edit Trip',
                          onPressed: () {
                            _editTrip(context, ref, index, trip);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete Trip',
                          onPressed: () {
                            _deleteTrip(context, ref, index, trip);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TripDetailScreen(trip: trip),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TripEditorScreen(),
            ),
          );
        },
        tooltip: 'Add Trip',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EditTripDialog extends StatefulWidget {
  final TripSummary trip;

  const _EditTripDialog({required this.trip});

  @override
  State<_EditTripDialog> createState() => _EditTripDialogState();
}

class _EditTripDialogState extends State<_EditTripDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _destinationController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.trip.name,
    );

    _destinationController = TextEditingController(
      text: widget.trip.destination,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    final updatedTrip = widget.trip.copyWith(
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
    );

    Navigator.pop(context, updatedTrip);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Trip'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Trip Name',
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Please enter a trip name';
                  }

                  if (name.length > 40) {
                    return 'Maximum 40 characters';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                ),
                validator: (value) {
                  final destination = value?.trim() ?? '';

                  if (destination.isEmpty) {
                    return 'Please enter a destination';
                  }

                  if (destination.length > 60) {
                    return 'Maximum 60 characters';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveChanges,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
