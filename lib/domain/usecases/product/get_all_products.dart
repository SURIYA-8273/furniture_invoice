import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

/// Get All Products Use Case
class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<List<ProductEntity>> call() => repository.getAllProducts();
}
