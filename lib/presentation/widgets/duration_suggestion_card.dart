import 'package:flutter/material.dart';

class DurationSuggestionCard extends StatelessWidget {
  final int currentDurationMinutes;
  final int suggestedDurationMinutes;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  const DurationSuggestionCard({
    super.key,
    required this.currentDurationMinutes,
    required this.suggestedDurationMinutes,
    required this.onApply,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_outlined),
                const SizedBox(width: 8),
                Text(
                  'Smart Duration Suggestion',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Current duration: $currentDurationMinutes minutes'),
            const SizedBox(height: 4),
            Text(
              'Suggested duration: $suggestedDurationMinutes minutes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Would you like to use the suggested duration?'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onDismiss, child: const Text('Not now')),
                const SizedBox(width: 8),
                FilledButton(onPressed: onApply, child: const Text('Apply')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
