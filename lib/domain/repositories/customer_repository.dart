import '../../domain/entities/customer_entity.dart';

/// Repository interface for Customer operations.
/// Defines the contract for data access.
abstract class CustomerRepository {
  /// Get all customers
  Future<List<CustomerEntity>> getAllCustomers();

  /// Get customer by ID
  Future<CustomerEntity?> getCustomerById(String id);

  /// Search customers by name or phone
  Future<List<CustomerEntity>> searchCustomers(String query);

  /// Add a new customer
  Future<void> addCustomer(CustomerEntity customer);

  /// Update existing customer
  Future<void> updateCustomer(CustomerEntity customer);

  /// Delete customer
  Future<void> deleteCustomer(String id);

  /// Update customer balance (after invoice or payment)
  Future<void> updateCustomerBalance({
    required String customerId,
    required double billedAmount,
    required double paidAmount,
  });

  /// Get customers with pending dues
  Future<List<CustomerEntity>> getCustomersWithDues();

  /// Get total outstanding balance across all customers
  Future<double> getTotalOutstandingBalance();
}
