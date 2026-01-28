import 'package:flutter/material.dart';
import '../../../../../core/theme/theme_tokens.dart';
import '../../../../../l10n/app_localizations.dart';

class ExcelSyncSettingsCard extends StatelessWidget {
  final bool isExcelSyncEnabled;
  final bool isConnected;
  final int excelSyncFrequencyDays;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onFrequencyChange;

  const ExcelSyncSettingsCard({
    super.key,
    required this.isExcelSyncEnabled,
    required this.isConnected,
    required this.excelSyncFrequencyDays,
    this.onToggle,
    this.onFrequencyChange,
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
                Icon(Icons.table_chart, color: theme.colorScheme.primary),
                SizedBox(width: ThemeTokens.spacingSm),
                Expanded(
                  child: Text(
                    l10n.excelSyncSettings,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ThemeTokens.spacingSm),
            Text(l10n.excelSyncDescription),
            SizedBox(height: ThemeTokens.spacingMd),

            // Toggle Switch
            SwitchListTile(
              title: Text(l10n.enableExcelSync),
              value: isExcelSyncEnabled,
              onChanged: isConnected && onToggle != null 
                  ? (val) => onToggle!(val) 
                  : null,
              contentPadding: EdgeInsets.zero,
            ),

            // Frequency Picker
            if (isExcelSyncEnabled) ...[
              const Divider(),
              ListTile(
                title: Text(l10n.syncFrequency),
                subtitle: Text(l10n.everyDays("$excelSyncFrequencyDays")), 
                trailing: const Icon(Icons.edit),
                contentPadding: EdgeInsets.zero,
                onTap: isConnected ? onFrequencyChange : null,
                enabled: isConnected,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
