import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stops_provider.dart';
import '../providers/trips_provider.dart';
import 'trip_detail_screen.dart';
import 'trip_editor_screen.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  Future<void> _editTrip(
    BuildContext context,
    WidgetRef ref,
    TripSummary trip,
  ) async {
    final updatedTrip = await showDialog<TripSummary>(
      context: context,
      builder: (dialogContext) => _EditTripDialog(trip: trip),
    );

    if (!context.mounted || updatedTrip == null) return;

    final trips = ref.read(tripsProvider);
    final index = trips.indexWhere((item) => item.id == trip.id);

    if (index == -1) return;

    ref.read(tripsProvider.notifier).updateTrip(index, updatedTrip);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trip updated successfully')));
  }

  Future<void> _deleteTrip(
    BuildContext context,
    WidgetRef ref,
    TripSummary trip,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Are you sure you want to delete "${trip.name}"?'),
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

    final trips = ref.read(tripsProvider);
    final index = trips.indexWhere((item) => item.id == trip.id);

    if (index == -1) return;

    ref.read(tripsProvider.notifier).deleteTrip(index);
    ref.read(stopsProvider.notifier).deleteStopsForTrip(trip.id);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trip deleted successfully')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Trips')),
      body: trips.isEmpty
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.route, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      'Plan your first trip',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your adventures start here!',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];

                return Card(
                  key: ValueKey(trip.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TripDetailScreen(trip: trip),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trip.name,
                                        softWrap: true,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(trip.destination, softWrap: true),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${trip.startDate.month}/'
                                        '${trip.startDate.day}/'
                                        '${trip.startDate.year} - '
                                        '${trip.endDate.month}/'
                                        '${trip.endDate.day}/'
                                        '${trip.endDate.year}',
                                        softWrap: true,
                                      ),
                                      const SizedBox(height: 6),
                                      Text('Budget: \$${trip.budget.round()}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Edit Trip',
                              onPressed: () {
                                _editTrip(context, ref, trip);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete Trip',
                              onPressed: () {
                                _deleteTrip(context, ref, trip);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TripEditorScreen()),
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

    _nameController = TextEditingController(text: widget.trip.name);

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
                decoration: const InputDecoration(labelText: 'Trip Name'),
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
                decoration: const InputDecoration(labelText: 'Destination'),
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
