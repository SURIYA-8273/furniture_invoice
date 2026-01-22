import '../../../core/utils/validation_utils.dart';
import '../../entities/product_entity.dart';
import '../../repositories/product_repository.dart';

/// Update Product Use Case
/// Validates and updates an existing product
class UpdateProduct {
  final ProductRepository repository;

  UpdateProduct(this.repository);

  Future<void> call(ProductEntity product) async {
    // Validate product name
    final nameError = ValidationUtils.validateProductName(product.name);
    if (nameError != null) {
      throw Exception(nameError);
    }

    // Validate MRP
    final mrpError = ValidationUtils.validateMRP(product.mrp);
    if (mrpError != null) {
      throw Exception(mrpError);
    }

    return repository.updateProduct(product);
  }
}
