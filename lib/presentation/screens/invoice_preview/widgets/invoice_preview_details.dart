import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/invoice_entity.dart';

class InvoicePreviewDetails extends StatelessWidget {
  final InvoiceEntity invoice;

  const InvoicePreviewDetails({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        
          
            Text(
              '${l10n.nameLabel} : ${invoice.customerName ?? '-'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
      
          Text(
            '${l10n.dateLabel} : ${DateFormat('dd-MM-yyyy').format(invoice.invoiceDate)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
