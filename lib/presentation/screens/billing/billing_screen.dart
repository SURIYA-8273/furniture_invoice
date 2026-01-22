import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/calculation_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/billing_calculation_provider.dart';
import '../../../domain/entities/invoice_item_entity.dart';
import 'invoice_details_screen.dart';

/// Enhanced Billing Screen with comprehensive invoice details collection
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Generate invoice number on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillingCalculationProvider>().generateInvoiceNumber();
    });
  }


  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (productName, size, mrp, quantity) {
          context.read<BillingCalculationProvider>().addItem(
                productName: productName,
                size: size,
                mrp: mrp,
                quantity: quantity,
              );
        },
      ),
    );
  }



  void _generateInvoice() {
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

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InvoiceDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.billing),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add_circle_outline, size: 28),
            tooltip: l10n.addProduct,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Show confirmation dialog before clearing
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.warning),
                  content: Text(l10n.clearAllConfirmation), 
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        final provider = context.read<BillingCalculationProvider>();
                        provider.clear();
                        provider.generateInvoiceNumber();
                        Navigator.pop(context);
                      },
                      child: Text(l10n.yes, style: TextStyle(color: theme.colorScheme.error)),
                    ),
                  ],
                ),
              );
            },
            tooltip: l10n.clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ThemeTokens.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Items List (Cards)
                    _buildItemsSection(l10n, theme),
                    // Add some functionality padding at bottom if needed
                    SizedBox(height: ThemeTokens.spacingXl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ThemeTokens.spacingMd),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummarySection(l10n, theme),
              SizedBox(height: ThemeTokens.spacingMd),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _generateInvoice,
                  icon: const Icon(Icons.receipt_long),
                  label: Text(
                    l10n.generateInvoice.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildItemsSection(AppLocalizations l10n, ThemeData theme) {
    return Consumer<BillingCalculationProvider>(
      builder: (context, provider, child) {
        if (provider.items.isEmpty) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(ThemeTokens.spacingXl),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 48, color: theme.colorScheme.outline),
                    SizedBox(height: ThemeTokens.spacingMd),
                    Text(l10n.noDataFound, style: theme.textTheme.titleMedium),
                    SizedBox(height: ThemeTokens.spacingSm),
                    Text(l10n.tapToAddItems, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          );
        }

        return _EditableBillingTable(
          items: provider.items,
          onUpdateItem: (index, field, value) {
            switch (field) {
              case 'productName':
                provider.updateItemField(index, productName: value as String);
                break;
              case 'size':
                provider.updateItemField(index, size: value as String);
                break;
              case 'squareFeet':
                provider.updateItemField(index, squareFeet: value as double);
                break;
              case 'quantity':
                provider.updateItemField(index, quantity: value as int);
                break;
              case 'totalQuantity':
                provider.updateItemField(index, totalQuantity: value as double);
                break;
              case 'mrp':
                provider.updateItemField(index, mrp: value as double);
                break;
              case 'totalAmount':
                provider.updateItemField(index, totalAmount: value as double);
                break;
            }
          },
          onDeleteItem: (index) => provider.removeItem(index),
        );
      },
    );
  }



  Widget _buildSummarySection(AppLocalizations l10n, ThemeData theme) {
    return Consumer<BillingCalculationProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items: ${provider.items.length}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Total: ${CalculationUtils.formatCurrency(provider.subtotal)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }


}

class _AddItemDialog extends StatefulWidget {
  final Function(String, String, double, int) onAdd;

  const _AddItemDialog({required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _mrpController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void dispose() {
    _productController.dispose();
    _mrpController.dispose();
    _quantityController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.add),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _productController,
              decoration: InputDecoration(labelText: l10n.productName),
              validator: (v) => v?.isEmpty ?? true ? l10n.validationRequired : null,
            ),
            const SizedBox(height: 16),
            
            // Size Inputs
            Text(l10n.productSize, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    decoration: InputDecoration(
                      labelText: l10n.width,
                      hintText: 'W',
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? l10n.validationRequired : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText: l10n.height,
                      hintText: 'H',
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? l10n.validationRequired : null,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            TextFormField(
              controller: _mrpController,
              decoration: InputDecoration(labelText: l10n.mrp),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? l10n.validationRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: l10n.quantity),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? l10n.validationRequired : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final size = '${_widthController.text.trim()}×${_heightController.text.trim()}';
              widget.onAdd(
                _productController.text,
                size,
                double.parse(_mrpController.text),
                int.parse(_quantityController.text),
              );
              Navigator.pop(context);
            }
          },
          child: Text(l10n.add),
        ),
      ],
    );
  }
}

class _EditableBillingTable extends StatefulWidget {
  final List<InvoiceItemEntity> items;
  final Function(int index, String field, dynamic value) onUpdateItem;
  final Function(int index) onDeleteItem;

  const _EditableBillingTable({
    required this.items,
    required this.onUpdateItem,
    required this.onDeleteItem,
  });

  @override
  State<_EditableBillingTable> createState() => _EditableBillingTableState();
}

class _EditableBillingTableState extends State<_EditableBillingTable> {
  @override

  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.items.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return _EditableItemRow(
          key: ValueKey(widget.items[index].id),
          index: index,
          item: widget.items[index],
          onUpdate: (field, value) => widget.onUpdateItem(index, field, value),
          onDelete: () => widget.onDeleteItem(index),
          isEven: index % 2 == 0,
        );
      },
    );
  }
}

class _EditableItemRow extends StatefulWidget {
  final int index;
  final InvoiceItemEntity item;
  final Function(String, dynamic) onUpdate;
  final VoidCallback onDelete;
  final bool isEven;

  const _EditableItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
    required this.isEven,
  });

  @override
  State<_EditableItemRow> createState() => _EditableItemRowState();
}

class _EditableItemRowState extends State<_EditableItemRow> {
  late TextEditingController _nameController;
  late TextEditingController _sqFtController;
  late TextEditingController _qtyController;
  late TextEditingController _totalQtyController;
  late TextEditingController _mrpController;
  late TextEditingController _amountController;
  
  late TextEditingController _widthController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(_EditableItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item != oldWidget.item) {
      _updateControllersIfChanged();
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.item.productName);
    _sqFtController = TextEditingController(text: widget.item.squareFeet.toStringAsFixed(2));
    _qtyController = TextEditingController(text: widget.item.quantity.toString());
    _totalQtyController = TextEditingController(text: widget.item.totalQuantity.toStringAsFixed(2));
    _mrpController = TextEditingController(text: widget.item.mrp.toStringAsFixed(2));
    _amountController = TextEditingController(text: widget.item.totalAmount.toStringAsFixed(2));
    
    _widthController = TextEditingController();
    _heightController = TextEditingController();
    _parseSize(widget.item.size);
  }
  
  void _parseSize(String size) {
    final parts = size.split(RegExp(r'[xX×]'));
    if (parts.length >= 2) {
      _widthController.text = parts[0].trim();
      _heightController.text = parts[1].trim();
    } else {
      _widthController.text = '';
      _heightController.text = '';
    }
  }

  void _updateControllersIfChanged() {
    if (_nameController.text != widget.item.productName) {
      _nameController.text = widget.item.productName;
    }
    
    // Only update numeric fields if values significantly differ (avoid cursor jumping on minor format changes)
    if (double.tryParse(_sqFtController.text) != widget.item.squareFeet) {
      _sqFtController.text = widget.item.squareFeet.toStringAsFixed(2);
    }
    if (int.tryParse(_qtyController.text) != widget.item.quantity) {
      _qtyController.text = widget.item.quantity.toString();
    }
    if (double.tryParse(_totalQtyController.text) != widget.item.totalQuantity) {
      _totalQtyController.text = widget.item.totalQuantity.toStringAsFixed(2);
    }
    if (double.tryParse(_mrpController.text) != widget.item.mrp) {
      _mrpController.text = widget.item.mrp.toStringAsFixed(2);
    }
    if (double.tryParse(_amountController.text) != widget.item.totalAmount) {
      _amountController.text = widget.item.totalAmount.toStringAsFixed(2);
    }
  }

  void _onSizeChanged() {
    final wText = _widthController.text;
    final hText = _heightController.text;
    final sizeStr = '$wText×$hText';
    widget.onUpdate('size', sizeStr);
    
    final w = double.tryParse(wText);
    final h = double.tryParse(hText);
    if (w != null && h != null) {
      final sqFt = w * h;
      widget.onUpdate('squareFeet', sqFt);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sqFtController.dispose();
    _qtyController.dispose();
    _totalQtyController.dispose();
    _mrpController.dispose();
    _amountController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Row 1: S.No, Name, Delete
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                SizedBox(width: ThemeTokens.spacingSm),
                Expanded(
                  child: _buildLabeledWrapper(
                    label: l10n.productName,
                    child: _buildTextField(
                      controller: _nameController,
                      onChanged: (val) => widget.onUpdate('productName', val),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 20, color: theme.colorScheme.error),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.confirmDelete),
                        content: Text(l10n.deleteItemConfirmation), 
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.onDelete();
                              Navigator.pop(context);
                            },
                            child: Text(l10n.delete, style: TextStyle(color: theme.colorScheme.error)),
                          ),
                        ],
                      ),
                    );
                  },
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Remove',
                ),
              ],
            ),
            const SizedBox(height: 1),
            
            // Row 2: Width, Height, SqFt, Quantity
            Row(
              children: [
                Expanded(
                  child: _buildLabeledWrapper(
                    label: l10n.width,
                    child: _buildTextField(
                      controller: _widthController,
                      isNumeric: true,
                      onChanged: (val) => _onSizeChanged(),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildLabeledWrapper(
                    label: l10n.height,
                    child: _buildTextField(
                      controller: _heightController,
                      isNumeric: true,
                      onChanged: (val) => _onSizeChanged(),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildLabeledWrapper(
                    label: l10n.squareFeet,
                    child: _buildTextField(
                      controller: _sqFtController,
                      isNumeric: true,
                      onChanged: (val) {
                        final d = double.tryParse(val);
                        if (d != null) widget.onUpdate('squareFeet', d);
                      },
                    ),
                  ),
                ),
                 const SizedBox(width: 4),
                Expanded(
                  child: _buildLabeledWrapper(
                    label: l10n.quantity,
                    child: _buildTextField(
                      controller: _qtyController,
                      isNumeric: true,
                      isInteger: true,
                      onChanged: (val) {
                         final i = int.tryParse(val);
                         if (i != null && i >= 0) widget.onUpdate('quantity', i);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),

            // Row 3: TotQty, MRP, Total
            Row(
              children: [
                Expanded(
                  child: _buildLabeledWrapper(
                    label: l10n.totalQuantity,
                    child: _buildTextField(
                      controller: _totalQtyController,
                      isNumeric: true,
                      isReadOnly: false, 
                      onChanged: (val) {
                         final d = double.tryParse(val);
                         if (d != null) widget.onUpdate('totalQuantity', d);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildLabeledWrapper(
                    label: l10n.mrp,
                    child: _buildTextField(
                      controller: _mrpController,
                      isNumeric: true,
                      prefixText: '₹',
                      onChanged: (val) {
                         final d = double.tryParse(val);
                         if (d != null) widget.onUpdate('mrp', d);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1, 
                  child: _buildLabeledWrapper(
                    label: l10n.totalAmount,
                    child: _buildTextField(
                      controller: _amountController,
                      isNumeric: true,
                      prefixText: '₹',
                      fontWeight: FontWeight.bold,
                      fillColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                      isReadOnly: true,
                      onChanged: (val) {
                         // Read-only, do not update
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledWrapper({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        child,
      ],
    );
  }



  Widget _buildTextField({
    required TextEditingController controller,
    required Function(String) onChanged,
    bool isNumeric = false,
    bool isInteger = false,
    bool isReadOnly = false,
    String? hintText,
    String? prefixText,
    Color? fillColor,
    FontWeight? fontWeight,
  }) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        keyboardType: isNumeric 
            ? TextInputType.numberWithOptions(decimal: !isInteger)
            : TextInputType.text,
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: fontWeight,
          // Use a monospaced font if available or default for numbers alignment
           fontFeatures: [const FontFeature.tabularFigures()],
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          isDense: true,
          hintText: hintText,
          prefixText: prefixText,
          prefixStyle: const TextStyle(fontSize: 12),
          filled: fillColor != null,
          fillColor: fillColor,
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
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
