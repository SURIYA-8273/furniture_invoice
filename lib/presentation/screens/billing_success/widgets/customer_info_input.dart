import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class CustomerInfoInput extends StatelessWidget {
  final TextEditingController controller;

  const CustomerInfoInput({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: l10n.customerName,
        hintText: l10n.enterCustomerName,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        prefixIcon: const Icon(Icons.person_outline),
      ),
      textCapitalization: TextCapitalization.words,
    );
  }
}
