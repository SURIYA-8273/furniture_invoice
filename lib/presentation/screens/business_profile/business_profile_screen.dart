import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_tokens.dart';
import 'widgets/business_logo_picker.dart';
import 'widgets/business_profile_form.dart';
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
  final _primaryPhoneController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessNameTamilController = TextEditingController();
  final _businessAddressTamilController = TextEditingController();

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
      _primaryPhoneController.text = profile.primaryPhone ?? '';
      _businessAddressController.text = profile.businessAddress ?? '';
      _businessNameTamilController.text = profile.businessNameTamil ?? '';
      _businessAddressTamilController.text = profile.businessAddressTamil ?? '';
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
      primaryPhone: _primaryPhoneController.text.trim().isEmpty
          ? null
          : _primaryPhoneController.text.trim(),
      businessAddress: _businessAddressController.text.trim().isEmpty
          ? null
          : _businessAddressController.text.trim(),
      businessNameTamil: _businessNameTamilController.text.trim().isEmpty
          ? null
          : _businessNameTamilController.text.trim(),
      businessAddressTamil: _businessAddressTamilController.text.trim().isEmpty
          ? null
          : _businessAddressTamilController.text.trim(),
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
    _primaryPhoneController.dispose();
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
                BusinessLogoPicker(
                  logoPath: _logoPath,
                  onPickImage: _pickImage,
                ),
                BusinessProfileForm(
                  businessNameController: _businessNameController,
                  primaryPhoneController: _primaryPhoneController,
                  businessAddressController: _businessAddressController,
                  businessNameTamilController: _businessNameTamilController,
                  businessAddressTamilController: _businessAddressTamilController,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ThemeTokens.spacingMd),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
             BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea( 
          child: ElevatedButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save),
            label: Text(l10n.save),
             style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.white,
              backgroundColor: ThemeTokens.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium)),
            ),
          ),
        ),
      ),
    );
  }
}
