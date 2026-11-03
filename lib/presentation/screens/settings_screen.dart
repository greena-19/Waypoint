import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                }
              },
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text('System Default'),
                    subtitle: Text('Follow device appearance'),
                    value: ThemeMode.system,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Light Mode'),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Dark Mode'),
                    value: ThemeMode.dark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('About', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.route_outlined),
                  title: Text('Waypoint'),
                  subtitle: Text('Offline Trip Planner'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('App Information'),
                  subtitle: Text(
                    'Plan trips, organize stops, and manage your adventures.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
