import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/download_bloc.dart';
import '../bloc/download_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverUrlController = TextEditingController(text: 'http://localhost:8000');
  bool _notificationsEnabled = true;
  bool _autoOpenAfterDownload = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrlController.text =
          prefs.getString('server_url') ?? 'http://localhost:8000';
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _autoOpenAfterDownload = prefs.getBool('auto_open') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _serverUrlController.text.trim());
    await prefs.setBool('notifications', _notificationsEnabled);
    await prefs.setBool('auto_open', _autoOpenAfterDownload);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Settings',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Configure your downloader',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 28),

              // App is now Serverless!
              _SectionHeader('Architecture', Icons.cloud_off_rounded),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  const Text(
                    'Local Backend Setup',
                    style: TextStyle(
                        color: AppTheme.accentOrange, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your laptop's local IP address where the yt-dlp Python backend is running (e.g., http://192.168.1.5:8000).",
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _serverUrlController,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Backend URL',
                      labelStyle: const TextStyle(color: AppTheme.textHint),
                      prefixIcon: const Icon(Icons.link_rounded, color: AppTheme.primary, size: 20),
                      filled: true,
                      fillColor: AppTheme.darkBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                    ),
                    onChanged: (_) => _saveSettings(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Preferences Section
              _SectionHeader('Preferences', Icons.tune_rounded),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _ToggleRow(
                    title: 'Download Notifications',
                    subtitle: 'Get notified when downloads complete',
                    icon: Icons.notifications_rounded,
                    value: _notificationsEnabled,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                  ),
                  const Divider(color: AppTheme.darkBorder, height: 1),
                  const SizedBox(height: 4),
                  _ToggleRow(
                    title: 'Auto-Open After Download',
                    subtitle: 'Open file manager after completion',
                    icon: Icons.folder_open_rounded,
                    value: _autoOpenAfterDownload,
                    onChanged: (v) => setState(() => _autoOpenAfterDownload = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // About Section
              _SectionHeader('About', Icons.info_outline_rounded),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _InfoRow(Icons.verified_rounded, 'Engine', 'yt-dlp v2026.06.09', AppTheme.accentGreen),
                  const Divider(color: AppTheme.darkBorder, height: 1),
                  _InfoRow(Icons.phone_android_rounded, 'App Version', '1.0.0', AppTheme.primary),
                  const Divider(color: AppTheme.darkBorder, height: 1),
                  _InfoRow(Icons.flutter_dash_rounded, 'Framework', 'Flutter 3.38.7', AppTheme.info),
                  const Divider(color: AppTheme.darkBorder, height: 1),
                  _InfoRow(Icons.code_rounded, 'Backend', 'FastAPI + Python 3.13', AppTheme.accentOrange),
                ],
              ),
              const SizedBox(height: 20),

              // Storage Section
              _SectionHeader('Storage', Icons.storage_rounded),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.folder_rounded, color: AppTheme.accentOrange, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Download Location',
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            Text('backend/downloaded_files/',
                                style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppTheme.darkCard,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Clear Download History',
                                style: TextStyle(color: AppTheme.textPrimary)),
                            content: const Text(
                              'Clear all history records? This does not delete files.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel',
                                    style: TextStyle(color: AppTheme.textSecondary)),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                      label: const Text('Clear History Records'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.darkCard,
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(color: AppTheme.textHint, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
