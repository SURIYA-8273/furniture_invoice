import '../entities/invoice_entity.dart';

/// Repository interface for invoice operations
abstract class InvoiceRepository {
  /// Get all invoices
  Future<List<InvoiceEntity>> getAllInvoices();

  /// Get a specific invoice by ID
  Future<InvoiceEntity?> getInvoiceById(String id);

  /// Search invoices by number or customer name
  Future<List<InvoiceEntity>> searchInvoices(String query);

  /// Add a new invoice
  Future<void> addInvoice(InvoiceEntity invoice);

  /// Update an existing invoice
  Future<void> updateInvoice(InvoiceEntity invoice);

  /// Delete an invoice
  Future<void> deleteInvoice(String id);

  /// Get invoices with pending balance
  Future<List<InvoiceEntity>> getUnpaidInvoices();
}
