import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../constants/hive_box_names.dart';
import '../../data/models/business_profile_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/invoice_item_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/payment_history_model.dart';

/// Service for initializing and managing Hive database.
/// Handles encryption, box initialization, and cleanup.
class HiveService {
  HiveService._();
  
  static final HiveService instance = HiveService._();
  
  bool _isInitialized = false;
  
  /// Check if Hive is initialized
  bool get isInitialized => _isInitialized;
  
  /// Initialize Hive with encryption
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Hive is already initialized');
      return;
    }
    
    try {
      // Initialize Hive Flutter
      await Hive.initFlutter();
      
      // Register all adapters
      Hive.registerAdapter(BusinessProfileModelAdapter()); // typeId: 0
      Hive.registerAdapter(ProductModelAdapter()); // typeId: 2
      Hive.registerAdapter(PaymentHistoryModelAdapter()); // typeId: 3
      Hive.registerAdapter(InvoiceModelAdapter()); // typeId: 4
      Hive.registerAdapter(InvoiceItemModelAdapter()); // typeId: 5
      Hive.registerAdapter(PaymentModelAdapter()); // typeId: 6
      
      debugPrint('Hive initialized successfully with all adapters');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }
  
  /// Open all required Hive boxes
  Future<void> openBoxes() async {
    if (!_isInitialized) {
      throw Exception('Hive must be initialized before opening boxes');
    }
    
    try {
      // Open settings boxes (non-encrypted for simplicity)
      await Hive.openBox(HiveBoxNames.themeSettings);
      await Hive.openBox(HiveBoxNames.languageSettings);
      await Hive.openBox(HiveBoxNames.appSettings);
      
      // Open business data boxes (encrypted)
      final encryptionKey = _generateEncryptionKey();
      
      await Hive.openBox(
        HiveBoxNames.businessProfile,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      
      await Hive.openBox(
        HiveBoxNames.products,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      
      await Hive.openBox(
        HiveBoxNames.invoices,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      
      await Hive.openBox(
        HiveBoxNames.invoiceItems,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      
      await Hive.openBox(
        HiveBoxNames.payments,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      
      await Hive.openBox<PaymentHistoryModel>(
        HiveBoxNames.paymentHistory,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      
      await Hive.openBox(
        HiveBoxNames.balanceHistory,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      
      debugPrint('All Hive boxes opened successfully');
    } catch (e) {
      debugPrint('Error opening Hive boxes: $e');
      rethrow;
    }
  }
  
  /// Generate encryption key
  /// In production, use flutter_secure_storage to store this securely
  List<int> _generateEncryptionKey() {
    // This is a simple implementation for development
    // In production, generate a secure random key and store it in secure storage
    const key = 'FurnitureBilling2026SecureKey!';
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32, '0'));
    return keyBytes.bytes;
  }
  
  /// Close all Hive boxes
  Future<void> closeBoxes() async {
    try {
      await Hive.close();
      debugPrint('All Hive boxes closed successfully');
    } catch (e) {
      debugPrint('Error closing Hive boxes: $e');
    }
  }
  
  /// Delete all data (for testing/debugging)
  Future<void> deleteAllData() async {
    try {
      await Hive.deleteFromDisk();
      _isInitialized = false;
      debugPrint('All Hive data deleted successfully');
    } catch (e) {
      debugPrint('Error deleting Hive data: $e');
    }
  }
  
  /// Get a specific box
  Box getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName is not open');
    }
    return Hive.box(boxName);
  }
  
  /// Check if a box is open
  bool isBoxOpen(String boxName) {
    return Hive.isBoxOpen(boxName);
  }
}
