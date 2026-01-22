import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/product_provider.dart';

/// Product Form Screen
/// Add or edit product details
class ProductFormScreen extends StatefulWidget {
  final ProductEntity? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mrpController = TextEditingController();
  final _sizeController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _mrpController.text = widget.product!.mrp.toString();
      _sizeController.text = widget.product!.size ?? '';
      _categoryController.text = widget.product!.category ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mrpController.dispose();
    _sizeController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ProductProvider>();

    final now = DateTime.now();
    final product = ProductEntity(
      id: widget.product?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      mrp: double.parse(_mrpController.text.trim()),
      size: _sizeController.text.trim().isEmpty ? null : _sizeController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
    );

    final success = widget.product == null
        ? await provider.addProduct(product)
        : await provider.updateProduct(product);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null
                ? l10n.productAddedSuccessfully
                : l10n.productUpdatedSuccessfully,
          ),
          backgroundColor: ThemeTokens.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? l10n.errorSavingProduct),
          backgroundColor: ThemeTokens.errorColor,
        ),
      );
    }
  }

  Future<void> _deleteProduct() async {
    if (widget.product == null) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProduct),
        content: Text(l10n.deleteProductConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: ThemeTokens.errorColor),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<ProductProvider>();
    final success = await provider.deleteProduct(widget.product!.id);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.productDeletedSuccessfully),
          backgroundColor: ThemeTokens.successColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? l10n.errorDeletingProduct),
          backgroundColor: ThemeTokens.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editProduct : l10n.addProduct),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteProduct,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(ThemeTokens.spacingMd),
          children: [
            // Product Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.productName,
                hintText: l10n.enterProductName,
                prefixIcon: const Icon(Icons.inventory_2),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.productNameRequired;
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            SizedBox(height: ThemeTokens.spacingMd),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.enterDescription,
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              enabled: !_isLoading,
            ),
            SizedBox(height: ThemeTokens.spacingMd),

            // MRP
            TextFormField(
              controller: _mrpController,
              decoration: InputDecoration(
                labelText: l10n.mrp,
                hintText: l10n.enterMRP,
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.mrpRequired;
                }
                final mrp = double.tryParse(value.trim());
                if (mrp == null || mrp <= 0) {
                  return l10n.invalidMRP;
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            SizedBox(height: ThemeTokens.spacingMd),

            // Size
            TextFormField(
              controller: _sizeController,
              decoration: InputDecoration(
                labelText: l10n.size,
                hintText: l10n.enterSize,
                prefixIcon: const Icon(Icons.straighten),
              ),
              enabled: !_isLoading,
            ),
            SizedBox(height: ThemeTokens.spacingMd),

            // Category
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: l10n.category,
                hintText: l10n.enterCategory,
                prefixIcon: const Icon(Icons.category),
              ),
              enabled: !_isLoading,
            ),
            SizedBox(height: ThemeTokens.spacingXl),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: ThemeTokens.spacingMd),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? l10n.updateProduct : l10n.addProduct),
            ),
          ],
        ),
      ),
    );
  }
}
