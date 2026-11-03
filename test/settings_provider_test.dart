import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waypoint/presentation/providers/settings_provider.dart';

void main() {
  group('ThemeModeNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Default theme follows system settings', () {
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('Can switch to light mode', () {
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);

      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('Can switch to dark mode', () {
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('Can return to system default', () {
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);

      expect(container.read(themeModeProvider), ThemeMode.system);
    });
  });
}
