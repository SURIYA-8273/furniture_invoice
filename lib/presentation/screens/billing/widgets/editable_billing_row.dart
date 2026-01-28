import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../core/utils/calculation_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/invoice_item_entity.dart';
import '../../../providers/billing_calculation_provider.dart';
import '../../../providers/description_provider.dart';

class EditableBillingRow extends StatefulWidget {
  final InvoiceItemEntity item;
  final int index;
  final BillingCalculationProvider provider;

  const EditableBillingRow({
    super.key, 
    required this.item, 
    required this.index,
    required this.provider,
  });

  @override
  State<EditableBillingRow> createState() => _EditableBillingRowState();
}

class _EditableBillingRowState extends State<EditableBillingRow> {
  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _lengthController;
  late TextEditingController _qtyController;
  late TextEditingController _totalLengthController;
  late TextEditingController _rateController;
  
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _widthFocus = FocusNode();
  final FocusNode _heightFocus = FocusNode();

  // Description Overlay
  final LayerLink _descLayerLink = LayerLink();
  OverlayEntry? _descOverlayEntry;
  final FocusNode _descFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _widthFocus.addListener(_onFocusChange);
    _heightFocus.addListener(_onFocusChange);
    
    _descFocus.addListener(_onDescFocusChange);
  }

  void _onFocusChange() {
    if (_widthFocus.hasFocus || _heightFocus.hasFocus) {
       _showOverlay();
    } else {
       _removeOverlay();
    }
  }

  void _onDescFocusChange() {
    if (_descFocus.hasFocus) {
      _showDescOverlay();
    } else {
      // Delay removal to allow tap on item
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_descFocus.hasFocus) {
          _removeDescOverlay();
        }
      });
    }
  }
  void _showOverlay() {
    if (_overlayEntry != null) return;
    final uniqueSizes = widget.provider.uniqueSizes;
    if (uniqueSizes.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 150, // Fixed width for dropdown
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 35), // Show below inputs
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: uniqueSizes.length,
                itemBuilder: (context, i) {
                   final size = uniqueSizes[i];
                   return InkWell(
                     onTap: () {
                        final parts = _parseSize(size);
                        _widthController.text = parts[0];
                        _heightController.text = parts[1];
                        _onSizeChanged();
                        _widthFocus.unfocus();
                        _heightFocus.unfocus();
                        _removeOverlay();
                     },
                     child: Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Text(size, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                     ),
                   );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _showDescOverlay() {
    if (_descOverlayEntry != null) return;
    
    // Use read here because we are in a callback/initState logic context where we might not be rebuilding.
    // However, for the overlay content, we want it to react to changes if descriptions load.
    // So inside the builder we use Consumer or watch if we want dynamic updates.
    // But DescriptionProvider loading is async.
    final descriptionProvider = context.read<DescriptionProvider>();
    // Ensure we have fresh data
    if (descriptionProvider.descriptions.isEmpty) {
      descriptionProvider.loadDescriptions();
    }
    
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _descOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 300, // Wider for description
        child: CompositedTransformFollower(
          link: _descLayerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 40), 
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
            child: Consumer<DescriptionProvider>(
              builder: (context, provider, child) {
                final descriptions = provider.descriptions;
                if (descriptions.isEmpty) {
                   return const SizedBox(height: 0); // Hide if empty
                }
                
                // Filter based on text
                final query = _nameController.text.toLowerCase();
                final filtered = descriptions.where((d) => d.text.toLowerCase().contains(query)).toList();
                
                if (filtered.isEmpty) return const SizedBox(height: 0);

                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                       final desc = filtered[i];
                       return InkWell(
                         onTap: () {
                            _nameController.text = desc.text;
                            widget.provider.updateItemField(widget.index, productName: desc.text);
                            _descFocus.unfocus();
                            _removeDescOverlay();
                         },
                         child: Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                           child: Text(desc.text, style: const TextStyle(fontSize: 14)),
                         ),
                       );
                    },
                  ),
                );
              }
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_descOverlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _removeDescOverlay() {
    _descOverlayEntry?.remove();
    _descOverlayEntry = null;
  }

  @override
  void didUpdateWidget(EditableBillingRow oldWidget) {
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
    
    _lengthController = TextEditingController(text: widget.item.length == 0 ? '' : widget.item.length.toStringAsFixed(2));
    _qtyController = TextEditingController(text: widget.item.quantity == 0 ? '' : widget.item.quantity.toString());
    _totalLengthController = TextEditingController(text: widget.item.totalLength == 0 ? '' : widget.item.totalLength.toStringAsFixed(2));
    _rateController = TextEditingController(text: widget.item.rate == 0 ? '' : widget.item.rate.toInt().toString());
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
    
    _updateNumericController(_lengthController, widget.item.length);
    final newQtyStr = widget.item.quantity == 0 ? '' : widget.item.quantity.toString();
    if (_qtyController.text != newQtyStr) {
       _qtyController.text = newQtyStr;
    }
    _updateNumericController(_totalLengthController, widget.item.totalLength);
    _updateNumericController(_rateController, widget.item.rate);
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
    _widthFocus.removeListener(_onFocusChange);
    _heightFocus.removeListener(_onFocusChange);
    _widthFocus.dispose();
    _heightFocus.dispose();
    _removeOverlay();
    
    _descFocus.removeListener(_onDescFocusChange);
    _descFocus.dispose();
    _removeDescOverlay();
    
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _lengthController.dispose();
    _qtyController.dispose();
    _totalLengthController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: widget.index % 2 == 0 
          ? ThemeTokens.getInvoiceRowAlternate(context) 
          : theme.cardColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Col 1: DESC (Name + Size) - Editable
            Expanded(
              flex: 25,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: theme.dividerColor)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CompositedTransformTarget(
                      link: _descLayerLink,
                      child: TextField(
                        controller: _nameController,
                        focusNode: _descFocus,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                             borderSide: BorderSide(color: theme.dividerColor),
                           ),
                           enabledBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(4),
                             borderSide: BorderSide(color: theme.dividerColor),
                           ),
                           focusedBorder: OutlineInputBorder(
                             borderRadius: BorderRadius.circular(4),
                             borderSide: BorderSide(color: theme.primaryColor, width: 1),
                          ),
                          hintText: l10n.itemName,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: null,
                        onChanged: (val) {
                          widget.provider.updateItemField(widget.index, productName: val);
                          // Rebuild overlay to filter
                          _descOverlayEntry?.markNeedsBuild();
                        },
                      ),
                    ),
                    if (widget.item.type == InvoiceItemType.measurement) ...[
                      const SizedBox(height: 4),
                      // Split Size Inputs
                      CompositedTransformTarget(
                        link: _layerLink,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _widthController,
                                focusNode: _widthFocus,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                ],
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: theme.dividerColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: theme.dividerColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: theme.primaryColor, width: 1),
                                  ),
                                  hintText: 'W',
                                  hintStyle: TextStyle(fontSize: 10, color: theme.hintColor),
                                ),
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                onTap: () {
                                  if (_widthController.text == '0') {
                                    _widthController.clear();
                                  }
                                },
                                onChanged: (_) => _onSizeChanged(),
                              ),
                            ),
                            const Text(' x ', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: TextField(
                                controller: _heightController,
                                focusNode: _heightFocus,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                ],
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: theme.dividerColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: theme.dividerColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(color: theme.primaryColor, width: 1),
                                  ),
                                  hintText: 'H',
                                  hintStyle: TextStyle(fontSize: 10, color: theme.hintColor),
                                ),
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: theme.textTheme.bodySmall?.color),
                                onTap: () {
                                  if (_heightController.text == '0') {
                                    _heightController.clear();
                                  }
                                },
                                onChanged: (_) => _onSizeChanged(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Col 2: LENGTH - Editable
            Expanded(
              flex: 10,
              child: _buildCellWithBorder(
                 child: widget.item.type == InvoiceItemType.measurement 
                  ? _buildSmallTextField(
                      controller: _lengthController, 
                      hintText: '0',
                      enabled: widget.item.totalLength <= 0.001 || widget.item.length > 0.001,
                      onChanged: (val) {
                         final v = double.tryParse(val) ?? 0.0;
                         widget.provider.updateItemField(widget.index, length: v);
                      }
                    ) 
                  : const Center(child: Text('-', style: TextStyle(color: Colors.grey))),
              ),
            ),
  
            // Col 3: QTY - Editable
            Expanded(
              flex: 10,
              child: _buildCellWithBorder(
                child: widget.item.type == InvoiceItemType.measurement
                  ? _buildSmallTextField(
                      controller: _qtyController, 
                      hintText: '0',
                      enabled: widget.item.totalLength <= 0.001 || widget.item.length > 0.001,
                      onChanged: (val) {
                         final v = int.tryParse(val) ?? 0;
                         widget.provider.updateItemField(widget.index, quantity: v);
                      }
                    )
                  : const Center(child: Text('-', style: TextStyle(color: Colors.grey))),
              ),
            ),

             // Col 4: RATE - Editable

            Expanded(
              flex: 12,
              child: _buildCellWithBorder(
                 child: _buildSmallTextField(
                  controller: _rateController, 
                  hintText: '0',
                  onChanged: (val) {
                     final v = double.tryParse(val) ?? 0.0;
                     widget.provider.updateItemField(widget.index, rate: v);
                  }
                ),
              ),
            ),
            
            // Col 5: TOT. LEN / TOT. QTY?
            // Header: TotalLen (Flex 12)
            // Row: _totQtyController
            Expanded(
              flex: 12,
              child: _buildCellWithBorder(
                child: _buildSmallTextField(
                  controller: _totalLengthController, 
                  hintText: '0',
                  enabled: widget.item.length <= 0.001,
                  onChanged: (val) {
                     final v = double.tryParse(val) ?? 0.0;
                     widget.provider.updateItemField(widget.index, totalLength: v);
                  }
                ),
              ),
            ),
            
            // Col 6: TOTAL - Read Only
            Expanded(
              flex: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                alignment: Alignment.center, // Changed to center to match header if needed, but right is better for numbers. Header was Center.
                // Let's keep Right for numbers in body, but ensure padding allows it.
                child: Text(
                  CalculationUtils.formatCurrency(widget.item.totalAmount).replaceAll('₹', ''), 
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
    final theme = Theme.of(context);
    return Container(
      decoration: showRightBorder ? BoxDecoration(
        border: Border(right: BorderSide(color: theme.dividerColor)),
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
    final theme = Theme.of(context);
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
            borderSide: BorderSide(color: theme.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(4),
             borderSide: BorderSide(color: theme.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(4),
             borderSide: BorderSide(color: theme.primaryColor, width: 2), 
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: theme.hintColor),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 14,
          color: theme.textTheme.bodyMedium?.color,
        ),
        onTap: () {
          if (controller.text == '0') {
            controller.clear();
          }
        },
        onChanged: onChanged,
        enabled: enabled,
      ),
    );
  }
}
