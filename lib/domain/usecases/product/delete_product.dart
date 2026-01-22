import '../../repositories/product_repository.dart';

/// Delete Product Use Case
class DeleteProduct {
  final ProductRepository repository;

  DeleteProduct(this.repository);

  Future<void> call(String id) async {
    if (id.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }
    return repository.deleteProduct(id);
  }
}
