import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/offline_service.dart';
import '../widgets/language_selector.dart';
import '../../../../generated/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${info.version} (Build ${info.buildNumber})';
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offlineService = ref.watch(offlineServiceProvider);
    final isOnline = offlineService.isOnline;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // ACCOUNT SECTION
          _buildSectionHeader(context, l10n.account),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.editProfile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile'),
          ),

          const Divider(),

          // PREFERENCES SECTION
          _buildSectionHeader(context, l10n.preferences),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.notificationsSettings),
            subtitle: Text(l10n.manageNotificationSettings),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pleaseManageNotifications)),
              );
            },
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LanguageSelector(),
          ),

          const Divider(),

          // LEGAL SECTION
          _buildSectionHeader(context, l10n.legalAndAbout),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsOfService),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/tos'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () => _launchUrl('https://example.com/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appVersion),
            trailing: Text(
              _version,
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          const Divider(),

          // DIAGNOSTICS
          _buildSectionHeader(context, l10n.diagnostics),
          ListTile(
            leading: Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              color: isOnline ? Colors.green : Colors.grey,
            ),
            title: Text(l10n.connectionStatus),
            trailing: Text(
              isOnline ? l10n.online : l10n.offlineMode,
              style: TextStyle(
                color: isOnline ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.logout),
                    content: Text(l10n.areYouSureLogout),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          l10n.logout,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await Supabase.instance.client.auth.signOut();
                }
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
