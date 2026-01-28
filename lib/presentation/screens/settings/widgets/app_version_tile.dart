import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class AppVersionTile extends StatelessWidget {
  const AppVersionTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      title: Text(l10n.version),
      subtitle: Text(l10n.appVersion),
      leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
    );
  }
}
