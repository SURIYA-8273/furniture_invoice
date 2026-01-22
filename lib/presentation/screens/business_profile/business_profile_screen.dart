import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/business_profile_provider.dart';

/// Business Profile Screen
/// Allows users to create and edit their business profile.
class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _whatsappNumberController = TextEditingController();
  final _primaryPhoneController = TextEditingController();
  final _additionalPhoneController = TextEditingController();
  final _instagramIdController = TextEditingController();
  final _websiteUrlController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _businessAddressController = TextEditingController();

  String? _logoPath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final provider = context.read<BusinessProfileProvider>();
    final profile = provider.profile;

    if (profile != null) {
      _businessNameController.text = profile.businessName;
      _whatsappNumberController.text = profile.whatsappNumber ?? '';
      _primaryPhoneController.text = profile.primaryPhone ?? '';
      _additionalPhoneController.text = profile.additionalPhone ?? '';
      _instagramIdController.text = profile.instagramId ?? '';
      _websiteUrlController.text = profile.websiteUrl ?? '';
      _gstNumberController.text = profile.gstNumber ?? '';
      _businessAddressController.text = profile.businessAddress ?? '';
      _logoPath = profile.logoPath;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Save image to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'business_logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

        setState(() {
          _logoPath = savedImage.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<BusinessProfileProvider>();
    final success = await provider.saveProfile(
      businessName: _businessNameController.text.trim(),
      logoPath: _logoPath,
      whatsappNumber: _whatsappNumberController.text.trim().isEmpty
          ? null
          : _whatsappNumberController.text.trim(),
      primaryPhone: _primaryPhoneController.text.trim().isEmpty
          ? null
          : _primaryPhoneController.text.trim(),
      additionalPhone: _additionalPhoneController.text.trim().isEmpty
          ? null
          : _additionalPhoneController.text.trim(),
      instagramId: _instagramIdController.text.trim().isEmpty
          ? null
          : _instagramIdController.text.trim(),
      websiteUrl: _websiteUrlController.text.trim().isEmpty
          ? null
          : _websiteUrlController.text.trim(),
      gstNumber: _gstNumberController.text.trim().isEmpty
          ? null
          : _gstNumberController.text.trim(),
      businessAddress: _businessAddressController.text.trim().isEmpty
          ? null
          : _businessAddressController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.success),
            backgroundColor: ThemeTokens.successColor,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to save profile'),
            backgroundColor: ThemeTokens.errorColor,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _whatsappNumberController.dispose();
    _primaryPhoneController.dispose();
    _additionalPhoneController.dispose();
    _instagramIdController.dispose();
    _websiteUrlController.dispose();
    _gstNumberController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.businessProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: l10n.save,
          ),
        ],
      ),
      body: Consumer<BusinessProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(ThemeTokens.spacingMd),
              children: [
                // Logo Section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                            border: Border.all(
                              color: theme.colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: _logoPath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                                  child: Image.file(
                                    File(_logoPath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.business,
                                  size: ThemeTokens.iconSizeXLarge,
                                  color: theme.colorScheme.primary,
                                ),
                        ),
                      ),
                      SizedBox(height: ThemeTokens.spacingSm),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload),
                        label: Text(l10n.uploadLogo),
                      ),
                      Text(
                        '(${l10n.optional})',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ThemeTokens.spacingLg),

                // Business Name (Required)
                TextFormField(
                  controller: _businessNameController,
                  decoration: InputDecoration(
                    labelText: '${l10n.businessName} *',
                    hintText: l10n.required,
                    prefixIcon: const Icon(Icons.business_center),
                  ),
                  validator: ValidationUtils.validateBusinessName,
                  textCapitalization: TextCapitalization.words,
                ),

                SizedBox(height: ThemeTokens.spacingMd),

                // WhatsApp Number (Optional)
                TextFormField(
                  controller: _whatsappNumberController,
                  decoration: InputDecoration(
                    labelText: '${l10n.whatsappNumber} (${l10n.optional})',
                    hintText: '9876543210',
                    prefixIcon: const Icon(Icons.chat),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => ValidationUtils.validatePhoneNumber(value, required: false),
                ),

                SizedBox(height: ThemeTokens.spacingMd),

                // Primary Phone (Optional)
                TextFormField(
                  controller: _primaryPhoneController,
                  decoration: InputDecoration(
                    labelText: '${l10n.primaryPhone} (${l10n.optional})',
                    hintText: '9876543210',
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => ValidationUtils.validatePhoneNumber(value, required: false),
                ),

                SizedBox(height: ThemeTokens.spacingMd),

                // Additional Phone (Optional)
                TextFormField(
                  controller: _additionalPhoneController,
                  decoration: InputDecoration(
                    labelText: '${l10n.additionalPhone} (${l10n.optional})',
                    hintText: '9876543210',
                    prefixIcon: const Icon(Icons.phone_android),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => ValidationUtils.validatePhoneNumber(value, required: false),
                ),

                SizedBox(height: ThemeTokens.spacingMd),

                // Instagram ID (Optional)
                TextFormField(
                  controller: _instagramIdController,
                  decoration: InputDecoration(
                    labelText: '${l10n.instagramId} (${l10n.optional})',
                    hintText: '@yourbusiness',
                    prefixIcon: const Icon(Icons.camera_alt),
                  ),
                ),

                SizedBox(height: ThemeTokens.spacingMd),

                // Website URL (Optional)
                TextFormField(
                  controller: _websiteUrlController,
                  decoration: InputDecoration(
                    labelText: '${l10n.websiteUrl} (${l10n.optional})',
                    hintText: 'https://www.example.com',
                    prefixIcon: const Icon(Icons.language),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) => ValidationUtils.validateUrl(value, required: false),
                ),

                SizedBox(height: ThemeTokens.spacingMd),

                // GST Number (Optional)
                TextFormField(
                  controller: _gstNumberController,
                  decoration: InputDecoration(
                    labelText: '${l10n.gstNumber} (${l10n.optional})',
                    hintText: '22AAAAA0000A1Z5',
                    prefixIcon: const Icon(Icons.receipt),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) => ValidationUtils.validateGstNumber(value, required: false),
                ),

                SizedBox(height: ThemeTokens.spacingMd),

                // Business Address (Optional)
                TextFormField(
                  controller: _businessAddressController,
                  decoration: InputDecoration(
                    labelText: '${l10n.businessAddress} (${l10n.optional})',
                    hintText: l10n.businessAddress,
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),

                SizedBox(height: ThemeTokens.spacingXl),

                // Save Button
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.save),
                ),

                SizedBox(height: ThemeTokens.spacingMd),

                // Info Text
                Text(
                  '* ${l10n.required}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ThemeTokens.errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
