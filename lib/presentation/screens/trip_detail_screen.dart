import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/stop_model.dart';
import '../../data/repositories/stop_repository.dart';
import '../../services/stop_tracking_service.dart';
import '../providers/trips_provider.dart';
import 'stop_editor_screen.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final TripSummary trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
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

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addStop() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => StopEditorScreen(tripId: widget.trip.id),
      ),
    );

    if (!mounted || saved != true) return;

    try {
      await _refreshStops();
      _showMessage('Stop added successfully');
    } catch (error) {
      _showMessage('Could not refresh stops: $error');
    }
  }

  Future<void> _editStop(StopModel stop) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            StopEditorScreen(tripId: widget.trip.id, existingStop: stop),
      ),
    );

    if (!mounted || saved != true) return;

    try {
      await _refreshStops();
      _showMessage('Stop updated successfully');
    } catch (error) {
      _showMessage('Could not refresh stops: $error');
    }
  }

  Future<void> _deleteStop(StopModel stop) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Stop'),
        content: Text('Are you sure you want to delete "${stop.name}"?'),
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
      _showMessage('Stop deleted successfully');
    } catch (error) {
      _showMessage('Could not delete stop: $error');
    }
  }

  Future<void> _checkIn(StopModel stop) async {
    try {
      await _trackingService.checkIn(stop.id);

      if (!mounted) return;

      await _refreshStops();
      _showMessage('Checked in to ${stop.name}');
    } catch (error) {
      _showMessage('Could not check in: $error');
    }
  }

  Future<void> _checkOut(StopModel stop) async {
    try {
      await _trackingService.checkOut(stop.id);

      if (!mounted) return;

      await _refreshStops();
      _showMessage('Checked out of ${stop.name}');
    } catch (error) {
      _showMessage('Could not check out: $error');
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
              Text('No stops added yet', textAlign: TextAlign.center),
              SizedBox(height: 4),
              Text(
                'Add your first stop to start planning.',
                textAlign: TextAlign.center,
              ),
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
          key: ValueKey(stop.id),
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
                        : Icons.place_outlined,
                    color: isCompleted ? Colors.green : null,
                  ),
                  title: Text(stop.name, softWrap: true),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stop.location, softWrap: true),
                      const SizedBox(height: 4),
                      Text('Planned: ${stop.plannedDuration} minutes'),
                      if (stop.actualDuration != null)
                        Text('Actual: ${stop.actualDuration} minutes'),
                      if (stop.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Notes: ${stop.notes}', softWrap: true),
                      ],
                      const SizedBox(height: 4),
                      Text('Status: ${stop.status.replaceAll('_', ' ')}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Options for ${stop.name}',
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editStop(stop);
                      } else if (value == 'delete') {
                        _deleteStop(stop);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!isInProgress && !isCompleted)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Stop'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Stop'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (isCompleted)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Visit completed'),
                  )
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
    final trips = ref.watch(tripsProvider);

    final tripIndex = trips.indexWhere((item) => item.id == widget.trip.id);

    final trip = tripIndex >= 0 ? trips[tripIndex] : widget.trip;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: FutureBuilder<List<StopModel>>(
        future: _stopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        softWrap: true,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(trip.destination, softWrap: true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_month_outlined),
                      title: const Text('Trip Dates'),
                      subtitle: Text(
                        '${_formatDate(trip.startDate)} - '
                        '${_formatDate(trip.endDate)}',
                        softWrap: true,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: const Text('Trip Type'),
                      subtitle: Text(_formatTripType(trip.tripType)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.account_balance_wallet_outlined,
                      ),
                      title: const Text('Budget'),
                      subtitle: Text('\$${trip.budget.toStringAsFixed(2)}'),
                    ),
                  ],
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
        tooltip: 'Add a stop to this trip',
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Stop'),
      ),
    );
  }
}
