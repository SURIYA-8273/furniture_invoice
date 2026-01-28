import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/invoice_item_entity.dart';

/// Provider for managing billing calculations in real-time.
/// Supports fully editable fields with automatic recalculation.
class BillingCalculationProvider extends ChangeNotifier {
  
  BillingCalculationProvider() {
    // Initialize with default state (one empty row)
    clear();
  }
  // Items
  List<InvoiceItemEntity> _items = [];
  
  // Financial calculations
  double _advancePayment = 0.0;
  
  // Invoice metadata
  String _invoiceNumber = '';
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  String _paymentTerms = '';
  
  // Payment details
  String _paymentMethod = 'cash';
  
  // Additional details
  String _notes = '';
  String _termsAndConditions = '';
  DateTime? _deliveryDate;
  String _referenceNumber = '';
  
  // Smart Suggestions
  List<String> get uniqueSizes {
    final sizes = _items
        .map((item) => item.size)
        .where((size) => size.isNotEmpty && size.contains('x'))
        .toSet()
        .toList();
    // Sort logic removed to keep user's history order or basic sort? 
    // Let's keep recent ones or just standard list.
    // Ideally user might want most frequent, but unique list is a good start.
    return sizes;
  }

  // Getters - Items
  List<InvoiceItemEntity> get items => _items;
  
  // Getters - Financial
  double get advancePayment => _advancePayment;
  
  // Getters - Invoice metadata
  String get invoiceNumber => _invoiceNumber;
  DateTime get invoiceDate => _invoiceDate;
  DateTime? get dueDate => _dueDate;
  String get paymentTerms => _paymentTerms;
  
  // Getters - Payment
  String get paymentMethod => _paymentMethod;
  
  // Getters - Additional
  String get notes => _notes;
  String get termsAndConditions => _termsAndConditions;
  DateTime? get deliveryDate => _deliveryDate;
  String get referenceNumber => _referenceNumber;

  /// Calculate grand total
  double get grandTotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalAmount);
  }
  
  /// Calculate balance due
  double get balanceDue {
    return grandTotal - _advancePayment;
  }
  
  /// Get payment status
  String get paymentStatus {
    if (_advancePayment >= grandTotal) return 'paid';
    if (_advancePayment > 0) return 'partial';
    return 'unpaid';
  }

  /// Add a new item to the invoice
  void addItem({
    required String productName,
    InvoiceItemType type = InvoiceItemType.measurement,
    String? size,
    double rate = 0.0,
    int quantity = 0,
    double? totalLength, // For direct items
    double length = 0.0, // Length
  }) {
    double finalLength = length;
    double finalTotalLength = 0.0;

    if (type == InvoiceItemType.measurement) {
        // Size string (HxW) is just informational now.
        // finalLength is taken directly from arguments.
        finalTotalLength = InvoiceItemEntity.calculateTotalLength(finalLength, quantity);
    } else {
       // Direct
       finalTotalLength = totalLength ?? 1.0;
    }

    final totalAmount = InvoiceItemEntity.calculateTotalAmount(rate, finalTotalLength);

    final item = InvoiceItemEntity(
      id: const Uuid().v4(),
      productName: productName,
      type: type,
      size: size ?? '',
      length: finalLength,
      quantity: quantity,
      totalLength: finalTotalLength,
      rate: rate,
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
    double? length,
    int? quantity,
    double? totalLength,
    double? rate,
    double? totalAmount,
  }) {
    if (index < 0 || index >= _items.length) return;

    final item = _items[index];

    // Recalculate if dimensions changed
    final newLength = length ?? item.length;
    final newQuantity = quantity ?? item.quantity;
    double effectiveRate = rate ?? item.rate;

    // Auto-fill Rate Logic:
    // If dimensions (size/length) changed and Rate wasn't manually entered in this update,
    // check if any other item has the same dimensions and copy its Rate.
    if (rate == null && (size != null || length != null)) {
       final effectiveSize = size ?? item.size;
       
       // Search for a match in other items
       for (final otherItem in _items) {
         if (otherItem == item) continue; // Skip self
         
         bool isMatch = false;
         // Match by Size string if available and not empty
         // This ensures both Width and Height are the same (as they form the "W x H" string)
         if (effectiveSize.isNotEmpty && otherItem.size.isNotEmpty && effectiveSize == otherItem.size) {
           isMatch = true;
         } 

         if (isMatch && otherItem.rate > 0) {
           effectiveRate = otherItem.rate;
           break; // Found a match, stop
         }
       }
    }

    final newRate = effectiveRate;

    // Recalculate dependent fields if not manually overridden
    double newTotalLength = totalLength ?? item.totalLength;
    
    // Auto-calc total length only if type is measurement AND totalLength wasn't explicitly passed
    if (item.type == InvoiceItemType.measurement && totalLength == null) {
       // If Length (newLength) is > 0, we are in Length Mode: Force sync.
       if (newLength > 0.001) {
          newTotalLength = InvoiceItemEntity.calculateTotalLength(newLength, newQuantity);
       } else {
          // Length is 0.
          // If dimensions were explicitly changed, respect the formula (which gives 0).
          // If dimensions were NOT changed (e.g. Rate update), preserve existing Total Length (Manual Mode).
          bool dimensionsChanged = (length != null || quantity != null);
          if (dimensionsChanged) {
             newTotalLength = InvoiceItemEntity.calculateTotalLength(newLength, newQuantity);
          } else {
             newTotalLength = item.totalLength;
          }
       }
    } 
    
    // Determine effective multiplier for Total Amount calculation
    double multiplier = newTotalLength;
    if (multiplier <= 0.001) {
      if (newQuantity > 0) {
        multiplier = newQuantity.toDouble();
      } else {
        // If both Total Length and Qty are 0, implies 1 unit if Rate is entered (unless Rate is also 0)
         multiplier = 1.0;
      }
    }

    final newTotalAmount = totalAmount ?? (newRate * multiplier);

    _items[index] = item.copyWith(
      productName: productName,
      size: size,
      length: newLength,
      quantity: newQuantity,
      totalLength: newTotalLength,
      rate: newRate,
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
  
  /// Generate invoice number
  void generateInvoiceNumber({int? nextNumber}) {
    // User requested UUID auto-generation instead of BILL- prefix
    // We use a short 8-character unique alphanumeric string for readability
    _invoiceNumber = const Uuid().v4().substring(0, 8).toUpperCase();
    notifyListeners();
  }
  
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
    return hasItems && isDueDateValid && isAdvancePaymentValid && !hasInvalidItems;
  }

  /// Validation: Check if any item has 0 total amount
  bool get hasInvalidItems {
    return _items.any((item) => item.totalAmount <= 0.001); // Basically 0
  }

  /// Clear all items and reset
  void clear() {
    _items.clear();
    _advancePayment = 0.0;
    _invoiceNumber = '';
    _invoiceDate = DateTime.now();
    _dueDate = null;
    _paymentTerms = '';
    _paymentMethod = 'Cash';
    _notes = '';
    _termsAndConditions = '';
    _deliveryDate = null;
    _referenceNumber = '';
    
    // Add default empty row as per user request
    addItem(productName: '');
    
    notifyListeners();
  }

  /// Load existing items (for editing invoice)
  void loadItems(List<InvoiceItemEntity> items) {
    _items = List.from(items);
    notifyListeners();
  }
}
