import '../../entities/customer_entity.dart';
import '../../repositories/customer_repository.dart';

/// Use case for getting all customers.
class GetAllCustomers {
  final CustomerRepository repository;

  GetAllCustomers(this.repository);

  Future<List<CustomerEntity>> call() async {
    return await repository.getAllCustomers();
  }
}
