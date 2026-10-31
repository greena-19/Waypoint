
import 'package:flutter/material.dart';

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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip editor coming next'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
