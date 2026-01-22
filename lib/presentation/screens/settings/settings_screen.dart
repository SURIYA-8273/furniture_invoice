import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../business_profile/business_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // General Section
          _buildSectionHeader(context, 'General'), // TODO: Localize
          SwitchListTile(
            title: Text(l10n.darkTheme),
            subtitle: Text(themeProvider.isDarkMode ? 'Dark Mode Enabled' : 'Light Mode Enabled'), // TODO: Localize
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(languageProvider.currentLocale.languageCode == 'en' ? 'English' : 'Tamil'),
            leading: Icon(Icons.language, color: theme.colorScheme.primary),
            onTap: () {
              // Show language selection dialog
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(l10n.language),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        languageProvider.setEnglish();
                        Navigator.pop(context);
                      },
                      child: const Text('English'),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        languageProvider.setTamil();
                        Navigator.pop(context);
                      },
                      child: const Text('Tamil'), // TODO: Use localized name
                    ),
                  ],
                ),
              );
            },
            trailing: const Icon(Icons.chevron_right),
          ),

          const Divider(),

          // Business Section
          _buildSectionHeader(context, 'Business'), // TODO: Localize
          ListTile(
            title: Text(l10n.businessProfile),
            subtitle: Text('Manage your business details'), // TODO: Localize
            leading: Icon(Icons.business, color: theme.colorScheme.primary),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BusinessProfileScreen()),
              );
            },
            trailing: const Icon(Icons.chevron_right),
          ),

          const Divider(),

          // Data Section
          _buildSectionHeader(context, 'Data'), // TODO: Localize
          ListTile(
            title: Text(l10n.backup),
            subtitle: Text('Backup your data'), // TODO: Localize
            leading: Icon(Icons.backup, color: theme.colorScheme.primary),
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup feature coming soon')),
              );
            },
          ),
          ListTile(
            title: Text(l10n.restore),
            subtitle: Text('Restore from backup'), // TODO: Localize
            leading: Icon(Icons.restore, color: theme.colorScheme.primary),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restore feature coming soon')),
              );
            },
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(context, 'About'), // TODO: Localize
          ListTile(
            title: const Text('Version'), // TODO: Localize
            subtitle: const Text('1.0.0'),
            leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
