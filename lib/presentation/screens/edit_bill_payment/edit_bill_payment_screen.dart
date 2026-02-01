import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/invoice_entity.dart';
import '../../../../domain/entities/payment_history_entity.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/payment_history_provider.dart';
import 'package:uuid/uuid.dart';
import '../invoice_preview/invoice_preview_screen.dart';
import '../../widgets/invoice_items_table.dart';
import 'widgets/edit_payment_summary_card.dart';
import 'widgets/payment_history_list.dart';
import 'widgets/payment_update_button.dart';
import '../../widgets/custom_dialog.dart';

class EditBillPaymentScreen extends StatefulWidget {
  final InvoiceEntity invoice;

  const EditBillPaymentScreen({super.key, required this.invoice});

  @override
  State<EditBillPaymentScreen> createState() => _EditBillPaymentScreenState();
}

class _EditBillPaymentScreenState extends State<EditBillPaymentScreen> {
  late InvoiceEntity _currentInvoice;
  late TextEditingController _paymentController;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice;
    _paymentController = TextEditingController(text: "0");
    
    // Load payment history for this invoice
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentHistoryProvider>().loadPayments(_currentInvoice.id);
    });
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final double paymentAmount = double.tryParse(_paymentController.text) ?? 0.0;
    final l10n = AppLocalizations.of(context)!;
    
    if (paymentAmount <= 0 && paymentAmount == 0) {
      // If no new payment, maybe just updating bill items?
      // For now, let's assume we always want to save the invoice state.
    }

    try {
      final invoiceProvider = context.read<InvoiceProvider>();
      final paymentProvider = context.read<PaymentHistoryProvider>();

      final updatedPaidAmount = _currentInvoice.paidAmount + paymentAmount;
      final updatedBalance = _currentInvoice.grandTotal - updatedPaidAmount;
      final updatedStatus = InvoiceEntity.determineStatus(_currentInvoice.grandTotal, updatedPaidAmount);

      final updatedInvoice = _currentInvoice.copyWith(
        paidAmount: updatedPaidAmount,
        balanceAmount: updatedBalance,
        status: updatedStatus,
        updatedAt: DateTime.now(),
      );

      // 1. Update Invoice
      await invoiceProvider.updateInvoice(updatedInvoice);

      // 2. Add Payment Record if amount > 0
      if (paymentAmount > 0) {
        final paymentRecord = PaymentHistoryEntity(
          id: const Uuid().v4(),
          invoiceId: _currentInvoice.id,
          paymentDate: DateTime.now(),
          paidAmount: paymentAmount,
          paymentMode: "cash", // Default or could be a selector
          previousDue: _currentInvoice.balanceAmount,
          remainingDue: updatedBalance,
          createdAt: DateTime.now(),
          notes: l10n.paymentHistoryNote(_currentInvoice.invoiceNumber),
        );
        await paymentProvider.recordPayment(paymentRecord);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.paymentUpdatedSuccessfully)),
        );
        // Navigate to Preview with updated invoice
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InvoicePreviewScreen(invoice: updatedInvoice),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: theme.colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.editBillAndPayment, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.primaryColor, 
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 4,
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: InvoiceItemsTable(items: _currentInvoice.items),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                children: [
                  EditPaymentSummaryCard(invoice: _currentInvoice),
                  const SizedBox(height: 10),
                  const Expanded(
                    child: PaymentHistoryList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PaymentUpdateButton(
        onPressed: () => _showPaymentDialog(context, l10n),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, AppLocalizations l10n) {
    _paymentController.clear();
    final formKey = GlobalKey<_PaymentInputFormState>();

    CustomDialog.show(
      context,
      title: l10n.enterPaymentAmount,
      content: _PaymentInputForm(
        key: formKey,
        controller: _paymentController,
        balanceAmount: _currentInvoice.balanceAmount,
      ),
      primaryActionLabel: l10n.save,
      secondaryActionLabel: l10n.cancel,
      onPrimaryAction: () {
        if (formKey.currentState?.validate() ?? false) {
          Navigator.pop(context);
          _handleSave();
        }
      },
      onSecondaryAction: () => Navigator.pop(context),
    );
  }
}

class _PaymentInputForm extends StatefulWidget {
  final TextEditingController controller;
  final double balanceAmount;

  const _PaymentInputForm({
    super.key,
    required this.controller,
    required this.balanceAmount,
  });

  @override
  State<_PaymentInputForm> createState() => _PaymentInputFormState();
}

class _PaymentInputFormState extends State<_PaymentInputForm> {
  String? _errorText;

  bool validate() {
    final l10n = AppLocalizations.of(context)!;
    final val = double.tryParse(widget.controller.text) ?? 0.0;
    
    if (val > widget.balanceAmount) {
      setState(() {
        _errorText = l10n.maxPaymentError(widget.balanceAmount.toStringAsFixed(2));
      });
      return false;
    }
    
    setState(() {
      _errorText = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      autofocus: true,
      decoration: InputDecoration(
        prefixText: '₹ ',
        hintText: '0.00',
        errorText: _errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall)),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey[800] 
            : Colors.grey[50],
      ),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      onChanged: (_) {
        if (_errorText != null) {
          setState(() => _errorText = null);
        }
      },
    );
  }
}

