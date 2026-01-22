import '../../entities/customer_entity.dart';
import '../../repositories/customer_repository.dart';

/// Use case for searching customers by name or phone.
class SearchCustomers {
  final CustomerRepository repository;

  SearchCustomers(this.repository);

  Future<List<CustomerEntity>> call(String query) async {
    return await repository.searchCustomers(query);
  }
}
