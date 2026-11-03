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
    final difference = suggestedDurationMinutes - currentDurationMinutes;

    final differenceText = difference > 0
        ? '$difference minutes longer'
        : difference < 0
        ? '${difference.abs()} minutes shorter'
        : 'Same as your current duration';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Smart Duration Suggestion',
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Current duration: $currentDurationMinutes minutes',
              softWrap: true,
            ),

            const SizedBox(height: 8),

            Text(
              'Suggested duration: $suggestedDurationMinutes minutes',
              softWrap: true,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(differenceText, style: Theme.of(context).textTheme.bodySmall),

            const SizedBox(height: 16),

            const Text('Would you like to use the suggested duration?'),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('Not now'),
                  ),
                  FilledButton(onPressed: onApply, child: const Text('Apply')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
