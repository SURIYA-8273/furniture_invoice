import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

/// Get Products By Category Use Case
class GetProductsByCategory {
  final ProductRepository repository;

  GetProductsByCategory(this.repository);

  Future<List<ProductEntity>> call(String category) => repository.getProductsByCategory(category);
}
