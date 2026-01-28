import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/invoice_entity.dart';

class InvoicePreviewFooter extends StatelessWidget {
  final InvoiceEntity invoice;

  const InvoicePreviewFooter({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      child: Column(
        children: [
          _buildTotalRow(context, l10n.totalAmount, invoice.grandTotal),
          const SizedBox(height: 6),
          _buildTotalRow(context, l10n.advancePaid, -invoice.paidAmount, isGreen: true),
          const SizedBox(height: 6),
                  _buildTotalRow(context, l10n.balanceDueUpper, invoice.balanceAmount),
          const SizedBox(height: 6),
         
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String label, double amount, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Spacer(flex: 2), // Push to right (reduced flex)
        Expanded(
          flex: 3, // Give more space to the content
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Flexible( // Allow text to wrap/shrink
                 child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle long text
                 ),
               ),
               const SizedBox(width: 8), // Minimal spacing
              Text(
                '${isGreen ? '-' : ''}₹${NumberFormat('#,##0.00').format(amount.abs())}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isGreen ? ThemeTokens.successColor : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
