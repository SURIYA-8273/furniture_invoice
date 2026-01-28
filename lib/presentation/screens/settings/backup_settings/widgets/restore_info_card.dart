import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/theme_tokens.dart';
import '../../../../../l10n/app_localizations.dart';
import 'stat_badge.dart';

class RestoreInfoCard extends StatelessWidget {
  final DateTime? lastImportTime;
  final int billsCount;
  final int paymentsCount;

  const RestoreInfoCard({
    super.key,
    this.lastImportTime,
    required this.billsCount,
    required this.paymentsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(ThemeTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.download_done, color: theme.colorScheme.primary),
                SizedBox(width: ThemeTokens.spacingSm),
                Text(
                  l10n.automaticImport,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: ThemeTokens.spacingSm),
            if (lastImportTime != null) ...[
              SizedBox(height: ThemeTokens.spacingSm),
              Text(
                l10n.lastImport(DateFormat('MMM dd, yyyy hh:mm a', l10n.localeName).format(lastImportTime!)),
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StatBadge(
                    label: l10n.billsRestored,
                    value: '$billsCount',
                    theme: theme,
                  ),
                  StatBadge(
                    label: l10n.paymentsRestored,
                    value: '$paymentsCount',
                    theme: theme,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
