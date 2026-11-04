import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/presentation/widgets/duration_suggestion_card.dart';

void main() {
  group('DurationSuggestionCard', () {
    testWidgets('displays current and suggested durations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DurationSuggestionCard(
              currentDurationMinutes: 60,
              suggestedDurationMinutes: 90,
              onApply: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Current duration: 60 minutes'), findsOneWidget);

      expect(find.text('Suggested duration: 90 minutes'), findsOneWidget);

      expect(find.text('Apply'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('Apply button calls onApply', (tester) async {
      var applied = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DurationSuggestionCard(
              currentDurationMinutes: 60,
              suggestedDurationMinutes: 90,
              onApply: () {
                applied = true;
              },
              onDismiss: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Apply'));
      await tester.pump();

      expect(applied, isTrue);
    });

    testWidgets('Not now button calls onDismiss', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DurationSuggestionCard(
              currentDurationMinutes: 60,
              suggestedDurationMinutes: 90,
              onApply: () {},
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Not now'));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('shows when suggested duration is longer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DurationSuggestionCard(
              currentDurationMinutes: 60,
              suggestedDurationMinutes: 90,
              onApply: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('30 minutes longer'), findsOneWidget);
    });

    testWidgets('shows when suggested duration is shorter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DurationSuggestionCard(
              currentDurationMinutes: 120,
              suggestedDurationMinutes: 90,
              onApply: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('30 minutes shorter'), findsOneWidget);
    });
  });
}
