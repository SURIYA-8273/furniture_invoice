import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/section_header.dart';
import 'widgets/theme_tile.dart';
import 'widgets/language_tile.dart';
import 'widgets/business_profile_tile.dart';
import 'widgets/backup_tile.dart';
import 'widgets/app_version_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // General Section
          SectionHeader(title: l10n.general),
          const ThemeTile(),
          const LanguageTile(),

          const Divider(),

          // Business Section
          SectionHeader(title: l10n.business),
          const BusinessProfileTile(),

          const Divider(),

          // Data Section
          SectionHeader(title: l10n.data),
          const BackupTile(),
        
          const Divider(),

          // About Section
          SectionHeader(title: l10n.about),
          const AppVersionTile(),
        ],
      ),
    );
  }
}
