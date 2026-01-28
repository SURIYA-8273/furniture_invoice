import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../backup_settings/backup_settings_screen.dart';

class BackupTile extends StatelessWidget {
  const BackupTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      title: Text(l10n.backup),
      subtitle: Text(l10n.backupYourData),
      leading: Icon(Icons.backup, color: theme.colorScheme.primary),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BackupSettingsScreen()),
        );
      },
    );
  }
}
