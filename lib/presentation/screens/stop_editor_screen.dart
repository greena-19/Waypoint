import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/trip_stop.dart';
import '../widgets/duration_suggestion_card.dart';

class StopEditorScreen extends StatefulWidget {
  final String tripId;
  final TripStop? existingStop;

  const StopEditorScreen({super.key, required this.tripId, this.existingStop});

  @override
  State<StopEditorScreen> createState() => _StopEditorScreenState();
}

class _StopEditorScreenState extends State<StopEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;

  // Temporary demonstration value.
  // Replace with the real duration calculation
  // during database and repository integration.
  static const int _demoSuggestedDurationMinutes = 90;

  bool _showSuggestion = false;
  bool _attemptedSave = false;

  bool get _isEditing => widget.existingStop != null;

  @override
  void initState() {
    super.initState();

    final stop = widget.existingStop;

    _nameController = TextEditingController(text: stop?.name ?? '');

    _locationController = TextEditingController(text: stop?.location ?? '');

    _durationController = TextEditingController(
      text: (stop?.plannedDurationMinutes ?? 60).toString(),
    );

    _notesController = TextEditingController(text: stop?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showDurationSuggestion() {
    final duration = int.tryParse(_durationController.text.trim());

    if (duration == null || duration < 1 || duration > 10080) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a duration between 1 and 10080 minutes'),
        ),
      );
      return;
    }

    setState(() {
      _showSuggestion = true;
    });
  }

  void _applySuggestion() {
    setState(() {
      _durationController.text = _demoSuggestedDurationMinutes.toString();
      _showSuggestion = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Suggested duration applied')));
  }

  void _dismissSuggestion() {
    setState(() {
      _showSuggestion = false;
    });
  }

  void _saveStop() {
    setState(() {
      _attemptedSave = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final stop = TripStop(
      id:
          widget.existingStop?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      tripId: widget.tripId,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      plannedDurationMinutes: int.parse(_durationController.text.trim()),
      notes: _notesController.text.trim(),
    );

    Navigator.pop(context, stop);
  }

  @override
  Widget build(BuildContext context) {
    final currentDuration = int.tryParse(_durationController.text.trim()) ?? 60;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Stop' : 'Add Stop')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _attemptedSave
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Stop Name',
                  hintText: 'e.g., Georgia Aquarium',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.isEmpty) {
                    return 'Please enter a stop name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter a location or address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (value) {
                  final location = value?.trim() ?? '';

                  if (location.isEmpty) {
                    return 'Please enter a location';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Planned Duration (minutes)',
                  hintText: 'e.g., 60',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                onChanged: (_) {
                  if (_showSuggestion) {
                    setState(() {
                      _showSuggestion = false;
                    });
                  }
                },
                validator: (value) {
                  final duration = int.tryParse(value?.trim() ?? '');

                  if (duration == null || duration < 1 || duration > 10080) {
                    return 'Enter 1 to 10080 minutes';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _showDurationSuggestion,
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Get Duration Suggestion'),
              ),

              if (_showSuggestion) ...[
                const SizedBox(height: 12),
                Text(
                  'Demo suggestion — calculation not connected yet',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                DurationSuggestionCard(
                  currentDurationMinutes: currentDuration,
                  suggestedDurationMinutes: _demoSuggestedDurationMinutes,
                  onApply: _applySuggestion,
                  onDismiss: _dismissSuggestion,
                ),
              ],

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any useful information',
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

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
