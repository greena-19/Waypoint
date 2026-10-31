import 'package:flutter/material.dart';

class TripDetailScreen extends StatelessWidget {
  final String tripName;
  final String destination;

  const TripDetailScreen({
    super.key,
    required this.tripName,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tripName)),
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
                    tripName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 8),
                      Expanded(child: Text(destination)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Trip Stops', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const Center(child: Text('No stops added yet')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stop editor coming soon')),
          );
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Stop'),
      ),
    );
  }
}
