import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class BillingTableHeader extends StatelessWidget {
  const BillingTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: ThemeTokens.invoiceTableHeader,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 25,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                 decoration: BoxDecoration(
                   border: Border(right: BorderSide(color: ThemeTokens.invoiceTableBorder)),
                 ),
                child: Text(
                  l10n.descriptionShort.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: ThemeTokens.invoiceHeaderText),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            _buildHeaderCell(context, l10n.lengthShort.toUpperCase(), flex: 10, showRightBorder: true),
            _buildHeaderCell(context, l10n.qtyShort.toUpperCase(), flex: 10, showRightBorder: true),
            _buildHeaderCell(context, l10n.rateShort.toUpperCase(), flex: 12, showRightBorder: true),
            _buildHeaderCell(context, l10n.totalLenShort.toUpperCase(), flex: 12, showRightBorder: true),
          
            _buildHeaderCell(context, l10n.totalShort.toUpperCase(), flex: 15, align: TextAlign.center, showRightBorder: false),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text, {int flex = 1, TextAlign align = TextAlign.center, bool showRightBorder = true}) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        decoration: showRightBorder ? BoxDecoration(
          border: Border(right: BorderSide(color: ThemeTokens.invoiceTableBorder)),
        ) : null,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: align,
           style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: ThemeTokens.invoiceHeaderText),
        ),
      ),
    );
  }
}
