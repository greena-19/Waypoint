import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/trip_stop.dart';
import '../providers/stops_provider.dart';
import '../providers/trips_provider.dart';
import 'stop_editor_screen.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final TripSummary trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
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

    ref.read(stopsProvider.notifier).addStop(newStop);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Stop added successfully')));
  }

  Future<void> _editStop(TripStop existingStop) async {
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

    ref.read(stopsProvider.notifier).updateStop(updatedStop);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Stop updated successfully')));
  }

  Future<void> _deleteStop(TripStop stop) async {
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

    ref.read(stopsProvider.notifier).deleteStop(stop.id);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Stop deleted successfully')));
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    final stops = ref
        .watch(stopsProvider)
        .where((stop) => stop.tripId == trip.id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: ListView(
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

          Text(
            'Trip Stops (${stops.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          if (stops.isEmpty)
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
            ...stops.map((stop) {
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
                        _editStop(stop);
                      } else if (value == 'delete') {
                        _deleteStop(stop);
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

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStop,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Stop'),
      ),
    );
  }
}
