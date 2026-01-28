import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../core/utils/calculation_utils.dart';
import '../../../../l10n/app_localizations.dart';

class BillSummaryCard extends StatelessWidget {
  final double grandTotal;
  final double advancePayment;
  final double balanceDue;

  const BillSummaryCard({
    super.key,
    required this.grandTotal,
    required this.advancePayment,
    required this.balanceDue,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusXLarge),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: EdgeInsets.all(ThemeTokens.spacingLg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.billSummary.toUpperCase(),
                style: TextStyle(
                    fontSize: ThemeTokens.fontSizeLabelMedium,
                    fontWeight: FontWeight.bold,
                    color: theme.hintColor,
                    letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.totalAmountCaps,
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
              Text(
                CalculationUtils.formatCurrency(grandTotal),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.textTheme.bodyLarge?.color),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.advancePaid,
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: ThemeTokens.fontSizeBodyMedium + 1),
              ),
              Text(
                CalculationUtils.formatCurrency(advancePayment),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.balanceDue.toUpperCase(),
                style: TextStyle(
                    fontSize: ThemeTokens.fontSizeTitleSmall - 1,
                    fontWeight: FontWeight.bold,
                    color: theme.hintColor),
              ),
              Text(
                CalculationUtils.formatCurrency(balanceDue),
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
