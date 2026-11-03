import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _themeKey = 'waypoint_theme_mode';

  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  Future<void> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final savedTheme = preferences.getString(_themeKey);

    if (savedTheme == null) return;

    state = ThemeMode.values.firstWhere(
      (mode) => mode.name == savedTheme,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
