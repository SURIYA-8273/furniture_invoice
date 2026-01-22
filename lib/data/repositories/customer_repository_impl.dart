import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_box_names.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';

/// Implementation of Customer Repository using Hive.
/// Handles local storage of customer data.
class CustomerRepositoryImpl implements CustomerRepository {
  Box get _box => Hive.box(HiveBoxNames.customers);

  @override
  Future<List<CustomerEntity>> getAllCustomers() async {
    try {
      final customers = _box.values
          .cast<CustomerModel>()
          .map((model) => model.toEntity())
          .toList();

      // Sort by name
      customers.sort((a, b) => a.name.compareTo(b.name));

      return customers;
    } catch (e) {
      throw Exception('Failed to get customers: $e');
    }
  }

  @override
  Future<CustomerEntity?> getCustomerById(String id) async {
    try {
      final model = _box.get(id) as CustomerModel?;
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to get customer: $e');
    }
  }

  @override
  Future<List<CustomerEntity>> searchCustomers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllCustomers();
      }

      final lowerQuery = query.toLowerCase();
      final customers = _box.values
          .cast<CustomerModel>()
          .where((model) {
            final nameMatch = model.name.toLowerCase().contains(lowerQuery);
            final phoneMatch = model.phone?.toLowerCase().contains(lowerQuery) ?? false;
            return nameMatch || phoneMatch;
          })
          .map((model) => model.toEntity())
          .toList();

      // Sort by name
      customers.sort((a, b) => a.name.compareTo(b.name));

      return customers;
    } catch (e) {
      throw Exception('Failed to search customers: $e');
    }
  }

  @override
  Future<void> addCustomer(CustomerEntity customer) async {
    try {
      final model = CustomerModel.fromEntity(customer);
      await _box.put(customer.id, model);
    } catch (e) {
      throw Exception('Failed to add customer: $e');
    }
  }

  @override
  Future<void> updateCustomer(CustomerEntity customer) async {
    try {
      final model = CustomerModel.fromEntity(customer);
      await _box.put(customer.id, model);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  @override
  Future<void> updateCustomerBalance({
    required String customerId,
    required double billedAmount,
    required double paidAmount,
  }) async {
    try {
      final model = _box.get(customerId) as CustomerModel?;
      if (model == null) {
        throw Exception('Customer not found');
      }

      final updatedModel = model.copyWith(
        totalBilled: model.totalBilled + billedAmount,
        totalPaid: model.totalPaid + paidAmount,
        updatedAt: DateTime.now(),
      );

      await _box.put(customerId, updatedModel);
    } catch (e) {
      throw Exception('Failed to update customer balance: $e');
    }
  }

  @override
  Future<List<CustomerEntity>> getCustomersWithDues() async {
    try {
      final customers = _box.values
          .cast<CustomerModel>()
          .map((model) => model.toEntity())
          .where((customer) => customer.hasPendingDues)
          .toList();

      // Sort by outstanding balance (highest first)
      customers.sort((a, b) => b.outstandingBalance.compareTo(a.outstandingBalance));

      return customers;
    } catch (e) {
      throw Exception('Failed to get customers with dues: $e');
    }
  }

  @override
  Future<double> getTotalOutstandingBalance() async {
    try {
      final customers = _box.values
          .cast<CustomerModel>()
          .map((model) => model.toEntity());

      double total = 0.0;
      for (final customer in customers) {
        total += customer.outstandingBalance;
      }

      return total;
    } catch (e) {
      throw Exception('Failed to get total outstanding balance: $e');
    }
  }
}
