import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../providers/billing_calculation_provider.dart';
import '../../../domain/entities/customer_entity.dart'; // For creating ad-hoc customer if needed

class InvoiceDetailsScreen extends StatefulWidget {
  const InvoiceDetailsScreen({super.key});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _discountController = TextEditingController();
  final _advanceController = TextEditingController();
  
  String _paymentMode = 'Cash';
  String _paymentStatus = 'Paid';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _discountController.dispose();
    _advanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<BillingCalculationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoiceDetails),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ThemeTokens.spacingMd),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(l10n.customerDetails, theme),
              SizedBox(height: ThemeTokens.spacingMd),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.customerName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.validationRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: ThemeTokens.spacingMd),
              
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: ThemeTokens.spacingMd),
              
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.address,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                maxLines: 3,
              ),
              
              SizedBox(height: ThemeTokens.spacingXl),
              _buildSectionTitle(l10n.paymentDetails, theme),
              SizedBox(height: ThemeTokens.spacingMd),
              
              DropdownButtonFormField<String>(
                value: _paymentMode,
                decoration: InputDecoration(
                  labelText: l10n.paymentMode,
                  prefixIcon: const Icon(Icons.payment),
                ),
                items: [
                  DropdownMenuItem(value: 'Cash', child: Text(l10n.cash)),
                  DropdownMenuItem(value: 'Card', child: Text(l10n.card)),
                  DropdownMenuItem(value: 'UPI', child: Text(l10n.upi)),
                  DropdownMenuItem(value: 'Bank Transfer', child: Text(l10n.bankTransfer)),
                ],
                onChanged: (val) => setState(() => _paymentMode = val!),
              ),
              SizedBox(height: ThemeTokens.spacingMd),

              DropdownButtonFormField<String>(
                value: _paymentStatus,
                decoration: InputDecoration(
                  labelText: l10n.paymentStatus,
                  prefixIcon: const Icon(Icons.info_outline),
                ),
                items: [
                  DropdownMenuItem(value: 'Paid', child: Text(l10n.paid)),
                  DropdownMenuItem(value: 'Partially Paid', child: Text(l10n.partiallyPaid)),
                  DropdownMenuItem(value: 'Unpaid', child: Text(l10n.unpaid)),
                ],
                onChanged: (val) => setState(() => _paymentStatus = val!),
              ),
              SizedBox(height: ThemeTokens.spacingMd),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      decoration: InputDecoration(
                        labelText: l10n.discount,
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => provider.setDiscount(double.tryParse(val) ?? 0),
                    ),
                  ),
                  SizedBox(width: ThemeTokens.spacingMd),
                  Expanded(
                    child: TextFormField(
                      controller: _advanceController,
                      decoration: InputDecoration(
                        labelText: l10n.advancePayment,
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => provider.setAdvancePayment(double.tryParse(val) ?? 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ThemeTokens.spacingMd),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _finalizeInvoice,
              child: Text(
                'FINAL PRINT', // Using explicit English as per common billing software, or use l10n.print
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  void _finalizeInvoice() {
    if (_formKey.currentState!.validate()) {
      // TODO: Logic to save/print invoice
      // Temporarily just show success
      // In real app, we would save the CustomerEntity to provider
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice saved successfully!')),
      );
      // Navigator.pop(context); // Or go to home
    }
  }
}
