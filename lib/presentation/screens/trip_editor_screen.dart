
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/trips_provider.dart';
import '../../services/notification_service.dart';
import 'trip_detail_screen.dart';

class TripEditorScreen extends ConsumerStatefulWidget {
  const TripEditorScreen({super.key});

  @override
  ConsumerState<TripEditorScreen> createState() => _TripEditorScreenState();
}

class _TripEditorScreenState extends ConsumerState<TripEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();

  DateTimeRange? _dateRange;
  double _budget = 200;
  String _tripType = 'day';
  bool _isSaving = false;

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
      initialDateRange:
          _dateRange ?? DateTimeRange(start: now, end: now),
    );

    if (!mounted) return;

    if (selected != null) {
      setState(() {
        _dateRange = selected;
      });
    }
  }

  int _getReminderId(String tripId) {
    var hash = 0x811c9dc5;

    for (final character in tripId.codeUnits) {
      hash = ((hash ^ character) * 0x01000193) & 0x7fffffff;
    }

    return hash;
  }

  Future<void> _scheduleTripReminder(TripSummary trip) async {
    final startDate = trip.startDate;

    final reminderTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day - 1,
      9,
    );

    if (!reminderTime.isAfter(DateTime.now())) {
      return;
    }

    await NotificationService.instance.scheduleReminder(
      id: _getReminderId(trip.id),
      title: 'Your trip is tomorrow!',
      body: 'Get ready for ${trip.name} in ${trip.destination}.',
      scheduledTime: reminderTime,
    );
  }

  Future<void> _saveTrip() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select trip dates'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newTrip = TripSummary(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      destination: _destinationController.text.trim(),
      startDate: _dateRange!.start,
      endDate: _dateRange!.end,
      tripType: _tripType,
      budget: _budget,
    );

    try {
      await ref.read(tripsProvider.notifier).addTrip(newTrip);

      String reminderMessage = 'Trip saved successfully.';

      try {
        await _scheduleTripReminder(newTrip);
        final reminderTime = DateTime(
          newTrip.startDate.year,
          newTrip.startDate.month,
          newTrip.startDate.day - 1,
          9,
        );

        if (reminderTime.isAfter(DateTime.now())) {
          reminderMessage = 'Trip saved. Reminder scheduled for 9:00 AM the day before.';
        } else {
          reminderMessage = 'Trip saved. It is too soon to schedule a reminder.';
        }
      } catch (error) {
        reminderMessage = 'Trip saved, but its reminder could not be scheduled.';
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(reminderMessage)),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TripDetailScreen(trip: newTrip),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save trip: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
      ),
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
                  setState(() {
                    _tripType = value;
                  });
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
                setState(() {
                  _budget = value;
                });
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveTrip,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving ? 'Saving...' : 'Save Trip',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
