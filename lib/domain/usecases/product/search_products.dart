import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

/// Search Products Use Case
class SearchProducts {
  final ProductRepository repository;

  SearchProducts(this.repository);

  Future<List<ProductEntity>> call(String query) => repository.searchProducts(query);
}
