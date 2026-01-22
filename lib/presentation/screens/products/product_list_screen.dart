import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/product_provider.dart';
import 'product_form_screen.dart';

/// Product List Screen
/// Displays all products with search functionality
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.products),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options (by category)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(ThemeTokens.spacingMd),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchProducts,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductProvider>().clearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                context.read<ProductProvider>().searchProducts(value);
              },
            ),
          ),

          // Product List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: ThemeTokens.errorColor),
                        SizedBox(height: ThemeTokens.spacingMd),
                        Text(provider.error!),
                        SizedBox(height: ThemeTokens.spacingMd),
                        ElevatedButton(
                          onPressed: () => provider.loadProducts(),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        SizedBox(height: ThemeTokens.spacingMd),
                        Text(
                          l10n.noProductsFound,
                          style: theme.textTheme.titleMedium,
                        ),
                        SizedBox(height: ThemeTokens.spacingSm),
                        Text(
                          l10n.addYourFirstProduct,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(ThemeTokens.spacingMd),
                  itemCount: provider.products.length,
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: ThemeTokens.spacingMd),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.inventory_2,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.description != null)
                              Text(
                                product.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            SizedBox(height: ThemeTokens.spacingXs),
                            Row(
                              children: [
                                if (product.category != null) ...[
                                  Chip(
                                    label: Text(
                                      product.category!,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  SizedBox(width: ThemeTokens.spacingSm),
                                ],
                                if (product.size != null)
                                  Text(
                                    '${l10n.size}: ${product.size}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${product.mrp.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              l10n.mrp,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductFormScreen(product: product),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addProduct),
      ),
    );
  }
}
