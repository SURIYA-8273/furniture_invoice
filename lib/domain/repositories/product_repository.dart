import '../entities/product_entity.dart';

/// Product Repository Interface
/// Defines the contract for product data operations
abstract class ProductRepository {
  /// Get all products
  Future<List<ProductEntity>> getAllProducts();

  /// Search products by name or category
  Future<List<ProductEntity>> searchProducts(String query);

  /// Get product by ID
  Future<ProductEntity?> getProductById(String id);

  /// Add a new product
  Future<void> addProduct(ProductEntity product);

  /// Update an existing product
  Future<void> updateProduct(ProductEntity product);

  /// Delete a product
  Future<void> deleteProduct(String id);

  /// Get products by category
  Future<List<ProductEntity>> getProductsByCategory(String category);
}
