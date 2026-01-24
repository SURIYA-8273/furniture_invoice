import 'package:flutter/material.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/repositories/invoice_repository.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceRepository invoiceRepository;

  List<InvoiceEntity> _invoices = [];
  bool _isLoading = false;
  String? _error;

  InvoiceProvider({required this.invoiceRepository});

  List<InvoiceEntity> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<InvoiceEntity> get unpaidInvoices =>
      _invoices.where((inv) => inv.hasPendingBalance).toList();
  
  List<InvoiceEntity> get paidInvoices =>
      _invoices.where((inv) => inv.isFullyPaid).toList();

  Future<void> loadInvoices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _invoices = await invoiceRepository.getAllInvoices();
    } catch (e) {
      _error = 'Failed to load invoices: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchInvoices(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _invoices = await invoiceRepository.searchInvoices(query);
    } catch (e) {
      _error = 'Failed to search invoices: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addInvoice(InvoiceEntity invoice) async {
    _isLoading = true;
    notifyListeners();

    try {
      await invoiceRepository.addInvoice(invoice);
      _invoices.insert(0, invoice);
      _invoices.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
    } catch (e) {
      _error = 'Failed to add invoice: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInvoice(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await invoiceRepository.deleteInvoice(id);
      _invoices.removeWhere((inv) => inv.id == id);
    } catch (e) {
      _error = 'Failed to delete invoice: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> getNextInvoiceNumber() async {
    try {
      return await invoiceRepository.getNextInvoiceNumber();
    } catch (e) {
      _error = 'Failed to get next invoice number: $e';
      notifyListeners();
      return 1001; // Fallback
    }
  }

  Future<InvoiceEntity?> getInvoiceByNumber(String invoiceNumber) async {
    try {
      return await invoiceRepository.getInvoiceByNumber(invoiceNumber);
    } catch (e) {
      _error = 'Failed to get invoice by number: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> updateInvoice(InvoiceEntity invoice) async {
    _isLoading = true;
    notifyListeners();

    try {
      await invoiceRepository.updateInvoice(invoice);
      final index = _invoices.indexWhere((inv) => inv.id == invoice.id);
      if (index != -1) {
        _invoices[index] = invoice;
      }
    } catch (e) {
      _error = 'Failed to update invoice: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
