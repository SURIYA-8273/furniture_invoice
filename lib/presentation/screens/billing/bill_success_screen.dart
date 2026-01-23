import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/calculation_utils.dart';
import '../../providers/billing_calculation_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../invoices/invoice_preview_screen.dart';

class BillSuccessScreen extends StatelessWidget {
  const BillSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillingCalculationProvider>();
    final theme = Theme.of(context);

    // If no items, probably shouldn't be here, but just in case
    if (!provider.hasItems) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const SizedBox();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Hide back button
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 24),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 2. Title & Metadata
              const Text(
                'Bill Saved Successfully',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'BILL #${provider.invoiceNumber.split('-').last} • TODAY, ${TimeOfDay.now().format(context)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),

              // 3. Bill Summary Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('BILL SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.0)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text('Edit Items', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text('Total Amount', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 15)),
                         Text(CalculationUtils.formatCurrency(provider.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                       ],
                     ),
                    const SizedBox(height: 16),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text('Advance Paid', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 15)),
                         Text(CalculationUtils.formatCurrency(provider.advancePayment), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                       ],
                     ),
                     const SizedBox(height: 20),
                     const Divider(height: 1),
                     const SizedBox(height: 20),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text('BALANCE DUE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                         Text(CalculationUtils.formatCurrency(provider.balanceDue), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.red)),
                       ],
                     ),
                  ],
                ),
              ),
              
              const Spacer(),

              // 4. Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                         // Construct Invoice Entity
                        final invoice = InvoiceEntity(
                          id: const Uuid().v4(),
                          invoiceNumber: provider.invoiceNumber,
                          items: List.from(provider.items),
                          subtotal: provider.subtotal,
                          discount: provider.discount,
                          gst: provider.gstAmount,
                          grandTotal: provider.grandTotal,
                          paidAmount: provider.advancePayment,
                          balanceAmount: provider.balanceDue,
                          status: InvoiceEntity.determineStatus(provider.grandTotal, provider.advancePayment),
                          invoiceDate: provider.invoiceDate,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        );

                        try {
                           // Save to Repository
                           await context.read<InvoiceProvider>().addInvoice(invoice);

                            if (!context.mounted) return;

                            // Navigate to Preview
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => InvoicePreviewScreen(
                                  invoice: invoice,
                                ),
                              ),
                            );
                             
                             ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invoice Generated & Saved Successfully!')),
                              );
                        } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to save invoice: $e')),
                            );
                        }
                      },
                      icon: const Icon(Icons.description, size: 20),
                      label: const Text('CONFIRM & GENERATE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                       onPressed: () {},
                       icon: const Icon(Icons.share_outlined),
                       padding: const EdgeInsets.all(12),
                       constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                   Navigator.pop(context);
                }, 
                child: Text('PRINT LATER', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.0))
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
