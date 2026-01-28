import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ThemeTokens.spacingMd,
        ThemeTokens.spacingMd,
        ThemeTokens.spacingMd,
        ThemeTokens.spacingSm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
