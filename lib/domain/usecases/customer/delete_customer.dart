import '../../repositories/customer_repository.dart';

/// Use case for deleting a customer.
class DeleteCustomer {
  final CustomerRepository repository;

  DeleteCustomer(this.repository);

  Future<void> call(String customerId) async {
    if (customerId.trim().isEmpty) {
      throw Exception('Customer ID is required');
    }

    await repository.deleteCustomer(customerId);
  }
}
