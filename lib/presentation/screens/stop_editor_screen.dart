
import 'package:flutter/material.dart';

import '../models/trip_stop.dart';

class StopEditorScreen extends StatefulWidget {
  final String tripId;
  final TripStop? existingStop;

  const StopEditorScreen({
    super.key,
    required this.tripId,
    this.existingStop,
  });

  @override
  State<StopEditorScreen> createState() => _StopEditorScreenState();
}

class _StopEditorScreenState extends State<StopEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;

  bool get _isEditing => widget.existingStop != null;

  @override
  void initState() {
    super.initState();

    final stop = widget.existingStop;

    _nameController = TextEditingController(
      text: stop?.name ?? '',
    );

    _locationController = TextEditingController(
      text: stop?.location ?? '',
    );

    _durationController = TextEditingController(
      text: (stop?.plannedDurationMinutes ?? 60).toString(),
    );

    _notesController = TextEditingController(
      text: stop?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveStop() {
    if (!_formKey.currentState!.validate()) return;

    final stop = TripStop(
      id: widget.existingStop?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      tripId: widget.tripId,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      plannedDurationMinutes:
          int.parse(_durationController.text.trim()),
      notes: _notesController.text.trim(),
    );

    Navigator.pop(context, stop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Stop' : 'Add Stop'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Stop Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a stop name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Planned Duration (minutes)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer_outlined),
              ),
              validator: (value) {
                final duration = int.tryParse(value?.trim() ?? '');
                if (duration == null || duration <= 0) {
                  return 'Enter a valid duration greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saveStop,
              icon: const Icon(Icons.save_outlined),
              label: Text(_isEditing ? 'Save Changes' : 'Save Stop'),
            ),
          ],
        ),
      ),
    );
  }
}
