
import 'package:flutter/material.dart';

import '../providers/trips_provider.dart';

class TripDetailScreen extends StatelessWidget {
  final TripSummary trip;

  const TripDetailScreen({
    super.key,
    required this.trip,
  });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
      ),
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
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(trip.destination),
                      ),
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
                    leading: const Icon(
                      Icons.calendar_month_outlined,
                    ),
                    title: const Text('Trip Dates'),
                    subtitle: Text(
                      '${_formatDate(trip.startDate)} - '
                      '${_formatDate(trip.endDate)}',
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.category_outlined,
                    ),
                    title: const Text('Trip Type'),
                    subtitle: Text(
                      _formatTripType(trip.tripType),
                    ),
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
            'Trip Stops',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          const Center(
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stop editor coming soon'),
            ),
          );
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Stop'),
      ),
    );
  }
}
