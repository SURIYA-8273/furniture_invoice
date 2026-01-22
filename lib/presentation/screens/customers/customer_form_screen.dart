import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../providers/customer_provider.dart';

class CustomerFormScreen extends StatefulWidget {
  final CustomerEntity? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();

  bool get isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone ?? '';
      _addressController.text = widget.customer!.address ?? '';
      _emailController.text = widget.customer!.email ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CustomerProvider>();
    final success = isEditing
        ? await provider.updateCustomer(
            id: widget.customer!.id,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          )
        : await provider.addCustomer(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
            email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.success),
            backgroundColor: ThemeTokens.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to save customer'),
            backgroundColor: ThemeTokens.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editCustomer : l10n.addCustomer),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCustomer,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(ThemeTokens.spacingMd),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${l10n.customerName} *',
                prefixIcon: const Icon(Icons.person),
              ),
              validator: ValidationUtils.validateCustomerName,
              textCapitalization: TextCapitalization.words,
            ),
            SizedBox(height: ThemeTokens.spacingMd),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: '${l10n.phoneNumber} (${l10n.optional})',
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => ValidationUtils.validatePhoneNumber(value, required: false),
            ),
            SizedBox(height: ThemeTokens.spacingMd),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '${l10n.email} (${l10n.optional})',
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => ValidationUtils.validateEmail(value, required: false),
            ),
            SizedBox(height: ThemeTokens.spacingMd),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: '${l10n.address} (${l10n.optional})',
                prefixIcon: const Icon(Icons.location_on),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: ThemeTokens.spacingXl),
            ElevatedButton.icon(
              onPressed: _saveCustomer,
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
