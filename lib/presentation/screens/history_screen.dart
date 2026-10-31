
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
      ),
      body: const Center(
        child: Text(
          'No completed trips yet',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
