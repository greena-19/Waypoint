
import 'package:flutter/material.dart';
import 'trip_editor_screen.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
      ),

      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.route,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'Plan your first trip',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 8),
            Text(
              'Your adventures start here!',
            ),
          ],
        ),
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
