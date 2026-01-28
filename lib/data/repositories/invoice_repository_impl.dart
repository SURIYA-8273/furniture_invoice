import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_box_names.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../models/invoice_model.dart';
import '../models/payment_history_model.dart';

/// Implementation of Invoice Repository using Hive.
class InvoiceRepositoryImpl implements InvoiceRepository {
  Box<InvoiceModel> get _box => Hive.box<InvoiceModel>(HiveBoxNames.invoices);

  @override
  Future<List<InvoiceEntity>> getAllInvoices() async {
    try {
      final invoices = _box.values
          .map((model) => model.toEntity())
          .toList();

      // Sort by creation date (newest first) - source of truth for bill history
      invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return invoices;
    } catch (e, stackTrace) {
      debugPrint('DEBUG: Error in getAllInvoices: $e');
      debugPrint('DEBUG: StackTrace: $stackTrace');
      debugPrint('Syncing all bills to Supabase...');
      // Note: invoices.length is not available here as the try block failed.
      // This line would cause an error if placed here.
      // debugPrint('Found ${invoices.length} invoices in local storage');
      throw Exception('Failed to get invoices: $e');
    }
  }

  @override
  Future<InvoiceEntity?> getInvoiceById(String id) async {
    try {
      final model = _box.get(id);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to get invoice: $e');
    }
  }

  @override
  Future<List<InvoiceEntity>> searchInvoices(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllInvoices();
      }

      final lowerQuery = query.toLowerCase();
      final invoices = _box.values
          .where((model) {
            final numberMatch = model.invoiceNumber.toLowerCase().contains(lowerQuery);
            final nameMatch = model.customerName != null && model.customerName!.toLowerCase().contains(lowerQuery);
            return numberMatch || nameMatch;
          })
          .map((model) => model.toEntity())
          .toList();

      // Sort by creation date
      invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return invoices;
    } catch (e) {
      throw Exception('Failed to search invoices: $e');
    }
  }

  @override
  Future<void> addInvoice(InvoiceEntity invoice) async {
    try {
      final model = InvoiceModel.fromEntity(invoice);
      await _box.put(invoice.id, model);
    } catch (e) {
      throw Exception('Failed to add invoice: $e');
    }
  }

  @override
  Future<void> updateInvoice(InvoiceEntity invoice) async {
    try {
      final model = InvoiceModel.fromEntity(invoice);
      await _box.put(invoice.id, model);
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  @override
  Future<void> deleteInvoice(String id) async {
    try {
      // 1. Delete associated payments first
      final paymentBox = Hive.box<PaymentHistoryModel>(HiveBoxNames.paymentHistory);
      final paymentKeysToDelete = paymentBox.keys.where((key) {
        final payment = paymentBox.get(key);
        return payment?.invoiceId == id;
      }).toList();
      
      for (var key in paymentKeysToDelete) {
        await paymentBox.delete(key);
      }
      
      // 2. Delete the invoice
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete invoice and its payments: $e');
    }
  }

  @override
  Future<List<InvoiceEntity>> getUnpaidInvoices() async {
    try {
      final invoices = _box.values
          .map((model) => model.toEntity())
          .where((invoice) => invoice.hasPendingBalance)
          .toList();

      // Sort by creation date
      invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return invoices;
    } catch (e) {
      throw Exception('Failed to get unpaid invoices: $e');
    }
  }

  @override
  Future<int> getNextInvoiceNumber() async {
    try {
      // Retrieve all invoices
      final invoices = _box.values;

      if (invoices.isEmpty) {
        return 1001; // Start from 1001
      }

      int maxNumber = 1000;

      for (var model in invoices) {
        // Assume format is PREFIX-NUMBER or just NUMBER 
        // We will try to extract the last sequence of digits
        final numberPart = model.invoiceNumber.split('-').last;
        final number = int.tryParse(numberPart);
        
        if (number != null) {
          if (number > maxNumber) {
            maxNumber = number;
          }
        }
      }

      return maxNumber + 1;
    } catch (e) {
      // If error, fallback safe
      return 1001;
    }
  }

  @override
  Future<InvoiceEntity?> getInvoiceByNumber(String invoiceNumber) async {
    try {
      final invoices = _box.values;
      try {
        final match = invoices.firstWhere(
            (model) => model.invoiceNumber == invoiceNumber);
        return match.toEntity();
      } catch (e) {
        return null; // Not found
      }
    } catch (e) {
      throw Exception('Failed to get invoice by number: $e');
    }
  }
}
