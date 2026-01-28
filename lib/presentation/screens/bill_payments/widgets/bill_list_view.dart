import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/invoice_entity.dart';
import '../../../providers/invoice_provider.dart';
import '../../edit_bill_payment/edit_bill_payment_screen.dart';
import 'invoice_list_item.dart';

class BillListView extends StatelessWidget {
  final List<InvoiceEntity> invoices;
  final Function(InvoiceEntity) onDelete;

  const BillListView({
    super.key,
    required this.invoices,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<InvoiceProvider>(); // Watch for deletingInvoiceId changes

    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: theme.hintColor.withValues(alpha: 0.3)),
            const SizedBox(height: ThemeTokens.spacingMd),
            Text(
              l10n.noInvoicesFound,
              style: TextStyle(color: theme.hintColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: ThemeTokens.spacingSm, bottom: ThemeTokens.spacingMd),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return InvoiceListItem(
          invoice: invoice,
          isDeleting: provider.deletingInvoiceId == invoice.id,
          onTap: () async {
            final provider = context.read<InvoiceProvider>();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditBillPaymentScreen(invoice: invoice),
              ),
            );
            provider.loadInvoices();
          },
          onDelete: () => onDelete(invoice),
        );
      },
    );
  }
}
