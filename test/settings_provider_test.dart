import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waypoint/presentation/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeModeNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Default theme follows system settings', () {
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('Can switch to light mode', () async {
      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.light);

      expect(container.read(themeModeProvider), ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('waypoint_theme_mode'), 'light');
    });

    test('Can switch to dark mode', () async {
      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      expect(container.read(themeModeProvider), ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('waypoint_theme_mode'), 'dark');
    });

    test('Can return to system default', () async {
      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      await container
          .read(themeModeProvider.notifier)
          .setThemeMode(ThemeMode.system);

      expect(container.read(themeModeProvider), ThemeMode.system);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('waypoint_theme_mode'), 'system');
    });

    test('Can load a previously saved theme', () async {
      SharedPreferences.setMockInitialValues({'waypoint_theme_mode': 'dark'});

      await container.read(themeModeProvider.notifier).loadThemeMode();

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });
}
