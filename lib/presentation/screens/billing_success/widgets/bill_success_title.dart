import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class BillSuccessTitle extends StatelessWidget {
  final String invoiceNumber;

  const BillSuccessTitle({
    super.key,
    required this.invoiceNumber,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // split invoice number logic was in the original file: provider.invoiceNumber.split('-').last
    final shortInvoiceNumber = invoiceNumber.split('-').last;

    return Column(
      children: [
        Text(
          l10n.billSavedSuccessfully,
          style: TextStyle(
              fontSize: ThemeTokens.fontSizeHeadingSmall,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${l10n.billNumberPrefix}$shortInvoiceNumber • ${l10n.today.toUpperCase()}, ${TimeOfDay.now().format(context)}',
          style: TextStyle(
              fontSize: 14,
              color: theme.hintColor,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
