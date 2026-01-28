import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/theme_tokens.dart';
import '../../../../../l10n/app_localizations.dart';

class ManualExportCard extends StatelessWidget {
  final bool isConnected;
  final bool isSyncing;
  final bool canExprot;
  final VoidCallback onExport;

  const ManualExportCard({
    super.key,
    required this.isConnected,
    required this.isSyncing,
    required this.canExprot,
    required this.onExport,
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
                Icon(Icons.sync, color: theme.colorScheme.primary),
                SizedBox(width: ThemeTokens.spacingSm),
                Expanded(
                  child: Text(
                    l10n.manualExcelSync,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ThemeTokens.spacingSm),
            Text(l10n.manualExcelSyncDescription),
            SizedBox(height: ThemeTokens.spacingMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canExprot
                    ? () {
                        HapticFeedback.selectionClick();
                        onExport();
                      }
                    : null,
                icon: isSyncing 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                  : const Icon(Icons.file_download),
                label: Text(isSyncing ? l10n.exporting : l10n.exportNow),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: ThemeTokens.spacingMd,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
