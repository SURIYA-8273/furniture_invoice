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
            return numberMatch;
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
}
