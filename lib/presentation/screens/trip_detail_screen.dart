
import 'package:flutter/material.dart';

import '../../data/models/stop_model.dart';
import '../../data/repositories/stop_repository.dart';
import '../../services/stop_tracking_service.dart';
import '../providers/trips_provider.dart';
import 'stop_editor_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final TripSummary trip;

  const TripDetailScreen({
    super.key,
    required this.trip,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final StopRepository _stopRepository = StopRepository();
  final StopTrackingService _trackingService = StopTrackingService();

  late Future<List<StopModel>> _stopsFuture;

  @override
  void initState() {
    super.initState();
    _loadStops();
  }

  void _loadStops() {
    _stopsFuture = _stopRepository.getStopsForTrip(widget.trip.id);
  }

  Future<void> _refreshStops() async {
    setState(_loadStops);
    await _stopsFuture;
  }

  Future<void> _addStop() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => StopEditorScreen(
          tripId: widget.trip.id,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await _refreshStops();
    }
  }

  Future<void> _editStop(StopModel stop) async {
    final nameController = TextEditingController(text: stop.name);
    final locationController =
        TextEditingController(text: stop.location);
    final durationController =
        TextEditingController(text: '${stop.plannedDuration}');

    try {
      final updatedValues = await showDialog<List<String>>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Edit Stop'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Stop Name',
                  ),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                  ),
                ),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Planned Duration (minutes)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final location = locationController.text.trim();
                final duration =
                    int.tryParse(durationController.text.trim());

                if (name.isEmpty ||
                    location.isEmpty ||
                    duration == null ||
                    duration <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Enter valid stop details.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, [
                  name,
                  location,
                  '$duration',
                ]);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (!mounted || updatedValues == null) return;

      final updatedStop = StopModel(
        id: stop.id,
        tripId: stop.tripId,
        name: updatedValues[0],
        location: updatedValues[1],
        plannedDuration: int.parse(updatedValues[2]),
        actualDuration: stop.actualDuration,
        checkInTime: stop.checkInTime,
        checkOutTime: stop.checkOutTime,
        status: stop.status,
      );

      await _stopRepository.updateStop(updatedStop);

      if (!mounted) return;

      await _refreshStops();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update stop: $error')),
      );
    } finally {
      nameController.dispose();
      locationController.dispose();
      durationController.dispose();
    }
  }

  Future<void> _deleteStop(StopModel stop) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Stop'),
        content: Text('Delete "${stop.name}"?'),
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

    if (!mounted || shouldDelete != true) return;

    try {
      await _stopRepository.deleteStop(stop.id);

      if (!mounted) return;

      await _refreshStops();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop deleted successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete stop: $error')),
      );
    }
  }

  Future<void> _checkIn(StopModel stop) async {
    try {
      await _trackingService.checkIn(stop.id);

      if (!mounted) return;
      await _refreshStops();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checked in to ${stop.name}.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not check in: $error')),
      );
    }
  }

  Future<void> _checkOut(StopModel stop) async {
    try {
      await _trackingService.checkOut(stop.id);

      if (!mounted) return;
      await _refreshStops();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checked out of ${stop.name}.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not check out: $error')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatTripType(String type) {
    switch (type) {
      case 'day':
        return 'Day Trip';
      case 'weekend':
        return 'Weekend Trip';
      case 'multi_day':
        return 'Multi-day Trip';
      default:
        return type;
    }
  }

  Widget _buildStops(List<StopModel> stops) {
    if (stops.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.add_location_alt_outlined,
                size: 56,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text('No stops added yet'),
              SizedBox(height: 4),
              Text('Add your first stop to start planning.'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: stops.map((stop) {
        final isCompleted = stop.status == 'completed';
        final isInProgress = stop.status == 'in_progress';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : isInProgress
                            ? Icons.directions_walk
                            : Icons.location_on_outlined,
                    color: isCompleted ? Colors.green : null,
                  ),
                  title: Text(stop.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stop.location),
                      Text('Planned: ${stop.plannedDuration} minutes'),
                      if (stop.actualDuration != null)
                        Text('Actual: ${stop.actualDuration} minutes'),
                      Text('Status: ${stop.status.replaceAll('_', ' ')}'),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (!isInProgress && !isCompleted)
                      TextButton.icon(
                        onPressed: () => _editStop(stop),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    TextButton.icon(
                      onPressed: () => _deleteStop(stop),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Delete'),
                    ),
                  ],
                ),
                if (isCompleted)
                  const Text('Visit completed')
                else if (isInProgress)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _checkOut(stop),
                      icon: const Icon(Icons.logout),
                      label: const Text('Check Out'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _checkIn(stop),
                      icon: const Icon(Icons.login),
                      label: const Text('Check In'),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
      ),
      body: FutureBuilder<List<StopModel>>(
        future: _stopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load trip stops.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      setState(_loadStops);
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final stops = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined),
                          const SizedBox(width: 8),
                          Expanded(child: Text(trip.destination)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: const Text('Trip Dates'),
                        subtitle: Text(
                          '${_formatDate(trip.startDate)} - '
                          '${_formatDate(trip.endDate)}',
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: const Text('Trip Type'),
                        subtitle: Text(_formatTripType(trip.tripType)),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(
                          Icons.account_balance_wallet_outlined,
                        ),
                        title: const Text('Budget'),
                        subtitle: Text(
                          '\$${trip.budget.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Trip Stops (${stops.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildStops(stops),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStop,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Stop'),
      ),
    );
  }
}
