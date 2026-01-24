import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../domain/entities/invoice_entity.dart';
import '../../../../domain/entities/invoice_item_entity.dart';
import '../../../../domain/entities/payment_history_entity.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/payment_history_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/calculation_utils.dart';

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
          paymentMode: "Cash", // Default or could be a selector
          previousDue: _currentInvoice.balanceAmount,
          remainingDue: updatedBalance,
          createdAt: DateTime.now(),
          notes: "Payment for Invoice #${_currentInvoice.invoiceNumber}",
        );
        await paymentProvider.recordPayment(paymentRecord);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment updated and saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Bill & Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        // Remove local overrides to inherit AppTheme (Blue) except for specific foreground needs if theme is not set perfectly everywhere yet.
        // Assuming AppTheme sets AppBar color to blue. If not, I'll set it here to match other screens.
        // The user specifically asked for "add a app bar blue theme"
        backgroundColor: Colors.blue, 
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
         
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemsTable(),
                  const Divider(height: 1),
                  _buildSummarySection(currencyFormat),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildFooterButton(),
    );
  }

  Widget _buildItemsTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        // borderRadius: BorderRadius.circular(8), // Optional rounded corners
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3), // Description
          1: FlexColumnWidth(1), // Length
          2: FlexColumnWidth(1), // Qty
          3: FlexColumnWidth(1.2), // Rate
          4: FlexColumnWidth(1.2), // Total Len
          5: FlexColumnWidth(1.5), // Total
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200),
          verticalInside: BorderSide(color: Colors.grey.shade200),
        ),
        children: [
          _buildTableHeader(),
          ..._currentInvoice.items.map((item) => _buildTableRow(item)).toList(),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light grey header background
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      children: [
        _buildHeaderCell('DESCRIPTION'),
        _buildHeaderCell('LEN'),
        _buildHeaderCell('QTY'),
        _buildHeaderCell('RATE'),
        _buildHeaderCell('TOT.LEN'),
        _buildHeaderCell('TOTAL'),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
             fontWeight: FontWeight.bold, // Bolder
             fontSize: 10,
             color: Colors.grey.shade800,
             letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  TableRow _buildTableRow(InvoiceItemEntity item) {
    const cellStyle = TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.w500);
    
    // Helper for cells
    Widget buildCell(String text, {double top = 12, double bottom = 12}) => TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: EdgeInsets.only(top: top, bottom: bottom, left: 4, right: 4),
        child: Center(child: Text(text, style: cellStyle, textAlign: TextAlign.center)),
      ),
    );

    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.only(left: 8, top: 12, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item.productName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                if (item.size.isNotEmpty)
                  Text(item.size, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
              ],
            ),
          ),
        ),
        buildCell(item.squareFeet == 0 ? '-' : item.squareFeet.toStringAsFixed(1)),
        buildCell(item.quantity == 0 ? '-' : item.quantity.toString()),
        buildCell('₹${item.mrp.toStringAsFixed(0)}'), // Removed decimal for rate to save space if needed, or keep .00
        buildCell(item.totalQuantity == 0 ? '-' : item.totalQuantity.toStringAsFixed(1)),
        buildCell(CalculationUtils.formatCurrency(item.totalAmount).replaceAll('₹', '')),
      ],
    );
  }



  Widget _buildSummarySection(NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSummaryRow('GRAND TOTAL', currencyFormat.format(_currentInvoice.grandTotal), isBold: true, fontSize: 18, color: Colors.black),
          const SizedBox(height: 4),
          _buildSummaryRow('PAID AMOUNT', currencyFormat.format(_currentInvoice.paidAmount), color: Colors.green[800], isBold: true, fontSize: 16),
          const SizedBox(height: 4),
          _buildSummaryRow('REMAINING BALANCE', 
            currencyFormat.format(_currentInvoice.balanceAmount), 
            color: Colors.red[400], isBold: true, fontSize: 16),
             const SizedBox(height: 12),
          _buildPaymentHistory(),
          const SizedBox(height: 20),
          // New Payment Input removed as per request
          
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        )),
        Text(value, style: TextStyle(
          color: color ?? Colors.black,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize,
        )),
      ],
    );
  }

  Widget _buildPaymentHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PAYMENT HISTORY', style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
            Icon(Icons.history, size: 14, color: Colors.grey[400]),
          ],
        ),
        const SizedBox(height: 8),
        Consumer<PaymentHistoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
            }
            // In a real app, we'd filter provider.payments by current invoice ID if available
            // For now, let's show the most recent payments for this customer
            final payments = provider.payments.toList();
            if (payments.isEmpty) {
              return Text('No previous payments', style: TextStyle(color: Colors.grey[400], fontSize: 12));
            }
            return Column(
              children: payments.map((p) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.payment, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMM yyyy').format(p.paymentDate),
                            style: const TextStyle(
                              color: Colors.black87, 
                              fontSize: 13,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '\$${p.paidAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 14,
                          color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }



  void _showPaymentDialog(BuildContext context) {
    _paymentController.clear(); // Clear previous value
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter Payment Amount', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _paymentController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: '0.00',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
               _handleSave(); // Proceed with save using the controller value
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeTokens.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatusChip('PAID', isSelected: _currentInvoice.status == 'paid', color: Colors.green),
        const SizedBox(width: 8),
        _buildStatusChip('PARTIAL', isSelected: _currentInvoice.status == 'partially_paid', color: Colors.orange),
        const SizedBox(width: 8),
        _buildStatusChip('PENDING', isSelected: _currentInvoice.status == 'pending', color: Colors.grey),
      ],
    );
  }

  Widget _buildStatusChip(String label, {required bool isSelected, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? (color?.withOpacity(0.15) ?? Colors.grey[100]) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(
        color: isSelected ? (color ?? Colors.grey[600]) : Colors.grey[300],
        fontSize: 10,
        fontWeight: FontWeight.bold,
      )),
    );
  }



  Widget _buildFooterButton() {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () => _showPaymentDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeTokens.primaryColor,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          child: const Text('Update Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}
