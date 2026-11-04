import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/settings_provider.dart';
import '../providers/trips_provider.dart';
import '../../services/json_backup_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final JsonBackupService _backupService = JsonBackupService();

  bool _isWorking = false;

  Future<void> _exportBackup() async {
    setState(() => _isWorking = true);

    try {
      final jsonString = await _backupService.exportBackup();
      final directory = await getTemporaryDirectory();

      final file = File(
        '${directory.path}/waypoint_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );

      await file.writeAsString(jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Waypoint Trip Backup',
          text: 'My Waypoint trip backup',
        ),
      );
    } catch (error) {
      _showMessage('Export failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  Future<void> _importBackup() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) return;

      final selectedFile = files.first;
      final filePath = selectedFile.path;

      if (filePath == null) {
        _showMessage('Could not read the selected file.');
        return;
      }

      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Import Backup?'),
          content: const Text(
            'Trips and stops in this backup will be added or updated. '
            'Matching IDs will overwrite existing records. '
            'Other existing records will remain.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      setState(() => _isWorking = true);

      final jsonString = await File(filePath).readAsString();
      final count = await _backupService.importBackup(jsonString);

      // Refresh the visible trips after importing the backup.
      await ref.read(tripsProvider.notifier).loadTrips();

      _showMessage('Successfully imported $count trips.');
    } on FormatException catch (error) {
      _showMessage('Invalid backup file: ${error.message}');
    } catch (error) {
      _showMessage('Import failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isWorking = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Backup & Restore',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Export Backup'),
                  subtitle: const Text(
                    'Save and share your trips as a JSON file',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  enabled: !_isWorking,
                  onTap: _isWorking ? null : _exportBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Import Backup'),
                  subtitle: const Text('Restore trips from a JSON backup file'),
                  trailing: const Icon(Icons.chevron_right),
                  enabled: !_isWorking,
                  onTap: _isWorking ? null : _importBackup,
                ),
              ],
            ),
          ),

          if (_isWorking) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            const Center(child: Text('Please wait...')),
          ],

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
