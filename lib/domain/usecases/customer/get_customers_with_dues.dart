import '../../entities/customer_entity.dart';
import '../../repositories/customer_repository.dart';

/// Use case for getting customers with pending dues.
class GetCustomersWithDues {
  final CustomerRepository repository;

  GetCustomersWithDues(this.repository);

  Future<List<CustomerEntity>> call() async {
    return await repository.getCustomersWithDues();
  }
}
