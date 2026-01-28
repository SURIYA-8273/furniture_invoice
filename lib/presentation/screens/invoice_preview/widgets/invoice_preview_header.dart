import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../domain/entities/business_profile_entity.dart';

class InvoicePreviewHeader extends StatelessWidget {
  final BusinessProfileEntity? businessProfile;
  
  const InvoicePreviewHeader({
    super.key,
    required this.businessProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTamil = Localizations.localeOf(context).languageCode == 'ta';
    
    // Determine Name
    String businessName = businessProfile?.businessName ?? l10n.defaultBusinessName;
    if (isTamil && businessProfile?.businessNameTamil != null && businessProfile!.businessNameTamil!.isNotEmpty) {
      businessName = businessProfile!.businessNameTamil!;
    }

    // Determine Address
    String? businessAddress = businessProfile?.businessAddress;
    if (isTamil && businessProfile?.businessAddressTamil != null && businessProfile!.businessAddressTamil!.isNotEmpty) {
      businessAddress = businessProfile!.businessAddressTamil;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Logo
          if (businessProfile?.logoPath != null)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(businessProfile!.logoPath!)),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                // color: Colors.black, // Removed black background
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          
          const SizedBox(height: 2),
          
          // Business Name
          Text(
            businessName.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 2),
          
          // Contact Details (Centered)
          if (businessProfile?.primaryPhone != null)
             Text(
               '${l10n.phoneLabel}: ${businessProfile!.primaryPhone}',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
               textAlign: TextAlign.center,
             ),
          if (businessAddress != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                businessAddress,
                 style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
