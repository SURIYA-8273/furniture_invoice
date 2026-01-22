import '../../entities/customer_entity.dart';
import '../../repositories/customer_repository.dart';

/// Use case for adding a new customer.
class AddCustomer {
  final CustomerRepository repository;

  AddCustomer(this.repository);

  Future<void> call(CustomerEntity customer) async {
    // Validate customer name
    if (customer.name.trim().isEmpty) {
      throw Exception('Customer name is required');
    }

    if (customer.name.trim().length < 2) {
      throw Exception('Customer name must be at least 2 characters');
    }

    // Update the updatedAt timestamp
    final updatedCustomer = customer.copyWith(
      updatedAt: DateTime.now(),
    );

    await repository.addCustomer(updatedCustomer);
  }
}
