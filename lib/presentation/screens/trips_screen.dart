import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/trips_provider.dart';
import 'trip_detail_screen.dart';
import 'trip_editor_screen.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Trips')),
      body: trips.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.route, size: 80),
                  SizedBox(height: 16),
                  Text('Plan your first trip', style: TextStyle(fontSize: 22)),
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
                    subtitle: Text(trip.destination),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripDetailScreen(
                            tripName: trip.name,
                            destination: trip.destination,
                          ),
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
            MaterialPageRoute(builder: (context) => const TripEditorScreen()),
          );
        },
        tooltip: 'Add Trip',
        child: const Icon(Icons.add),
      ),
    );
  }
}
