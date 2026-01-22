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

  /// Sync customers to cloud
  Future<void> syncCustomers(List<Map<String, dynamic>> customers) async {
    try {
      for (final customer in customers) {
        await client
            .from('customers')
            .upsert(customer, onConflict: 'id');
      }
      debugPrint('Synced ${customers.length} customers to cloud');
    } catch (e) {
      debugPrint('Error syncing customers: $e');
      rethrow;
    }
  }

  /// Sync invoices to cloud
  Future<void> syncInvoices(List<Map<String, dynamic>> invoices) async {
    try {
      for (final invoice in invoices) {
        await client
            .from('invoices')
            .upsert(invoice, onConflict: 'id');
      }
      debugPrint('Synced ${invoices.length} invoices to cloud');
    } catch (e) {
      debugPrint('Error syncing invoices: $e');
      rethrow;
    }
  }

  /// Sync payments to cloud
  Future<void> syncPayments(List<Map<String, dynamic>> payments) async {
    try {
      for (final payment in payments) {
        await client
            .from('payments')
            .upsert(payment, onConflict: 'id');
      }
      debugPrint('Synced ${payments.length} payments to cloud');
    } catch (e) {
      debugPrint('Error syncing payments: $e');
      rethrow;
    }
  }

  /// Fetch customers from cloud
  Future<List<Map<String, dynamic>>> fetchCustomers() async {
    try {
      final response = await client
          .from('customers')
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching customers: $e');
      rethrow;
    }
  }

  /// Fetch invoices from cloud
  Future<List<Map<String, dynamic>>> fetchInvoices() async {
    try {
      final response = await client
          .from('invoices')
          .select()
          .order('invoice_date', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching invoices: $e');
      rethrow;
    }
  }

  /// Check connection status
  Future<bool> isConnected() async {
    try {
      await client.from('customers').select().limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Perform full sync (upload local data to cloud)
  Future<void> performFullSync({
    required List<Map<String, dynamic>> customers,
    required List<Map<String, dynamic>> invoices,
    required List<Map<String, dynamic>> payments,
  }) async {
    try {
      await syncCustomers(customers);
      await syncInvoices(invoices);
      await syncPayments(payments);
      debugPrint('Full sync completed successfully');
    } catch (e) {
      debugPrint('Error during full sync: $e');
      rethrow;
    }
  }
}
