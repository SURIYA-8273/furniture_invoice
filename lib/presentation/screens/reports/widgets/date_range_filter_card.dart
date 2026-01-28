import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class DateRangeFilterCard extends StatelessWidget {
  final String selectedPeriod;
  final DateTimeRange? selectedDateRange;
  final Function(String) onPeriodChanged;
  final VoidCallback onCustomDateSelected;

  const DateRangeFilterCard({
    super.key,
    required this.selectedPeriod,
    required this.selectedDateRange,
    required this.onPeriodChanged,
    required this.onCustomDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(ThemeTokens.spacingMd),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.dateRange.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.textTheme.labelMedium?.color?.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          SizedBox(height: ThemeTokens.spacingMd),
          Wrap(
            spacing: ThemeTokens.spacingSm,
            runSpacing: ThemeTokens.spacingSm,
            children: [
              _buildPeriodChip('today', l10n.today, theme),
              _buildPeriodChip('week', l10n.thisWeek, theme),
              _buildPeriodChip('month', l10n.thisMonth, theme),
              FilterChip(
                label: Text(selectedPeriod == 'custom' && selectedDateRange != null
                    ? '${DateFormat('dd/MM').format(selectedDateRange!.start)} - ${DateFormat('dd/MM').format(selectedDateRange!.end)}'
                    : l10n.custom),
                selected: selectedPeriod == 'custom',
                onSelected: (selected) => onCustomDateSelected(),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                selectedColor: theme.colorScheme.primaryContainer,
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: TextStyle(
                  color: selectedPeriod == 'custom' ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                  fontWeight: selectedPeriod == 'custom' ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selectedPeriod == 'custom' ? theme.colorScheme.primary.withValues(alpha: 0.5) : Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period, String label, ThemeData theme) {
    final isSelected = selectedPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onPeriodChanged(period);
      },
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.5) : Colors.transparent,
        ),
      ),
    );
  }
}
