import 'package:hive/hive.dart';
import '../../core/constants/hive_box_names.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

/// Product Repository Implementation
/// Implements product data operations using Hive for local storage
class ProductRepositoryImpl implements ProductRepository {
  Box<ProductModel> get _box => Hive.box<ProductModel>(HiveBoxNames.products);

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    try {
      final products = _box.values.toList();
      // Sort by name
      products.sort((a, b) => a.name.compareTo(b.name));
      return products.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        return getAllProducts();
      }

      final products = _box.values.where((product) {
        final searchLower = query.toLowerCase();
        return product.name.toLowerCase().contains(searchLower) ||
            (product.description?.toLowerCase().contains(searchLower) ?? false) ||
            (product.category?.toLowerCase().contains(searchLower) ?? false);
      }).toList();

      products.sort((a, b) => a.name.compareTo(b.name));
      return products.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    try {
      final model = _box.get(id);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      await _box.put(product.id, model);
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      await _box.put(product.id, model);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    try {
      final products = _box.values.where((product) {
        return product.category?.toLowerCase() == category.toLowerCase();
      }).toList();

      products.sort((a, b) => a.name.compareTo(b.name));
      return products.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }
}
