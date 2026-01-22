import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/customer/get_all_customers.dart';
import '../../domain/usecases/customer/search_customers.dart';
import '../../domain/usecases/customer/add_customer.dart';
import '../../domain/usecases/customer/update_customer.dart';
import '../../domain/usecases/customer/delete_customer.dart';
import '../../domain/usecases/customer/get_customers_with_dues.dart';

/// Provider for managing customer state.
/// Handles CRUD operations and balance tracking for customers.
class CustomerProvider extends ChangeNotifier {
  final GetAllCustomers getAllCustomersUseCase;
  final SearchCustomers searchCustomersUseCase;
  final AddCustomer addCustomerUseCase;
  final UpdateCustomer updateCustomerUseCase;
  final DeleteCustomer deleteCustomerUseCase;
  final GetCustomersWithDues getCustomersWithDuesUseCase;

  List<CustomerEntity> _customers = [];
  List<CustomerEntity> _filteredCustomers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  CustomerProvider({
    required this.getAllCustomersUseCase,
    required this.searchCustomersUseCase,
    required this.addCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.deleteCustomerUseCase,
    required this.getCustomersWithDuesUseCase,
  });

  // Getters
  List<CustomerEntity> get customers => _filteredCustomers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get customerCount => _customers.length;
  String get searchQuery => _searchQuery;

  /// Initialize and load customers
  Future<void> initialize() async {
    await loadCustomers();
  }

  /// Load all customers from repository
  Future<void> loadCustomers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _customers = await getAllCustomersUseCase();
      _filteredCustomers = _customers;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading customers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search customers by name or phone
  Future<void> searchCustomers(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _filteredCustomers = _customers;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _filteredCustomers = await searchCustomersUseCase(query);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error searching customers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new customer
  Future<bool> addCustomer({
    required String name,
    String? phone,
    String? address,
    String? email,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final now = DateTime.now();
      final customer = CustomerEntity(
        id: const Uuid().v4(),
        name: name,
        phone: phone,
        address: address,
        email: email,
        totalBilled: 0.0,
        totalPaid: 0.0,
        createdAt: now,
        updatedAt: now,
      );

      await addCustomerUseCase(customer);
      await loadCustomers(); // Reload to get updated list

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error adding customer: $e');
      return false;
    }
  }

  /// Update an existing customer
  Future<bool> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? address,
    String? email,
    double? totalBilled,
    double? totalPaid,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Find existing customer to preserve balance if not provided
      final existingCustomer = _customers.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Customer not found'),
      );

      final customer = CustomerEntity(
        id: id,
        name: name,
        phone: phone,
        address: address,
        email: email,
        totalBilled: totalBilled ?? existingCustomer.totalBilled,
        totalPaid: totalPaid ?? existingCustomer.totalPaid,
        createdAt: existingCustomer.createdAt,
        updatedAt: DateTime.now(),
      );

      await updateCustomerUseCase(customer);
      await loadCustomers(); // Reload to get updated list

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating customer: $e');
      return false;
    }
  }

  /// Delete a customer
  Future<bool> deleteCustomer(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await deleteCustomerUseCase(id);
      await loadCustomers(); // Reload to get updated list

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error deleting customer: $e');
      return false;
    }
  }

  /// Get customer by ID
  CustomerEntity? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get customers with pending dues
  Future<List<CustomerEntity>> getCustomersWithDues() async {
    try {
      return await getCustomersWithDuesUseCase();
    } catch (e) {
      debugPrint('Error getting customers with dues: $e');
      return [];
    }
  }

  /// Get total outstanding balance across all customers
  double getTotalOutstandingBalance() {
    double total = 0.0;
    for (final customer in _customers) {
      total += customer.outstandingBalance;
    }
    return total;
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredCustomers = _customers;
    notifyListeners();
  }
}
