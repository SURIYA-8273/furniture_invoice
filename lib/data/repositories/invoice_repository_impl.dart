import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_box_names.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../models/invoice_model.dart';

/// Implementation of Invoice Repository using Hive.
class InvoiceRepositoryImpl implements InvoiceRepository {
  Box get _box => Hive.box(HiveBoxNames.invoices);

  @override
  Future<List<InvoiceEntity>> getAllInvoices() async {
    try {
      final invoices = _box.values
          .cast<InvoiceModel>()
          .map((model) => model.toEntity())
          .toList();

      // Sort by date (newest first)
      invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));

      return invoices;
    } catch (e) {
      throw Exception('Failed to get invoices: $e');
    }
  }

  @override
  Future<InvoiceEntity?> getInvoiceById(String id) async {
    try {
      final model = _box.get(id) as InvoiceModel?;
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
          .cast<InvoiceModel>()
          .where((model) {
            final numberMatch = model.invoiceNumber.toLowerCase().contains(lowerQuery);
            final nameMatch = model.customerName != null && model.customerName!.toLowerCase().contains(lowerQuery);
            return numberMatch || nameMatch;
          })
          .map((model) => model.toEntity())
          .toList();

      // Sort by date
      invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));

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
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete invoice: $e');
    }
  }

  @override
  Future<List<InvoiceEntity>> getUnpaidInvoices() async {
    try {
      final invoices = _box.values
          .cast<InvoiceModel>()
          .map((model) => model.toEntity())
          .where((invoice) => invoice.hasPendingBalance)
          .toList();

      // Sort by date
      invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));

      return invoices;
    } catch (e) {
      throw Exception('Failed to get unpaid invoices: $e');
    }
  }

  @override
  Future<int> getNextInvoiceNumber() async {
    try {
      // Retrieve all invoices
      final invoices = _box.values.cast<InvoiceModel>();

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
      final invoices = _box.values.cast<InvoiceModel>();
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
