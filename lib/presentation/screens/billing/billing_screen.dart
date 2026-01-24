import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/calculation_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/billing_calculation_provider.dart';
import '../../../domain/entities/invoice_item_entity.dart';
import '../../../domain/entities/invoice_entity.dart';
import '../../providers/invoice_provider.dart';
import '../invoices/invoice_preview_screen.dart';
import 'bill_success_screen.dart';
import 'package:uuid/uuid.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BillingCalculationProvider>();
      provider.generateInvoiceNumber();
      _paidAmountController.text = provider.advancePayment.toInt().toString();
    });
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  void _setPaymentStatus(String status) {
    final provider = context.read<BillingCalculationProvider>();
    if (status == 'PAID') {
      provider.setAdvancePayment(provider.grandTotal);
      _paidAmountController.text = provider.grandTotal.toInt().toString();
    } else if (status == 'PENDING') {
      provider.setAdvancePayment(0);
      _paidAmountController.text = '0';
    } else if (status == 'PARTIAL') {
      // Keep current or clear? User likely wants to type.
      // Focus could be handled if we had a FocusNode.
    }
  }


  void _addItem() {
    context.read<BillingCalculationProvider>().addItem(
          productName: '',
          type: InvoiceItemType.measurement,
          mrp: 0.0,
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





  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<BillingCalculationProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(
        title: Text(
          'BILL #${provider.invoiceNumber.isEmpty ? "..." : provider.invoiceNumber.split('-').last}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            tooltip: 'Add Measurement',
            onPressed: () => _addItem(),
          ),

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
                    // Items Table Header
                    _buildTableHeader(theme),
                    
                    // Items List
                    _buildItemsList(provider, theme),
                  ],
                ),
              ),
            ),
            
            // Enhanced Payment Footer (Matching requested design)
            Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. Grand Total Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GRAND TOTAL',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          CalculationUtils.formatCurrency(provider.grandTotal),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
  
                    // 2. Paid Amount & Balance Due Row
                    Row(
                      children: [
                        // Paid Amount Box
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PAID AMOUNT',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Text('₹', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: TextField(
                                        controller: _paidAmountController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (val) {
                                          final amount = double.tryParse(val) ?? 0.0;
                                          provider.setAdvancePayment(amount);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Balance Due Box
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50, // Pinkish tint as in image
                              border: Border.all(color: Colors.red.shade100),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BALANCE DUE',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.red[400],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CalculationUtils.formatCurrency(provider.balanceDue),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
              
                    const SizedBox(height: 10),
  
                    // 4. Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveBilling,
                        icon: const Icon(Icons.receipt_long, size: 16),
                        label: const Text('SAVE BILLING'),
                        style: ElevatedButton.styleFrom(
                          // backgroundColor: Colors.black, // Inherit blue
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          elevation: 8,
                          shadowColor: Colors.black45,
                          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String label, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () => _setPaymentStatus(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue.shade700 : Colors.black,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  




  Widget _buildTableHeader(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
           bottom: BorderSide(color: Colors.grey.shade300),
           top: BorderSide(color: Colors.grey.shade300), // Optional top border for symmetry
        ),
      ),
      child: IntrinsicHeight( // Ensures all cells stretch to max height for vertical lines
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                 decoration: BoxDecoration(
                   border: Border(right: BorderSide(color: Colors.grey.shade300)),
                 ),
                child: Text(
                  'DESC',
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.grey[700]),
                ),
              ),
            ),
            _buildHeaderCell(theme, 'LENGTH', flex: 1, showRightBorder: true),
            _buildHeaderCell(theme, 'QTY', flex: 1, showRightBorder: true),
            _buildHeaderCell(theme, 'TOTAL LENGTH', flex: 1, showRightBorder: true),
            _buildHeaderCell(theme, 'RATE', flex: 1, showRightBorder: true),
            _buildHeaderCell(theme, 'TOTAL', flex: 2, align: TextAlign.right, showRightBorder: false),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(ThemeData theme, String text, {int flex = 1, TextAlign align = TextAlign.center, bool showRightBorder = true}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: showRightBorder ? BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ) : null,
        alignment: align == TextAlign.right ? Alignment.centerRight : (align == TextAlign.left ? Alignment.centerLeft : Alignment.center),
        child: Text(
          text,
          textAlign: align,
           style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildItemsList(BillingCalculationProvider provider, ThemeData theme) {
    if (provider.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: Text("No items added", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey))),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: provider.items.length,
      separatorBuilder: (ctx, i) => const Divider(height: 1, thickness: 1),
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return Dismissible(
          key: ValueKey(item.id), 
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            provider.removeItem(index);
          },
          child: _EditableBillingRow(
            key: ValueKey(item.id), // Important for focus stability
            item: item,
            index: index,
            provider: provider,
          ),
        );
      },
    );
  }

}

class _EditableBillingRow extends StatefulWidget {
  final InvoiceItemEntity item;
  final int index;
  final BillingCalculationProvider provider;

  const _EditableBillingRow({
    super.key, 
    required this.item, 
    required this.index,
    required this.provider,
  });

  @override
  State<_EditableBillingRow> createState() => _EditableBillingRowState();
}

class _EditableBillingRowState extends State<_EditableBillingRow> {
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _sqFtController;
  late TextEditingController _qtyController;
  late TextEditingController _totQtyController;
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(_EditableBillingRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item != oldWidget.item) {
       _updateControllersIfExternalChange();
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.item.productName);
    
    final sizeParts = _parseSize(widget.item.size);
    _widthController = TextEditingController(text: sizeParts[0]);
    _heightController = TextEditingController(text: sizeParts[1]);
    
    _sqFtController = TextEditingController(text: widget.item.squareFeet == 0 ? '' : widget.item.squareFeet.toStringAsFixed(2));
    _qtyController = TextEditingController(text: widget.item.quantity == 0 ? '' : widget.item.quantity.toString());
    _totQtyController = TextEditingController(text: widget.item.totalQuantity == 0 ? '' : widget.item.totalQuantity.toStringAsFixed(2));
    _rateController = TextEditingController(text: widget.item.mrp == 0 ? '' : widget.item.mrp.toInt().toString());
  }

  List<String> _parseSize(String size) {
    if (size.toLowerCase().contains('x')) {
      final parts = size.toLowerCase().split('x');
      if (parts.length >= 2) {
        return [parts[0].trim(), parts[1].trim()];
      }
    }
    return [size, '']; // Fallback: put everything in width if no 'x'
  }

  void _updateControllersIfExternalChange() {
    if (_nameController.text != widget.item.productName) {
      _nameController.text = widget.item.productName;
    }
    
    // Check if composed size differs
    final currentSize = _composeSize();
    if (currentSize != widget.item.size) {
       final parts = _parseSize(widget.item.size);
       if (_widthController.text != parts[0]) _widthController.text = parts[0];
       if (_heightController.text != parts[1]) _heightController.text = parts[1];
    }
    
    _updateNumericController(_sqFtController, widget.item.squareFeet);
    final newQtyStr = widget.item.quantity == 0 ? '' : widget.item.quantity.toString();
    if (_qtyController.text != newQtyStr) {
       _qtyController.text = newQtyStr;
    }
    _updateNumericController(_totQtyController, widget.item.totalQuantity);
    _updateNumericController(_rateController, widget.item.mrp);
  }
  
  String _composeSize() {
    final w = _widthController.text.trim();
    final h = _heightController.text.trim();
    if (w.isEmpty && h.isEmpty) return '';
    if (h.isEmpty) return w; // Just width (or service name?)
    return '$w x $h';
  }

  void _onSizeChanged() {
    widget.provider.updateItemField(widget.index, size: _composeSize());
  }

  void _updateNumericController(TextEditingController controller, double value) {
     final current = double.tryParse(controller.text) ?? 0.0;
     // If value is 0 (or effective 0), text should be empty.
     // Special case for quantity: if value is 1, text should be empty (default). 
     // Wait, generic update might not know it's quantity. 
     // But quantity is int, passed as double here.
     // Actually, let's keep it simple: if value is 0, text is empty.
     // For Quantity, if default is 1, we might need special handling or just accept 1 showing up if we don't clear it.
     // But initialize handles start. Update handles changes. 
     // If I intentionally set Qty to 1, should it clear? The user said "remove default value". 
     // So if the value effectively matches the "empty" state, clear it.
     
     if ((current - value).abs() > 0.001) {
       // If value is 0, set to empty
       if (value.abs() < 0.001) {
         if (controller.text.isNotEmpty) controller.text = '';
       } else {
         controller.text = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
       }
     }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _sqFtController.dispose();
    _qtyController.dispose();
    _totQtyController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      // Removed generic padding, moving padding to cells
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Col 1: DESC (Name + Size) - Editable
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey.shade300)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.black, width: 1),
                        ),
                        hintText: 'Item Name',
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: null,
                      onChanged: (val) => widget.provider.updateItemField(widget.index, productName: val),
                    ),
                    if (widget.item.type == InvoiceItemType.measurement) ...[
                      const SizedBox(height: 4),
                      // Split Size Inputs
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _widthController,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(color: Colors.black, width: 1),
                                ),
                                hintText: 'W',
                                hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
                               onChanged: (_) => _onSizeChanged(),
                            ),
                          ),
                          const Text(' x ', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: TextField(
                              controller: _heightController,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(color: Colors.black, width: 1),
                                ),
                                hintText: 'H',
                                hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey),
                              onChanged: (_) => _onSizeChanged(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Col 2: SQ.FT - Editable (Disable for Direct)
            Expanded(
              flex: 1,
              child: _buildCellWithBorder(
                child: widget.item.type == InvoiceItemType.measurement 
                  ? _buildSmallTextField(
                      controller: _sqFtController, 
                      hintText: '0',
                      enabled: widget.item.totalQuantity <= 0.001 || widget.item.squareFeet > 0.001,
                      onChanged: (val) {
                         final v = double.tryParse(val);
                         if (v != null) widget.provider.updateItemField(widget.index, squareFeet: v);
                      }
                    ) 
                  : const Center(child: Text('-', style: TextStyle(color: Colors.grey))),
              ),
            ),
  
            // Col 3: QTY - Editable (Disable for Direct)
            Expanded(
              flex: 1,
              child: _buildCellWithBorder(
                child: widget.item.type == InvoiceItemType.measurement
                  ? _buildSmallTextField(
                      controller: _qtyController, 
                      hintText: '0',
                      enabled: widget.item.totalQuantity <= 0.001 || widget.item.squareFeet > 0.001,
                      onChanged: (val) {
                         final v = int.tryParse(val);
                         if (v != null) widget.provider.updateItemField(widget.index, quantity: v);
                      }
                    )
                  : const Center(child: Text('-', style: TextStyle(color: Colors.grey))),
              ),
            ),
  
            // Col 4: TOT.QTY - Editable
            Expanded(
              flex: 1,
              child: _buildCellWithBorder(
                child: _buildSmallTextField(
                  controller: _totQtyController, 
                  hintText: '0',
                  enabled: widget.item.squareFeet <= 0.001,
                  onChanged: (val) {
                     final v = double.tryParse(val);
                     if (v != null) widget.provider.updateItemField(widget.index, totalQuantity: v);
                  }
                ),
              ),
            ),
            
            // Col 5: RATE - Editable
            Expanded(
              flex: 1,
              child: _buildCellWithBorder(
                 child: _buildSmallTextField(
                  controller: _rateController, 
                  hintText: '0',
                  onChanged: (val) {
                     final v = double.tryParse(val);
                     if (v != null) widget.provider.updateItemField(widget.index, mrp: v);
                  }
                ),
              ),
            ),
            
            // Col 6: TOTAL - Read Only
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                alignment: Alignment.centerRight,
                child: Text(
                  CalculationUtils.formatCurrency(widget.item.totalAmount).replaceAll('₹', ''), 
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCellWithBorder({required Widget child, bool showRightBorder = true}) {
    return Container(
      decoration: showRightBorder ? BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ) : null,
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildSmallTextField({
    required TextEditingController controller, 
    required Function(String) onChanged,
    bool enabled = true,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLines: null, // Allow wrapping
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(4),
             borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(4),
             borderSide: const BorderSide(color: Colors.blue, width: 2), // Focus color matching image
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 13,
          color: enabled ? Colors.black : Colors.grey,
        ),
        onChanged: onChanged,
        enabled: enabled,
      ),
    );
  }
  


}


