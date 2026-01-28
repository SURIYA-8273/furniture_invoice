import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/billing_calculation_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../../domain/entities/payment_history_entity.dart';
import '../invoice_preview/invoice_preview_screen.dart';
import '../../providers/payment_history_provider.dart';
import 'widgets/bill_success_icon.dart';
import 'widgets/bill_success_title.dart';
import 'widgets/bill_summary_card.dart';
import 'widgets/customer_info_input.dart';

class BillSuccessScreen extends StatefulWidget {
  const BillSuccessScreen({super.key});

  @override
  State<BillSuccessScreen> createState() => _BillSuccessScreenState();
}

class _BillSuccessScreenState extends State<BillSuccessScreen> {
  final TextEditingController _customerNameController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillingCalculationProvider>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // If no items, show empty state instead of popping (safe for rebuilding in stack)
    if (!provider.hasItems) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()), // Or empty container
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        // backgroundColor: Colors.transparent, // Removed to inherit blue theme
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Back icon, white for contrast on blue
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.billGenerated,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // actions: [], // Removed close button from actions
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: ThemeTokens.spacingMd + 4, vertical: ThemeTokens.spacingMd + 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Success Icon
              const BillSuccessIcon(),
              const SizedBox(height: 24),
              
              // 2. Title & Metadata
              BillSuccessTitle(invoiceNumber: provider.invoiceNumber),
              const SizedBox(height: 40),

              // 3. Customer Info Input
              CustomerInfoInput(controller: _customerNameController),
              const SizedBox(height: 24),

              // 4. Bill Summary Card
              BillSummaryCard(
                grandTotal: provider.grandTotal,
                advancePayment: provider.advancePayment,
                balanceDue: provider.balanceDue,
              ),
              
              const SizedBox(height: 40), 

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ThemeTokens.spacingMd),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                   final invoiceProvider = context.read<InvoiceProvider>();
                   final existingInvoice = await invoiceProvider.getInvoiceByNumber(provider.invoiceNumber);
                   
                   InvoiceEntity finalInvoice;

                     if (existingInvoice != null) {
                      // Update existing
                      finalInvoice = existingInvoice.copyWith(
                         customerName: _customerNameController.text.trim().isNotEmpty ? _customerNameController.text.trim() : existingInvoice.customerName,
                         items: List.from(provider.items),
                         grandTotal: provider.grandTotal,
                         paidAmount: provider.advancePayment,
                         balanceAmount: provider.balanceDue,
                         status: InvoiceEntity.determineStatus(provider.grandTotal, provider.advancePayment),
                         invoiceDate: provider.invoiceDate,
                         updatedAt: DateTime.now(),
                      );
                      await invoiceProvider.updateInvoice(finalInvoice);
                    } else {
                      // Create new
                       finalInvoice = InvoiceEntity(
                         id: const Uuid().v4(),
                         invoiceNumber: provider.invoiceNumber,
                         customerName: _customerNameController.text.trim().isNotEmpty ? _customerNameController.text.trim() : null,
                         items: List.from(provider.items),
                         grandTotal: provider.grandTotal,
                         paidAmount: provider.advancePayment,
                         balanceAmount: provider.balanceDue,
                         status: InvoiceEntity.determineStatus(provider.grandTotal, provider.advancePayment),
                         invoiceDate: provider.invoiceDate,
                         createdAt: DateTime.now(),
                         updatedAt: DateTime.now(),
                       );
                       await invoiceProvider.addInvoice(finalInvoice);
                    }
    
                    // Record payment in history if there's an advance payment
                    if (provider.advancePayment > 0) {
                      if (!context.mounted) return;
                      final paymentHistoryProvider = context.read<PaymentHistoryProvider>();
                      final payment = PaymentHistoryEntity(
                        id: const Uuid().v4(),
                        invoiceId: finalInvoice.id,
                        paymentDate: provider.invoiceDate,
                        paidAmount: provider.advancePayment,
                        paymentMode: provider.paymentMethod,
                        previousDue: provider.grandTotal, // At initial billing, previous due is grand total
                        remainingDue: provider.balanceDue,
                        createdAt: DateTime.now(),
                        notes: l10n.initialPaymentNote(finalInvoice.invoiceNumber),
                      );
                      await paymentHistoryProvider.recordPayment(payment);
                    }
                    if (!context.mounted) return;
    
                    // Navigate to Preview
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => InvoicePreviewScreen(
                          invoice: finalInvoice,
                        ),
                      ),
                    );
                     
                     if (!mounted) return;
                     ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(existingInvoice != null ? l10n.invoiceUpdatedSuccessfully : l10n.invoiceGeneratedAndSaved)),
                      );
                } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.failedToSaveInvoiceWithDetail(e.toString()))),
                    );
                }
              },
              icon: const Icon(Icons.description, size: 20),
              label: Text(l10n.confirmAndGenerate),
              style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.black, // Inherit from theme (Blue)
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
