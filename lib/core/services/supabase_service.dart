import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for Supabase cloud backup integration
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  SupabaseClient? _client;
  bool _isInitialized = false;

  /// Initialize Supabase
  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_isInitialized) {
      debugPrint('Supabase is already initialized');
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );

      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      rethrow;
    }
  }

  /// Get Supabase client
  SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  bool get isInitialized => _isInitialized;

  // ============================================
  // BILLS BACKUP METHODS
  // ============================================

  /// Sync a single bill to cloud (upsert)
  Future<void> syncBill(Map<String, dynamic> bill) async {
    try {
      await client.from('bills').upsert(bill, onConflict: 'id');
      debugPrint('Synced bill: ${bill['invoice_number']}');
    } catch (e) {
      debugPrint('Error syncing bill ${bill['id']}: $e');
      rethrow;
    }
  }

  /// Delete a bill from cloud
  Future<void> deleteBill(String id) async {
    try {
      await client.from('bills').delete().eq('id', id);
      debugPrint('Deleted bill from cloud: $id');
    } catch (e) {
      debugPrint('Error deleting bill from cloud: $e');
      rethrow;
    }
  }

  /// Record a deleted invoice ID to the tombstone table
  Future<void> recordDeletion(String invoiceId) async {
    try {
      await client.from('deleted_invoices').insert({
        'invoice_id': invoiceId,
        'deleted_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('Recorded deletion tombstone for: $invoiceId');
    } catch (e) {
      debugPrint('Error recording deletion: $e');
      // We don't rethrow here to allow local deletion to proceed 
      // even if tombstone record fails (offline case usually handled by sync).
    }
  }

  /// Fetch all deleted invoice IDs from cloud
  Future<List<String>> fetchDeletedInvoices() async {
    try {
      final response = await client.from('deleted_invoices').select('invoice_id');
      return (response as List).map((r) => r['invoice_id'] as String).toList();
    } catch (e) {
      debugPrint('Error fetching deleted invoices: $e');
      return [];
    }
  }

  /// Clear the tombstone table
  Future<void> clearDeletedInvoices() async {
    try {
      // Deleting all rows where invoice_id is not null (effectively everything)
      await client.from('deleted_invoices').delete().neq('invoice_id', 'null');
      debugPrint('Cleared deleted_invoices table');
    } catch (e) {
      debugPrint('Error clearing deleted invoices: $e');
    }
  }

  /// Sync multiple bills to cloud (batch upsert)
  Future<int> syncBills(List<Map<String, dynamic>> bills) async {
    int successCount = 0;
    for (final bill in bills) {
      try {
        await syncBill(bill);
        successCount++;
      } catch (e) {
        debugPrint('Failed to sync bill ${bill['id']}: $e');
      }
    }
    debugPrint('Synced $successCount/${bills.length} bills to cloud');
    return successCount;
  }

  // ============================================
  // BILL ITEMS BACKUP METHODS
  // ============================================

  /// Sync bill items for a specific bill
  Future<void> syncBillItems(
    String billId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      // Delete existing items for this bill
      await client.from('bill_items').delete().eq('bill_id', billId);

      // Insert new items
      if (items.isNotEmpty) {
        await client.from('bill_items').insert(items);
      }
      debugPrint('Synced ${items.length} items for bill $billId');
    } catch (e) {
      debugPrint('Error syncing bill items for $billId: $e');
      rethrow;
    }
  }

  // ============================================
  // PAYMENT HISTORY BACKUP METHODS
  // ============================================

  /// Sync a single payment to cloud (upsert)
  Future<void> syncPayment(Map<String, dynamic> payment) async {
    try {
      await client.from('payment_history').upsert(payment, onConflict: 'id');
      debugPrint('Synced payment: ${payment['id']}');
    } catch (e) {
      debugPrint('Error syncing payment ${payment['id']}: $e');
      rethrow;
    }
  }

  /// Sync multiple payments to cloud (batch upsert)
  Future<int> syncPayments(List<Map<String, dynamic>> payments) async {
    int successCount = 0;
    for (final payment in payments) {
      try {
        await syncPayment(payment);
        successCount++;
      } catch (e) {
        debugPrint('Failed to sync payment ${payment['id']}: $e');
      }
    }
    debugPrint('Synced $successCount/${payments.length} payments to cloud');
    return successCount;
  }

  // ============================================
  // BACKUP LOGGING METHODS
  // ============================================

  /// Create a backup log entry
  Future<String> createBackupLog({
    required String backupType, // 'automatic' or 'manual'
  }) async {
    try {
      final response = await client.from('backup_logs').insert({
        'backup_type': backupType,
        'backup_status': 'running',
        'started_at': DateTime.now().toUtc().toIso8601String(),
      }).select();

      final logId = response[0]['id'] as String;
      debugPrint('Created backup log: $logId');
      return logId;
    } catch (e) {
      debugPrint('Error creating backup log: $e');
      rethrow;
    }
  }

  /// Update backup log with results
  Future<void> updateBackupLog({
    required String logId,
    required String status, // 'success', 'partial', 'failed'
    required int billsSynced,
    required int billsFailed,
    required int paymentsSynced,
    required int paymentsFailed,
    String? errorMessage,
    Map<String, dynamic>? errorDetails,
  }) async {
    try {
      final startedAt = await _getBackupLogStartTime(logId);
      final completedAt = DateTime.now();
      final duration = completedAt.difference(startedAt).inSeconds;

      await client.from('backup_logs').update({
        'backup_status': status,
        'bills_synced': billsSynced,
        'bills_failed': billsFailed,
        'payments_synced': paymentsSynced,
        'payments_failed': paymentsFailed,
        'error_message': errorMessage,
        'error_details': errorDetails,
        'completed_at': completedAt.toUtc().toIso8601String(),
        'duration_seconds': duration,
      }).eq('id', logId);

      debugPrint('Updated backup log: $logId - Status: $status');
    } catch (e) {
      debugPrint('Error updating backup log: $e');
    }
  }

  /// Get backup log start time
  Future<DateTime> _getBackupLogStartTime(String logId) async {
    try {
      final response = await client
          .from('backup_logs')
          .select('started_at')
          .eq('id', logId)
          .single();
      return DateTime.parse(response['started_at'] as String);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Get recent backup logs
  Future<List<Map<String, dynamic>>> getBackupLogs({int limit = 10}) async {
    try {
      final response = await client
          .from('backup_logs')
          .select()
          .order('started_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching backup logs: $e');
      return [];
    }
  }

  // ============================================
  // FETCH METHODS
  // ============================================

  /// Fetch bills from cloud
  Future<List<Map<String, dynamic>>> fetchBills() async {
    try {
      final response = await client
          .from('bills')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching bills: $e');
      rethrow;
    }
  }

  /// Fetch bill items for a specific bill
  Future<List<Map<String, dynamic>>> fetchBillItems(String billId) async {
    try {
      final response =
          await client.from('bill_items').select().eq('bill_id', billId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching bill items: $e');
      rethrow;
    }
  }

  /// Fetch payment history
  Future<List<Map<String, dynamic>>> fetchPaymentHistory() async {
    try {
      final response = await client
          .from('payment_history')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching payment history: $e');
      rethrow;
    }
  }

  // ============================================
  // CONNECTION & HEALTH CHECK
  // ============================================

  /// Check connection status
  Future<bool> isConnected() async {
    try {
      await client.from('bills').select().limit(1);
      return true;
    } catch (e) {
      debugPrint('Connection check failed: $e');
      return false;
    }
  }

  /// Test database connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final startTime = DateTime.now();
      await client.from('bills').select().limit(1);
      final endTime = DateTime.now();
      final latency = endTime.difference(startTime).inMilliseconds;

      return {
        'success': true,
        'latency': latency,
        'message': 'Connected successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Connection failed',
      };
    }
  }
}
