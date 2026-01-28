import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';

class BusinessLogoPicker extends StatelessWidget {
  final String? logoPath;
  final VoidCallback onPickImage;

  const BusinessLogoPicker({
    super.key,
    required this.logoPath,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onPickImage,
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
              child: logoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                      child: Image.file(
                        File(logoPath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(height: ThemeTokens.spacingSm),
        ],
      ),
    );
  }
}
