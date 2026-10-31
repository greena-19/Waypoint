
import 'package:flutter/material.dart';

class TripEditorScreen extends StatefulWidget {
  const TripEditorScreen({super.key});

  @override
  State<TripEditorScreen> createState() => _TripEditorScreenState();
}

class _TripEditorScreenState extends State<TripEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();

  DateTimeRange? _dateRange;
  double _budget = 200;
  String _tripType = 'day';

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();

    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _dateRange ??
          DateTimeRange(start: now, end: now),
    );

    if (selected != null && mounted) {
      setState(() => _dateRange = selected);
    }
  }

  void _saveTrip() {
    if (!_formKey.currentState!.validate()) return;

    if (_dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select trip dates'),
        ),
      );
      return;
    }

    // SQLite persistence will be connected next.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip form validated successfully'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Trip')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Trip Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) {
                  return 'Enter a trip name';
                }
                if (name.length > 40) {
                  return 'Maximum 40 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final destination = value?.trim() ?? '';
                if (destination.isEmpty) {
                  return 'Enter a destination';
                }
                if (destination.length > 60) {
                  return 'Maximum 60 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _tripType,
              decoration: const InputDecoration(
                labelText: 'Trip Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'day',
                  child: Text('Day Trip'),
                ),
                DropdownMenuItem(
                  value: 'weekend',
                  child: Text('Weekend Trip'),
                ),
                DropdownMenuItem(
                  value: 'multi_day',
                  child: Text('Multi-day Trip'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _tripType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDates,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                _dateRange == null
                    ? 'Select Trip Dates'
                    : '${_dateRange!.start.month}/'
                      '${_dateRange!.start.day}/'
                      '${_dateRange!.start.year} - '
                      '${_dateRange!.end.month}/'
                      '${_dateRange!.end.day}/'
                      '${_dateRange!.end.year}',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Budget: \$${_budget.round()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _budget,
              min: 0,
              max: 1000,
              divisions: 100,
              label: '\$${_budget.round()}',
              onChanged: (value) {
                setState(() => _budget = value);
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saveTrip,
              icon: const Icon(Icons.save),
              label: const Text('Save Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
