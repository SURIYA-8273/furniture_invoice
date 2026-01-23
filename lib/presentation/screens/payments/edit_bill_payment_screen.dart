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
        title: const Text('Edit Bill & Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: ThemeTokens.primaryColor),
            onPressed: _handleSave,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemsTable(),
                  // Action buttons removed as per request
                  const Divider(height: 1),
                  _buildSummarySection(currencyFormat),
                ],
              ),
            ),
          ),
          _buildFooterButton(),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(30),
          1: FlexColumnWidth(4),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1.5),
          5: FlexColumnWidth(1.5),
          6: FlexColumnWidth(2),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey[200]!),
          verticalInside: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
        children: [
          _buildTableHeader(),
          ..._currentInvoice.items.map((item) => _buildTableRow(item)).toList(),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.black);
    return const TableRow(
      children: [
    
        TableCell(child: Center(child: Text('DESCRIPTION (H X W)', style: headerStyle))),
        TableCell(child: Center(child: Text('L', style: headerStyle))),
        TableCell(child: Center(child: Text('QTY', style: headerStyle))),
        TableCell(child: Center(child: Text('RATE', style: headerStyle))),
        TableCell(child: Center(child: Text('TOTAL L', style: headerStyle))),
        TableCell(child: Center(child: Text('TOTAL', style: headerStyle))),
      ],
    );
  }

  TableRow _buildTableRow(InvoiceItemEntity item) {
    const cellStyle = TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500);
    return TableRow(
      children: [
        
        TableCell(
          child: Container(
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 4),
            child: Text(item.productName, style: cellStyle),
          ),
        ),
        TableCell(
          child: Center(child: Text(item.squareFeet.toStringAsFixed(1), style: cellStyle)),
        ),
        TableCell(
          child: Center(child: Text(item.quantity.toString(), style: cellStyle)),
        ),
        TableCell(
          child: Center(child: Text(item.mrp.toStringAsFixed(2), style: cellStyle)),
        ),
        TableCell(
          child: Center(child: Text(item.totalQuantity.toStringAsFixed(1), style: cellStyle)),
        ),
        TableCell(
          child: Center(child: Text(item.totalAmount.toStringAsFixed(2), style: cellStyle)),
        ),
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
            currencyFormat.format(_currentInvoice.balanceAmount - (double.tryParse(_paymentController.text) ?? 0)), 
            color: Colors.red[400], isBold: true, fontSize: 16),
             const SizedBox(height: 12),
          _buildPaymentHistory(),
          const SizedBox(height: 20),
          _buildNewPaymentInput(currencyFormat),
         

          
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

  Widget _buildNewPaymentInput(NumberFormat currencyFormat) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1F0FF)),
      ),
      child: Column(
        children: [
          const Text('ENTER NEW PAYMENT', style: TextStyle(color: ThemeTokens.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('\$', style: TextStyle(color: ThemeTokens.primaryColor, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _paymentController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: ThemeTokens.primaryColor, fontSize: 40, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    setState(() {}); // Trigger rebuild to update Remaining Balance
                  },
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeTokens.primaryColor,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: const Text('Update Payment & Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
