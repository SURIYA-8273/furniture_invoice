import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/calculation_utils.dart';
import '../../providers/billing_calculation_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../invoices/invoice_preview_screen.dart';

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
    final theme = Theme.of(context);

    // If no items, show empty state instead of popping (safe for rebuilding in stack)
    if (!provider.hasItems) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()), // Or empty container
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        // backgroundColor: Colors.transparent, // Removed to inherit blue theme
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Back icon, white for contrast on blue
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bill Generated',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // actions: [], // Removed close button from actions
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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

              // 3. Customer Info Input
              TextField(
                controller: _customerNameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  hintText: 'Enter customer name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),

              // 4. Bill Summary Card
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
                        // GestureDetector(
                        //   onTap: () => Navigator.pop(context),
                        //   child: Text('Edit Items', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                        // ),
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
              
              const SizedBox(height: 40), 

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                 // Construct Invoice Entity
                final invoice = InvoiceEntity(
                  id: const Uuid().v4(),
                  invoiceNumber: provider.invoiceNumber,
                  customerName: _customerNameController.text.trim().isNotEmpty ? _customerNameController.text.trim() : null,
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
                // backgroundColor: Colors.black, // Inherit from theme (Blue)
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
