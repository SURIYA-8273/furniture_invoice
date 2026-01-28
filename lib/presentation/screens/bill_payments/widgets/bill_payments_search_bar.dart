import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/invoice_provider.dart';

class BillPaymentsSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const BillPaymentsSearchBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: theme.cardColor,
      padding: EdgeInsets.fromLTRB(ThemeTokens.spacingMd, 0, ThemeTokens.spacingMd, ThemeTokens.spacingMd),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: l10n.searchBillNumber,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: ThemeTokens.spacingMd),
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            context.read<InvoiceProvider>().loadInvoices();
          } else {
            context.read<InvoiceProvider>().searchInvoices(value);
          }
        },
      ),
    );
  }
}
