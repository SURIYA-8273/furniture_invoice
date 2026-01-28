import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/theme_tokens.dart';
import '../../../../../l10n/app_localizations.dart';

class ExcelSyncStatusCard extends StatelessWidget {
  final DateTime? lastSyncTime;

  const ExcelSyncStatusCard({
    super.key,
    this.lastSyncTime,
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
                Icon(Icons.table_view, color: theme.colorScheme.primary),
                SizedBox(width: ThemeTokens.spacingSm),
                Text(
                  l10n.excelSyncStatus, 
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: ThemeTokens.spacingSm),
            if (lastSyncTime != null) ...[
              SizedBox(height: ThemeTokens.spacingSm),
              Text(
                // Display the last export time
                l10n.lastExport(DateFormat('MMM dd, yyyy hh:mm a', l10n.localeName).format(lastSyncTime!)),
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else
               Text(
                l10n.noExportHistory,
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontStyle: FontStyle.italic
                ),
              ),
          ],
        ),
      ),
    );
  }
}
