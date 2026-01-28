import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../business_profile/business_profile_screen.dart';

class BusinessProfileTile extends StatelessWidget {
  const BusinessProfileTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      title: Text(l10n.businessProfile),
      subtitle: Text(l10n.manageBusinessDetails),
      leading: Icon(Icons.business, color: theme.colorScheme.primary),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BusinessProfileScreen()),
        );
      },
    );
  }
}
