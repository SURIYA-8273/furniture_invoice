import 'package:flutter/material.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/payment_history_model.dart';
import '../../data/models/invoice_item_model.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/payment_history_entity.dart';
import 'hive_service.dart';
import '../constants/hive_box_names.dart';
import 'supabase_service.dart';
import '../../l10n/app_localizations.dart';

/// Result of a backup operation
class BackupResult {
  final bool success;
  final int billsSynced;
  final int billsFailed;
  final int paymentsSynced;
  final int paymentsFailed;
  final int orphanedPayments;
  final String? errorMessage;
  final DateTime timestamp;

  BackupResult({
    required this.success,
    required this.billsSynced,
    required this.billsFailed,
    required this.paymentsSynced,
    required this.paymentsFailed,
    this.orphanedPayments = 0,
    this.errorMessage,
    required this.timestamp,
  });

  bool get hasErrors => billsFailed > 0 || (paymentsFailed - orphanedPayments) > 0;
  int get totalSynced => billsSynced + paymentsSynced;
  int get totalFailed => billsFailed + paymentsFailed;

  String get statusMessage {
    if (success && !hasErrors) {
      if (orphanedPayments > 0) {
        return 'Synced $billsSynced bills. Cleaned up $orphanedPayments ghost records.';
      }
      return 'Backup completed successfully';
    } else if (hasErrors) {
      return 'Backup completed with $totalFailed errors';
    } else {
      return 'Backup failed: ${errorMessage ?? "Unknown error"}';
    }
  }
}

/// Internal result for bill backup
class BillSyncResult {
  final int synced;
  final int failed;
  final Set<String> syncedIds;
  BillSyncResult(this.synced, this.failed, this.syncedIds);
}

/// Result of a restore operation
class RestoreResult {
  final bool success;
  final int billsRestored;
  final int paymentsRestored;
  final String? errorMessage;
  final DateTime timestamp;

  RestoreResult({
    required this.success,
    required this.billsRestored,
    required this.paymentsRestored,
    this.errorMessage,
    required this.timestamp,
  });
}

/// Service for orchestrating backup operations
class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  final _supabase = SupabaseService.instance;

  // ============================================
  // BACKUP ORCHESTRATION
  // ============================================

  /// Perform full backup (all bills and payments)
  Future<BackupResult> performFullBackup({
    required String backupType, // 'automatic' or 'manual'
    Function(String)? onProgress,
    AppLocalizations? l10n,
  }) async {
    debugPrint('Starting full backup (type: $backupType)...');
    onProgress?.call(l10n?.initializingBackup ?? 'Initializing backup...');

    // Check if Supabase is initialized
    if (!_supabase.isInitialized) {
      return BackupResult(
        success: false,
        billsSynced: 0,
        billsFailed: 0,
        paymentsSynced: 0,
        paymentsFailed: 0,
        errorMessage: l10n?.supabaseNotInitialized ?? 'Supabase not initialized',
        timestamp: DateTime.now(),
      );
    }

    // Check connection
    onProgress?.call(l10n?.checkingConnectionProgress ?? 'Checking connection...');
    final isConnected = await _supabase.isConnected();
    if (!isConnected) {
      return BackupResult(
        success: false,
        billsSynced: 0,
        billsFailed: 0,
        paymentsSynced: 0,
        paymentsFailed: 0,
        errorMessage: l10n?.noInternetConnection ?? 'No internet connection',
        timestamp: DateTime.now(),
      );
    }

    String? logId;
    int billsSynced = 0;
    int billsFailed = 0;
    int paymentsSynced = 0;
    int paymentsFailed = 0;
    int orphanedPayments = 0;
    String? errorMessage;
    final Set<String> successfullySyncedBillIds = {};

    try {
      // Create backup log
      logId = await _supabase.createBackupLog(backupType: backupType);

      // Backup bills
      onProgress?.call(l10n?.backingUpBills ?? 'Backing up bills...');
      final billsSyncResult = await _backupAllBills(onProgress, l10n);
      billsSynced = billsSyncResult.synced;
      billsFailed = billsSyncResult.failed;
      successfullySyncedBillIds.addAll(billsSyncResult.syncedIds);

      // Backup payments
      onProgress?.call(l10n?.backingUpPayments ?? 'Backing up payments...');
      final paymentsResult = await _backupAllPayments(onProgress, successfullySyncedBillIds, l10n);
      paymentsSynced = paymentsResult['synced'] as int;
      paymentsFailed = paymentsResult['failed'] as int;
      orphanedPayments = paymentsResult['orphaned'] as int;

      // Determine status
      // Ghost records (orphaned) don't count as "failures" for the overall status
      final actualFailures = billsFailed + (paymentsFailed - orphanedPayments);
      final hasErrors = actualFailures > 0;
      final status = hasErrors ? 'partial' : 'success';

      // Update backup log
      await _supabase.updateBackupLog(
        logId: logId,
          status: status,
          billsSynced: billsSynced,
          billsFailed: billsFailed,
          paymentsSynced: paymentsSynced,
          paymentsFailed: actualFailures, // Report real failures to log
        );

      onProgress?.call(l10n?.backupCompleted ?? 'Backup completed!');

      final now = DateTime.now();
      // Save last backup stats locally
      await saveLastBackupStats(
        time: now,
        billsCount: billsSynced,
        paymentsCount: paymentsSynced,
      );

      return BackupResult(
        success: true,
        billsSynced: billsSynced,
        billsFailed: billsFailed,
        paymentsSynced: paymentsSynced,
        paymentsFailed: paymentsFailed,
        orphanedPayments: orphanedPayments,
        timestamp: now,
      );
    } catch (e) {
      errorMessage = e.toString();
      debugPrint('Backup failed: $errorMessage');

      // Update backup log with error
      if (logId != null) {
        await _supabase.updateBackupLog(
          logId: logId,
          status: 'failed',
          billsSynced: billsSynced,
          billsFailed: billsFailed,
          paymentsSynced: paymentsSynced,
          paymentsFailed: paymentsFailed,
          errorMessage: errorMessage,
        );
      }

      return BackupResult(
        success: false,
        billsSynced: billsSynced,
        billsFailed: billsFailed,
        paymentsSynced: paymentsSynced,
        paymentsFailed: paymentsFailed,
        errorMessage: errorMessage,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Restore data from Supabase to local Hive
  Future<RestoreResult> restoreData({
    Function(String)? onProgress,
    AppLocalizations? l10n,
  }) async {
    debugPrint('Starting data restoration from Supabase...');
    onProgress?.call(l10n?.fetchingBills ?? 'Fetching bills from cloud...');

    int billsRestored = 0;
    int paymentsRestored = 0;

    try {
      // 0. Process Cloud Deletions (Sync deletions from other devices)
      onProgress?.call(l10n?.checkingDeleted ?? 'Checking for deleted records...');
      final deletedIds = await _supabase.fetchDeletedInvoices();
      if (deletedIds.isNotEmpty) {
        debugPrint('Syncing ${deletedIds.length} deletions from cloud...');
        onProgress?.call(l10n?.removingDeleted ?? 'Removing deleted records locally...');
        
        final invoiceBox = HiveService.instance.getBox<InvoiceModel>(HiveBoxNames.invoices);
        final paymentBox = HiveService.instance.getBox<PaymentHistoryModel>(HiveBoxNames.paymentHistory);
        
        for (final id in deletedIds) {
          // Delete invoice
          await invoiceBox.delete(id);
          
          // Delete related payments
          final keysToDelete = paymentBox.keys.where((key) {
            final p = paymentBox.get(key);
            return p?.invoiceId == id;
          }).toList();
          
          for (final key in keysToDelete) {
            await paymentBox.delete(key);
          }
        }
        
        // Clear deletions from cloud after processing
        // await _supabase.clearDeletedInvoices();
        // debugPrint('Processed and cleared cloud deletions.');
      }

      // 1. Fetch all bills
      final billsData = await _supabase.fetchBills();
      debugPrint('Fetched ${billsData.length} bills from cloud');

      final invoiceBox = HiveService.instance.getBox<InvoiceModel>(HiveBoxNames.invoices);

      for (int i = 0; i < billsData.length; i++) {
        final billMap = billsData[i];
        final billId = billMap['id'] as String;
        onProgress?.call(l10n?.restoringBill(i + 1, billsData.length) ?? 'Restoring bill ${i + 1}/${billsData.length}...');

        // Fetch items for this bill
        final itemsData = await _supabase.fetchBillItems(billId);
        
        // Create models
        final items = itemsData.map((itemMap) => InvoiceItemModel(
          id: itemMap['id'],
          productName: itemMap['product_name'],
          size: itemMap['size'],
          length: (itemMap['length'] as num).toDouble(),
          quantity: itemMap['quantity'] as int,
          totalLength: (itemMap['total_length'] as num).toDouble(),
          rate: (itemMap['rate'] as num).toDouble(),
          totalAmount: (itemMap['total_amount'] as num).toDouble(),
        )).toList();

        final invoice = InvoiceModel(
          id: billId,
          invoiceNumber: billMap['invoice_number'],
          customerName: billMap['customer_name'],
          items: items,
          grandTotal: (billMap['grand_total'] as num).toDouble(),
          paidAmount: (billMap['paid_amount'] as num).toDouble(),
          balanceAmount: (billMap['balance_amount'] as num).toDouble(),
          status: billMap['status'],
          invoiceDate: _parseAndCorrectTimestamp(billMap['invoice_date']),
          createdAt: _parseAndCorrectTimestamp(billMap['created_at']),
          updatedAt: _parseAndCorrectTimestamp(billMap['updated_at']),
        );

        await invoiceBox.put(billId, invoice);
        billsRestored++;
      }

      // 2. Fetch all payments
      onProgress?.call(l10n?.fetchingPayments ?? 'Fetching payments from cloud...');
      final paymentsData = await _supabase.fetchPaymentHistory();
      debugPrint('Fetched ${paymentsData.length} payments from cloud');

      final paymentBox = HiveService.instance.getBox<PaymentHistoryModel>(HiveBoxNames.paymentHistory);

      for (int i = 0; i < paymentsData.length; i++) {
        final payMap = paymentsData[i];
        final payId = payMap['id'] as String;
        onProgress?.call(l10n?.restoringPayment(i + 1, paymentsData.length) ?? 'Restoring payment ${i + 1}/${paymentsData.length}...');

        final payment = PaymentHistoryModel(
          id: payId,
          invoiceId: payMap['invoice_id'],
          paymentDate: _parseAndCorrectTimestamp(payMap['payment_date']),
          paidAmount: (payMap['paid_amount'] as num).toDouble(),
          paymentMode: payMap['payment_mode'],
          previousDue: (payMap['previous_due'] as num).toDouble(),
          remainingDue: (payMap['remaining_due'] as num).toDouble(),
          notes: payMap['notes'],
          createdAt: _parseAndCorrectTimestamp(payMap['created_at']),
        );

        await paymentBox.put(payId, payment);
        paymentsRestored++;
      }

      onProgress?.call(l10n?.restorationCompleted ?? 'Restoration completed!');
      
      // Save last import time and stats
      await saveLastImportStats(
        time: DateTime.now(),
        billsCount: billsRestored,
        paymentsCount: paymentsRestored,
      );

      return RestoreResult(
        success: true,
        billsRestored: billsRestored,
        paymentsRestored: paymentsRestored,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Restoration failed: $e');
      return RestoreResult(
        success: false,
        billsRestored: billsRestored,
        paymentsRestored: paymentsRestored,
        errorMessage: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  /// Sync a single invoice and its items immediately
  Future<void> syncInvoice(InvoiceEntity invoice) async {
    if (!_supabase.isInitialized) return;

    try {
      final model = InvoiceModel.fromEntity(invoice);
      final billData = _prepareBillData(model);
      await _supabase.syncBill(billData);

      final itemsData = _prepareBillItemsData(model);
      await _supabase.syncBillItems(invoice.id, itemsData);
      debugPrint('Real-time sync successful for invoice: ${invoice.invoiceNumber}');
    } catch (e) {
      debugPrint('Real-time sync failed for invoice ${invoice.invoiceNumber}: $e');
    }
  }

  /// Sync a single payment immediately
  Future<void> syncPayment(PaymentHistoryEntity payment) async {
    if (!_supabase.isInitialized) return;

    try {
      final model = PaymentHistoryModel.fromEntity(payment);
      final paymentData = _preparePaymentData(model);
      await _supabase.syncPayment(paymentData);
      debugPrint('Real-time sync successful for payment: ${payment.id}');
    } catch (e) {
      debugPrint('Real-time sync failed for payment ${payment.id}: $e');
    }
  }

  /// Perform incremental backup (only changed records)
  Future<BackupResult> performIncrementalBackup({
    required String backupType,
    Function(String)? onProgress,
    AppLocalizations? l10n,
  }) async {
    debugPrint('Starting incremental backup (type: $backupType)...');
    onProgress?.call('Checking for changes...');

    return performFullBackup(
      backupType: backupType,
      onProgress: onProgress,
      l10n: l10n,
    );
  }

  // ============================================
  // PRIVATE HELPER METHODS
  // ============================================

  /// Backup all bills from Hive to Supabase
  Future<BillSyncResult> _backupAllBills(Function(String)? onProgress, AppLocalizations? l10n) async {
    int synced = 0;
    int failed = 0;
    final Set<String> syncedIds = {};
    final Set<String> seenInvoiceNumbers = {};

    try {
      final box = HiveService.instance.getBox<InvoiceModel>(HiveBoxNames.invoices);
      final invoices = box.values.toList();

      debugPrint('Found ${invoices.length} bills to backup');

      for (int i = 0; i < invoices.length; i++) {
        final invoice = invoices[i];
        
        // Diagnosis: Check for local duplicates
        if (seenInvoiceNumbers.contains(invoice.invoiceNumber)) {
          debugPrint('DEBUG: Local duplicate found for invoice number: ${invoice.invoiceNumber}. This will likely fail on Supabase due to UNIQUE constraint.');
        }
        seenInvoiceNumbers.add(invoice.invoiceNumber);

        onProgress?.call(l10n?.backingUpBill(i + 1, invoices.length) ?? 'Backing up bill ${i + 1}/${invoices.length}...');

        try {
          // Prepare bill data
          final billData = _prepareBillData(invoice);

          // Sync bill
          try {
            await _supabase.syncBill(billData);
          } catch (e) {
            debugPrint('DEBUG: Error syncing bill table for ${invoice.invoiceNumber}: $e');
            rethrow;
          }

          // Sync bill items
          try {
            final itemsData = _prepareBillItemsData(invoice);
            await _supabase.syncBillItems(invoice.id, itemsData);
          } catch (e) {
            debugPrint('DEBUG: Error syncing bill_items table for ${invoice.invoiceNumber}: $e');
            rethrow;
          }

          syncedIds.add(invoice.id);
          synced++;
        } catch (e) {
          debugPrint('----------------------------------------');
          debugPrint('CRITICAL: Failed to backup bill ${invoice.invoiceNumber}');
          debugPrint('ID: ${invoice.id}');
          debugPrint('Error: $e');
          if (e.toString().contains('PostgrestException')) {
             debugPrint('Postgrest details: $e');
          }
          debugPrint('----------------------------------------');
          failed++;
        }
      }
    } catch (e) {
      debugPrint('Error accessing invoices box: $e');
      throw Exception('Failed to access local database');
    }

    return BillSyncResult(synced, failed, syncedIds);
  }

  /// Backup all payments from Hive to Supabase
  Future<Map<String, int>> _backupAllPayments(
      Function(String)? onProgress, Set<String> syncedBillIds, AppLocalizations? l10n) async {
    int synced = 0;
    int failed = 0;
    int orphaned = 0;

    try {
      final box = HiveService.instance.getBox<PaymentHistoryModel>(HiveBoxNames.paymentHistory);
      final payments = box.values.toList();

      debugPrint('Found ${payments.length} payments to backup');

      for (int i = 0; i < payments.length; i++) {
        final payment = payments[i];
        
        // Skip payments for bills that weren't synced (to avoid FK errors)
        if (payment.invoiceId != null && !syncedBillIds.contains(payment.invoiceId)) {
          final billBox = HiveService.instance.getBox<InvoiceModel>(HiveBoxNames.invoices);
          final billExistsLocally = billBox.containsKey(payment.invoiceId);

          if (!billExistsLocally) {
            debugPrint('Orphaned record: Payment ${payment.id} for deleted bill ${payment.invoiceId}. Will not sync.');
            orphaned++;
          } else {
            debugPrint('Skipping payment ${payment.id} because bill ${payment.invoiceId} failed to sync (but exists locally)');
          }
          
          failed++;
          continue;
        }

        onProgress?.call(l10n?.backingUpPayment(i + 1, payments.length) ?? 'Backing up payment ${i + 1}/${payments.length}...');

        try {
          final paymentData = _preparePaymentData(payment);
          await _supabase.syncPayment(paymentData);
          synced++;
        } catch (e) {
          debugPrint('Failed to backup payment ${payment.id}: $e');
          failed++;
        }
      }
    } catch (e) {
      debugPrint('Error accessing payment_history box: $e');
      throw Exception('Failed to access local database');
    }

    return {'synced': synced, 'failed': failed, 'orphaned': orphaned};
  }



  Map<String, dynamic> _prepareBillData(InvoiceModel invoice) {
    String status = invoice.status.toLowerCase();
    
    // Normalize status to match Supabase CHECK constraint: ('paid', 'partial', 'unpaid')
    if (status == 'partially_paid' || status == 'partial') {
      status = 'partial';
    } else if (status == 'pending' || status == 'unpaid') {
      status = 'unpaid';
    } else if (status == 'paid') {
      status = 'paid';
    } else {
      // Fallback based on financial values if status is unknown
      status = invoice.balanceAmount <= 0 ? 'paid' : (invoice.paidAmount > 0 ? 'partial' : 'unpaid');
    }

    return {
      'id': invoice.id,
      'invoice_number': invoice.invoiceNumber,
      'customer_name': invoice.customerName,
      'grand_total': invoice.grandTotal,
      'paid_amount': invoice.paidAmount,
      'balance_amount': invoice.balanceAmount,
      'status': invoice.status,
      'invoice_date': invoice.invoiceDate.toUtc().toIso8601String(),
      'created_at': invoice.createdAt.toUtc().toIso8601String(),
      'updated_at': invoice.updatedAt.toUtc().toIso8601String(),
      'last_synced_at': DateTime.now().toUtc().toIso8601String(),
      'sync_status': 'synced',
    };
  }

  /// Prepare bill items data for Supabase
  List<Map<String, dynamic>> _prepareBillItemsData(InvoiceModel invoice) {
    return invoice.items.map((item) {
      return {
        'id': item.id,
        'bill_id': invoice.id,
        'product_name': item.productName,
        'size': item.size,
        'length': item.length,
        'quantity': item.quantity,
        'total_length': item.totalLength,
        'rate': item.rate,
        'total_amount': item.totalAmount,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      };
    }).toList();
  }

  /// Prepare payment data for Supabase
  Map<String, dynamic> _preparePaymentData(PaymentHistoryModel payment) {
    return {
      'id': payment.id,
      'invoice_id': payment.invoiceId,
      'payment_date': payment.paymentDate.toUtc().toIso8601String(),
      'paid_amount': payment.paidAmount,
      'payment_mode': payment.paymentMode.toLowerCase(),
      'previous_due': payment.previousDue,
      'remaining_due': payment.remainingDue,
      'notes': payment.notes,
      'created_at': payment.createdAt.toUtc().toIso8601String(),
      'last_synced_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Get last backup stats from local settings
  Future<Map<String, dynamic>> getLastBackupStats() async {
    try {
      final box = HiveService.instance.getBox(HiveBoxNames.appSettings);
      final lastBackup = box.get('last_backup_time');
      if (lastBackup == null) return {};
      
      return {
        'time': DateTime.parse(lastBackup as String),
        'billsCount': box.get('last_backup_bills_count') ?? 0,
        'paymentsCount': box.get('last_backup_payments_count') ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting last backup stats: $e');
      return {};
    }
  }

  /// Save last backup stats locally
  Future<void> saveLastBackupStats({
    required DateTime time,
    required int billsCount,
    required int paymentsCount,
  }) async {
    try {
      final box = HiveService.instance.getBox(HiveBoxNames.appSettings);
      await box.put('last_backup_time', time.toIso8601String());
      await box.put('last_backup_bills_count', billsCount);
      await box.put('last_backup_payments_count', paymentsCount);
    } catch (e) {
      debugPrint('Error saving last backup stats: $e');
    }
  }

  /// Get last backup timestamp from Supabase logs or local cache
  Future<DateTime?> getLastBackupTime() async {
    final stats = await getLastBackupStats();
    if (stats.containsKey('time')) return stats['time'] as DateTime;

    if (!_supabase.isInitialized) return null;
    
    try {
      final logs = await _supabase.getBackupLogs(limit: 1);
      if (logs.isEmpty) return null;

      final lastLog = logs.first;
      if (lastLog['completed_at'] == null) return null;
      return DateTime.parse(lastLog['completed_at'] as String);
    } catch (e) {
      debugPrint('Error getting last backup time: $e');
      return null;
    }
  }

  /// Check if backup is needed (based on time threshold)
  Future<bool> isBackupNeeded({Duration threshold = const Duration(hours: 24)}) async {
    final lastBackup = await getLastBackupTime();
    if (lastBackup == null) return true;

    final timeSinceBackup = DateTime.now().difference(lastBackup);
    return timeSinceBackup > threshold;
  }

  /// Get last import stats from local settings
  Future<Map<String, dynamic>> getLastImportStats() async {
    try {
      final box = HiveService.instance.getBox(HiveBoxNames.appSettings);
      final lastImport = box.get('last_import_time');
      if (lastImport == null) return {};
      
      return {
        'time': DateTime.parse(lastImport as String),
        'billsCount': box.get('last_import_bills_count') ?? 0,
        'paymentsCount': box.get('last_import_payments_count') ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting last import stats: $e');
      return {};
    }
  }

  /// Save last import stats locally
  Future<void> saveLastImportStats({
    required DateTime time,
    required int billsCount,
    required int paymentsCount,
  }) async {
    try {
      final box = HiveService.instance.getBox(HiveBoxNames.appSettings);
      await box.put('last_import_time', time.toIso8601String());
      await box.put('last_import_bills_count', billsCount);
      await box.put('last_import_payments_count', paymentsCount);
    } catch (e) {
      debugPrint('Error saving last import stats: $e');
    }
  }

  /// Get last excel sync stats from local settings
  Future<Map<String, dynamic>> getLastExcelSyncStats() async {
    try {
      final box = HiveService.instance.getBox(HiveBoxNames.appSettings);
      final lastSync = box.get('last_excel_sync_time');
      if (lastSync == null) return {};
      
      return {
        'time': DateTime.parse(lastSync as String),
      };
    } catch (e) {
      debugPrint('Error getting last excel sync stats: $e');
      return {};
    }
  }

  /// Save last excel sync stats locally
  Future<void> saveLastExcelSyncStats({
    required DateTime time,
  }) async {
    try {
      final box = HiveService.instance.getBox(HiveBoxNames.appSettings);
      await box.put('last_excel_sync_time', time.toIso8601String());
    } catch (e) {
      debugPrint('Error saving last excel sync stats: $e');
    }
  }

  /// Keep for backward compatibility or remove if not used
  Future<DateTime?> getLastImportTime() async {
    final stats = await getLastImportStats();
    return stats['time'] as DateTime?;
  }

  /// Parse timestamp and correct for potential timezone drift
  /// If a timestamp appears to be in the future (due to legacy Local-as-UTC sync),
  /// shift it back by the local timezone offset.
  DateTime _parseAndCorrectTimestamp(String timestamp) {
    if (timestamp.isEmpty) return DateTime.now();
    try {
      final parsed = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      
      // Tolerance of 30 minutes to avoid correcting slightly drifting clocks
      // If the time is more than 30 mins in the future, it's likely a timezone error (min offset usually 1h+)
      if (parsed.isAfter(now.add(const Duration(minutes: 30)))) {
        debugPrint('Detected future timestamp (Timezone Drift): $parsed. Correcting by offset...');
        // Assuming the future drift is caused by interpreting Local as UTC
        // We subtract the local timezone offset to restore original time
        return parsed.subtract(now.timeZoneOffset);
      }
      
      return parsed;
    } catch (e) {
      debugPrint('Error parsing timestamp correction: $e');
      return DateTime.now();
    }
  }
}

