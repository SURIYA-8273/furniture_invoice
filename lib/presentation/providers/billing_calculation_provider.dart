import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/invoice_item_entity.dart';
import '../../domain/entities/customer_entity.dart';

/// Provider for managing billing calculations in real-time.
/// Supports fully editable fields with automatic recalculation.
class BillingCalculationProvider extends ChangeNotifier {
  // Items
  List<InvoiceItemEntity> _items = [];
  
  // Financial calculations
  double _discount = 0.0;
  double _gstPercentage = 0.0;
  double _advancePayment = 0.0;
  
  // Invoice metadata
  String _invoiceNumber = '';
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  String _paymentTerms = '';
  
  // Customer details
  CustomerEntity? _selectedCustomer;
  String _shippingAddress = '';
  bool _sameAsBilling = true;
  
  // Payment details
  String _paymentMethod = 'Cash';
  
  // Additional details
  String _notes = '';
  String _termsAndConditions = '';
  DateTime? _deliveryDate;
  String _referenceNumber = '';

  // Getters - Items
  List<InvoiceItemEntity> get items => _items;
  
  // Getters - Financial
  double get discount => _discount;
  double get gstPercentage => _gstPercentage;
  double get advancePayment => _advancePayment;
  
  // Getters - Invoice metadata
  String get invoiceNumber => _invoiceNumber;
  DateTime get invoiceDate => _invoiceDate;
  DateTime? get dueDate => _dueDate;
  String get paymentTerms => _paymentTerms;
  
  // Getters - Customer
  CustomerEntity? get selectedCustomer => _selectedCustomer;
  String get shippingAddress => _shippingAddress;
  bool get sameAsBilling => _sameAsBilling;
  
  // Getters - Payment
  String get paymentMethod => _paymentMethod;
  
  // Getters - Additional
  String get notes => _notes;
  String get termsAndConditions => _termsAndConditions;
  DateTime? get deliveryDate => _deliveryDate;
  String get referenceNumber => _referenceNumber;

  /// Calculate subtotal from all items
  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  /// Calculate GST amount
  double get gstAmount {
    return (subtotal - _discount) * (_gstPercentage / 100);
  }

  /// Calculate grand total
  double get grandTotal {
    return subtotal - _discount + gstAmount;
  }
  
  /// Calculate balance due
  double get balanceDue {
    return grandTotal - _advancePayment;
  }
  
  /// Get payment status
  String get paymentStatus {
    if (_advancePayment >= grandTotal) return 'Paid';
    if (_advancePayment > 0) return 'Partially Paid';
    return 'Unpaid';
  }

  /// Add a new item to the invoice
  void addItem({
    required String productName,
    required String size,
    required double mrp,
    int quantity = 1,
  }) {
    final squareFeet = InvoiceItemEntity.calculateSquareFeetFromSize(size);
    final totalQuantity = InvoiceItemEntity.calculateTotalQuantity(squareFeet, quantity);
    final totalAmount = InvoiceItemEntity.calculateTotalAmount(mrp, totalQuantity);

    final item = InvoiceItemEntity(
      id: const Uuid().v4(),
      productName: productName,
      size: size,
      squareFeet: squareFeet,
      quantity: quantity,
      totalQuantity: totalQuantity,
      mrp: mrp,
      totalAmount: totalAmount,
    );

    _items.add(item);
    notifyListeners();
  }

  /// Update an existing item
  void updateItem(int index, InvoiceItemEntity updatedItem) {
    if (index >= 0 && index < _items.length) {
      _items[index] = updatedItem;
      notifyListeners();
    }
  }

  /// Update item field with auto-recalculation
  void updateItemField(
    int index, {
    String? productName,
    String? size,
    double? squareFeet,
    int? quantity,
    double? totalQuantity,
    double? mrp,
    double? totalAmount,
  }) {
    if (index < 0 || index >= _items.length) return;

    final item = _items[index];

    // If size changed, recalculate square feet
    if (size != null && size != item.size) {
      squareFeet = InvoiceItemEntity.calculateSquareFeetFromSize(size);
    }

    // Use provided values or keep existing
    final newSquareFeet = squareFeet ?? item.squareFeet;
    final newQuantity = quantity ?? item.quantity;
    final newMrp = mrp ?? item.mrp;

    // Recalculate dependent fields if not manually overridden
    final newTotalQuantity = totalQuantity ??
        InvoiceItemEntity.calculateTotalQuantity(newSquareFeet, newQuantity);
    
    final newTotalAmount = totalAmount ??
        InvoiceItemEntity.calculateTotalAmount(newMrp, newTotalQuantity);

    _items[index] = item.copyWith(
      productName: productName,
      size: size,
      squareFeet: newSquareFeet,
      quantity: newQuantity,
      totalQuantity: newTotalQuantity,
      mrp: newMrp,
      totalAmount: newTotalAmount,
    );

    notifyListeners();
  }

  /// Remove an item
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Set discount amount
  void setDiscount(double value) {
    _discount = value.clamp(0.0, subtotal);
    notifyListeners();
  }

  /// Set GST percentage
  void setGstPercentage(double value) {
    _gstPercentage = value.clamp(0.0, 100.0);
    notifyListeners();
  }
  
  /// Set advance payment
  void setAdvancePayment(double value) {
    _advancePayment = value.clamp(0.0, grandTotal);
    notifyListeners();
  }
  
  /// Set invoice number
  void setInvoiceNumber(String value) {
    _invoiceNumber = value;
    notifyListeners();
  }
  
  /// Set invoice date
  void setInvoiceDate(DateTime date) {
    _invoiceDate = date;
    notifyListeners();
  }
  
  /// Set due date
  void setDueDate(DateTime? date) {
    _dueDate = date;
    notifyListeners();
  }
  
  /// Set payment terms
  void setPaymentTerms(String value) {
    _paymentTerms = value;
    notifyListeners();
  }
  
  /// Set selected customer
  void setSelectedCustomer(CustomerEntity? customer) {
    _selectedCustomer = customer;
    if (_sameAsBilling && customer != null) {
      _shippingAddress = customer.address ?? '';
    }
    notifyListeners();
  }
  
  /// Set shipping address
  void setShippingAddress(String value) {
    _shippingAddress = value;
    notifyListeners();
  }
  
  /// Toggle same as billing
  void setSameAsBilling(bool value) {
    _sameAsBilling = value;
    if (value && _selectedCustomer != null) {
      _shippingAddress = _selectedCustomer!.address ?? '';
    }
    notifyListeners();
  }
  
  /// Set payment method
  void setPaymentMethod(String value) {
    _paymentMethod = value;
    notifyListeners();
  }
  
  /// Set notes
  void setNotes(String value) {
    _notes = value;
    notifyListeners();
  }
  
  /// Set terms and conditions
  void setTermsAndConditions(String value) {
    _termsAndConditions = value;
    notifyListeners();
  }
  
  /// Set delivery date
  void setDeliveryDate(DateTime? date) {
    _deliveryDate = date;
    notifyListeners();
  }
  
  /// Set reference number
  void setReferenceNumber(String value) {
    _referenceNumber = value;
    notifyListeners();
  }
  
  /// Generate auto invoice number
  void generateInvoiceNumber() {
    final now = DateTime.now();
    _invoiceNumber = 'INV${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
    notifyListeners();
  }
  
  /// Validation: Check if customer is selected
  bool get hasCustomer => _selectedCustomer != null;
  
  /// Validation: Check if items exist
  bool get hasItems => _items.isNotEmpty;
  
  /// Validation: Check if due date is valid
  bool get isDueDateValid {
    if (_dueDate == null) return true;
    return _dueDate!.isAfter(_invoiceDate) || _dueDate!.isAtSameMomentAs(_invoiceDate);
  }
  
  /// Validation: Check if advance payment is valid
  bool get isAdvancePaymentValid {
    return _advancePayment <= grandTotal;
  }
  
  /// Validation: Check if all required fields are filled
  bool get isValid {
    return hasCustomer && hasItems && isDueDateValid && isAdvancePaymentValid;
  }

  /// Clear all items and reset
  void clear() {
    _items.clear();
    _discount = 0.0;
    _gstPercentage = 0.0;
    _advancePayment = 0.0;
    _invoiceNumber = '';
    _invoiceDate = DateTime.now();
    _dueDate = null;
    _paymentTerms = '';
    _selectedCustomer = null;
    _shippingAddress = '';
    _sameAsBilling = true;
    _paymentMethod = 'Cash';
    _notes = '';
    _termsAndConditions = '';
    _deliveryDate = null;
    _referenceNumber = '';
    notifyListeners();
  }

  /// Load existing items (for editing invoice)
  void loadItems(List<InvoiceItemEntity> items, {double? discount, double? gstPercentage}) {
    _items = List.from(items);
    _discount = discount ?? 0.0;
    _gstPercentage = gstPercentage ?? 0.0;
    notifyListeners();
  }
}
