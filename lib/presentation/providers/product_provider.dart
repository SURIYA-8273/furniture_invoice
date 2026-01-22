import 'package:flutter/foundation.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/product/get_all_products.dart';
import '../../domain/usecases/product/search_products.dart';
import '../../domain/usecases/product/add_product.dart';
import '../../domain/usecases/product/update_product.dart';
import '../../domain/usecases/product/delete_product.dart';
import '../../domain/usecases/product/get_products_by_category.dart';

/// Product Provider
/// Manages product state and operations
class ProductProvider with ChangeNotifier {
  final GetAllProducts getAllProductsUseCase;
  final SearchProducts searchProductsUseCase;
  final AddProduct addProductUseCase;
  final UpdateProduct updateProductUseCase;
  final DeleteProduct deleteProductUseCase;
  final GetProductsByCategory getProductsByCategoryUseCase;

  ProductProvider({
    required this.getAllProductsUseCase,
    required this.searchProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.getProductsByCategoryUseCase,
  });

  // State
  List<ProductEntity> _products = [];
  List<ProductEntity> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<ProductEntity> get products => _filteredProducts.isEmpty && _searchQuery.isEmpty
      ? _products
      : _filteredProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  /// Initialize provider
  Future<void> initialize() async {
    await loadProducts();
  }

  /// Load all products
  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await getAllProductsUseCase();
      _filteredProducts = [];
      _searchQuery = '';
      _error = null;
    } catch (e) {
      _error = e.toString();
      _products = [];
      _filteredProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _filteredProducts = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _filteredProducts = await searchProductsUseCase(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _filteredProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredProducts = [];
    notifyListeners();
  }

  /// Add a new product
  Future<bool> addProduct(ProductEntity product) async {
    try {
      await addProductUseCase(product);
      await loadProducts(); // Reload to get updated list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update an existing product
  Future<bool> updateProduct(ProductEntity product) async {
    try {
      await updateProductUseCase(product);
      await loadProducts(); // Reload to get updated list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String id) async {
    try {
      await deleteProductUseCase(id);
      await loadProducts(); // Reload to get updated list
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get products by category
  Future<List<ProductEntity>> getProductsByCategory(String category) async {
    try {
      return await getProductsByCategoryUseCase(category);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
