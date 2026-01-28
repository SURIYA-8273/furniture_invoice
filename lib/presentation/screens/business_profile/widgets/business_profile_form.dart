import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../core/utils/validation_utils.dart';
import '../../../../l10n/app_localizations.dart';

class BusinessProfileForm extends StatelessWidget {
  final TextEditingController businessNameController;
  final TextEditingController primaryPhoneController;
  final TextEditingController businessAddressController;
  final TextEditingController businessNameTamilController;
  final TextEditingController businessAddressTamilController;

  const BusinessProfileForm({
    super.key,
    required this.businessNameController,
    required this.primaryPhoneController,
    required this.businessAddressController,
    required this.businessNameTamilController,
    required this.businessAddressTamilController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        SizedBox(height: ThemeTokens.spacingLg),

        // Business Name (Required)
        TextFormField(
          controller: businessNameController,
          decoration: InputDecoration(
            labelText: '${l10n.businessName} *',
            hintText: l10n.required,
            prefixIcon: const Icon(Icons.business_center),
          ),
          validator: ValidationUtils.validateBusinessName,
          textCapitalization: TextCapitalization.words,
        ),

        SizedBox(height: ThemeTokens.spacingMd),

        // Business Name (Tamil) - Required
        TextFormField(
          controller: businessNameTamilController,
          decoration: InputDecoration(
            labelText: '${l10n.businessNameTamil} *',
            hintText: l10n.required,
            prefixIcon: const Icon(Icons.language),
          ),
          validator: (value) => ValidationUtils.validateRequired(value, l10n.businessNameTamil),
        ),

        SizedBox(height: ThemeTokens.spacingMd),

        // Primary Phone (Required)
        TextFormField(
          controller: primaryPhoneController,
          decoration: InputDecoration(
            labelText: '${l10n.primaryPhone} *',
            hintText: '9876543210',
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) => ValidationUtils.validatePhoneNumber(value, required: true),
        ),

        SizedBox(height: ThemeTokens.spacingMd),

        // Business Address (Required)
        TextFormField(
          controller: businessAddressController,
          decoration: InputDecoration(
            labelText: '${l10n.businessAddress} *',
            hintText: l10n.businessAddress,
            prefixIcon: const Icon(Icons.location_on),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) => value == null || value.trim().isEmpty ? l10n.required : null,
        ),

        SizedBox(height: ThemeTokens.spacingMd),

        // Business Address (Tamil) - Required
        TextFormField(
          controller: businessAddressTamilController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '${l10n.businessAddressTamil} *',
            hintText: l10n.required,
            prefixIcon: const Icon(Icons.location_city),
          ),
          validator: (value) => ValidationUtils.validateRequired(value, l10n.businessAddressTamil),
        ),

        SizedBox(height: ThemeTokens.spacingXl),
      ],
    );
  }
}
