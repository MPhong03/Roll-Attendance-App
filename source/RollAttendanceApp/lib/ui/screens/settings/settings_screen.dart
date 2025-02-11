import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:itproject/utils/theme_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationEnabled = false;
  bool _cameraEnabled = false;
  bool _locationEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    _notificationEnabled = await Permission.notification.isGranted;
    _cameraEnabled = await Permission.camera.isGranted;
    _locationEnabled = await Permission.location.isGranted;
    setState(() {});
  }

  Future<void> _handlePermissionToggle(
      Permission permission, bool currentValue, Function(bool) onUpdate) async {
    if (currentValue) {
      _showPermissionDialog();
    } else {
      final status = await permission.request();
      onUpdate(status.isGranted);
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cannot disable permission'),
        content: const Text(
            'Permissions can only be disabled from system settings. Do you want to open settings now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSettingItem(
              title: 'Theme',
              subtitle: 'Change system theme',
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (bool value) async {
                await themeProvider.toggleTheme(value);
              },
            ),
            _buildSettingItem(
              title: 'Notification',
              subtitle: 'Allow app to send notifications',
              value: _notificationEnabled,
              onChanged: (bool value) => _handlePermissionToggle(
                  Permission.notification, _notificationEnabled, (status) {
                setState(() {
                  _notificationEnabled = status;
                });
              }),
            ),
            _buildSettingItem(
              title: 'Camera',
              subtitle: 'Allow app to access the camera',
              value: _cameraEnabled,
              onChanged: (bool value) => _handlePermissionToggle(
                  Permission.camera, _cameraEnabled, (status) {
                setState(() {
                  _cameraEnabled = status;
                });
              }),
            ),
            _buildSettingItem(
              title: 'Location',
              subtitle: 'Allow app to access location',
              value: _locationEnabled,
              onChanged: (bool value) => _handlePermissionToggle(
                  Permission.location, _locationEnabled, (status) {
                setState(() {
                  _locationEnabled = status;
                });
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 3,
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
          activeTrackColor: Colors.lightGreen,
        ),
      ),
    );
  }
}
