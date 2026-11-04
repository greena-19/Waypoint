
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/json_backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Waypoint Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Backup'),
            subtitle: const Text(
              'Restore trips from a JSON backup file',
            ),
            trailing: const Icon(Icons.chevron_right),
            enabled: !_isWorking,
            onTap: _isWorking ? null : _importBackup,
          ),
          if (_isWorking) ...[
            const SizedBox(height: 24),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('Please wait...'),
            ),
          ],
        ],
      ),
    );
  }
}
