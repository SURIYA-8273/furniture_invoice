import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/invoice_entity.dart';

class EditPaymentSummaryCard extends StatelessWidget {
  final InvoiceEntity invoice;

  const EditPaymentSummaryCard({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              _buildSummaryRow(
                context,
                l10n.grandTotal.toUpperCase(),
                currencyFormat.format(invoice.grandTotal),
                isBold: true,
                fontSize: 20,
                color: theme.brightness == Brightness.light ? Colors.black : Colors.white,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                context,
                l10n.paidAmount.toUpperCase(),
                currencyFormat.format(invoice.paidAmount),
                color: ThemeTokens.successColor,
                isBold: true,
                fontSize: 18,
              ),
              const SizedBox(height: 8),
              _buildSummaryRow(
                context,
                l10n.remainingBalance.toUpperCase(),
                currencyFormat.format(invoice.balanceAmount),
                color: ThemeTokens.errorColor,
                isBold: true,
                fontSize: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isBold = false, Color? color, double fontSize = 14}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          color: theme.brightness == Brightness.light ? Colors.black : Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 0.5,
        )),
        Text(value, style: TextStyle(
          color: color ?? theme.textTheme.bodyMedium?.color,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize,
        )),
      ],
    );
  }
}
