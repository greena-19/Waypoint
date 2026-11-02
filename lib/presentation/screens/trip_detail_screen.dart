import 'package:flutter/material.dart';

import '../models/trip_stop.dart';
import '../providers/trips_provider.dart';
import 'stop_editor_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final TripSummary trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final List<TripStop> _stops = [];

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

  Future<void> _addStop() async {
    final newStop = await Navigator.push<TripStop>(
      context,
      MaterialPageRoute(
        builder: (context) => StopEditorScreen(tripId: widget.trip.id),
      ),
    );

    if (!mounted || newStop == null) return;

    setState(() {
      _stops.add(newStop);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Stop added successfully')));
  }

  Future<void> _editStop(int index) async {
    final existingStop = _stops[index];

    final updatedStop = await Navigator.push<TripStop>(
      context,
      MaterialPageRoute(
        builder: (context) => StopEditorScreen(
          tripId: widget.trip.id,
          existingStop: existingStop,
        ),
      ),
    );

    if (!mounted || updatedStop == null) return;

    setState(() {
      _stops[index] = updatedStop;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Stop updated successfully')));
  }

  Future<void> _deleteStop(int index) async {
    final stop = _stops[index];

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Stop'),
        content: Text('Are you sure you want to delete "${stop.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || shouldDelete != true) return;

    setState(() {
      _stops.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Stop deleted successfully')));
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Trip information
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

          // Trip details
          Card(
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
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Budget'),
                  subtitle: Text('\$${trip.budget.toStringAsFixed(2)}'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Trip Stops heading
          Text(
            'Trip Stops (${_stops.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          // Empty state
          if (_stops.isEmpty)
            const Center(
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
            )
          else
            // Display stops with Edit and Delete options
            ..._stops.asMap().entries.map((entry) {
              final index = entry.key;
              final stop = entry.value;

              return Card(
                key: ValueKey(stop.id),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(stop.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stop.location),
                      Text(
                        'Duration: '
                        '${stop.plannedDurationMinutes} minutes',
                      ),
                      if (stop.notes.isNotEmpty) Text('Notes: ${stop.notes}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Stop options',
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editStop(index);
                      } else if (value == 'delete') {
                        _deleteStop(index);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit Stop')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Stop'),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),

      // Add Stop button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStop,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Stop'),
      ),
    );
  }
}
