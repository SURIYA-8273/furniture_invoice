import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/billing_calculation_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../../../domain/entities/invoice_item_entity.dart';
import '../billing_success/bill_success_screen.dart';
import 'widgets/billing_items_list.dart';
import 'widgets/billing_payment_footer.dart';
import 'widgets/billing_table_header.dart'; 

/// Enhanced Billing Screen: Single page invoice creation with payment details.
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _paidAmountController;

  @override
  void initState() {
    super.initState();
    _paidAmountController = TextEditingController();
    
    // Generate invoice number on init
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final invoiceProvider = context.read<InvoiceProvider>();
      final billingProvider = context.read<BillingCalculationProvider>();
      
      final nextNumber = await invoiceProvider.getNextInvoiceNumber();
      billingProvider.generateInvoiceNumber(nextNumber: nextNumber);
      
      _paidAmountController.text = billingProvider.advancePayment.toInt().toString();
    });
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  void _addItem() {
    context.read<BillingCalculationProvider>().addItem(
          productName: '',
          type: InvoiceItemType.measurement,
          rate: 0.0,
          quantity: 0,
        );
  }

  void _saveBilling() {
    final provider = context.read<BillingCalculationProvider>();
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!provider.hasItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.itemsRequired)),
      );
      return;
    }

    // Navigate to Success Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BillSuccessScreen(),
      ),
    );
  }

  Future<void> _showClearConfirmationDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllDataQuestion),
        content: Text(l10n.clearAllDataWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.clearAllAction.toUpperCase()),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<BillingCalculationProvider>();
      provider.clear();
      _paidAmountController.text = '0';
      
      final invoiceProvider = context.read<InvoiceProvider>();
      final nextNumber = await invoiceProvider.getNextInvoiceNumber();
      provider.generateInvoiceNumber(nextNumber: nextNumber);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.allDataCleared)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<BillingCalculationProvider>();
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
           // Clear data when leaving the screen
           WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                 context.read<BillingCalculationProvider>().clear();
              }
           });
        }
      },
      child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${l10n.billNumberPrefix}${provider.invoiceNumber.isEmpty ? "..." : provider.invoiceNumber.split('-').last}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            tooltip: l10n.clearAll,
            onPressed: () => _showClearConfirmationDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        border: Border.all(color: ThemeTokens.invoiceTableBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Items Table Header
                          const BillingTableHeader(),
                          
                          // Items List
                          BillingItemsList(provider: provider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Enhanced Payment Footer (Matching requested design)
            BillingPaymentFooter(
              provider: provider,
              paidAmountController: _paidAmountController,
              onAddItem: _addItem,
              onSave: _saveBilling,
            ),
          ],
        ),
      ),
    ),
  );
}

}
