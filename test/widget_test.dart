
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waypoint/data/database/app_database.dart';
import 'package:waypoint/data/repositories/trip_repository.dart';
import 'package:waypoint/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await AppDatabase.instance.closeDatabase();

    final repository = TripRepository();
    final trips = await repository.getAllTrips();

    for (final trip in trips) {
      await repository.deleteTrip(trip.id);
    }

    await AppDatabase.instance.closeDatabase();
  });

  tearDown(() async {
    await AppDatabase.instance.closeDatabase();
  });

  Future<void> waitForAppToLoad(WidgetTester tester) async {
    await tester.runAsync(() async {
      await Future.delayed(const Duration(seconds: 1));
    });

    await tester.pump();
  }

  testWidgets('Waypoint displays navigation tabs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: WaypointApp()),
    );

    await waitForAppToLoad(tester);

    expect(find.text('My Trips'), findsOneWidget);
    expect(find.text('Trips'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Waypoint opens Trip Editor', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: WaypointApp()),
    );

    await waitForAppToLoad(tester);

    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Create Trip'), findsOneWidget);
    expect(find.text('Trip Name'), findsOneWidget);
    expect(find.text('Destination'), findsOneWidget);
  });
}
