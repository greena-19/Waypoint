import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/main.dart';

void main() {
  testWidgets('Waypoint displays navigation tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WaypointApp()));

    expect(find.text('My Trips'), findsOneWidget);
    expect(find.text('Trips'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Waypoint opens Trip Editor', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: WaypointApp()));

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Trip Name'), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
  });
}
