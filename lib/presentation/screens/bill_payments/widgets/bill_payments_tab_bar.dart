import 'package:flutter/material.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class BillPaymentsTabBar extends StatelessWidget {
  final TabController tabController;

  const BillPaymentsTabBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: theme.cardColor,
      padding: EdgeInsets.symmetric(horizontal: ThemeTokens.spacingMd, vertical: ThemeTokens.spacingSm),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
          border: Border.all(
            color: ThemeTokens.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: TabBar(
          controller: tabController,
          indicator: BoxDecoration(
            color: ThemeTokens.primaryColor,
            borderRadius: BorderRadius.circular(ThemeTokens.radiusSmall + 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: theme.textTheme.labelLarge?.color?.withValues(alpha: 0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          padding: EdgeInsets.all(ThemeTokens.spacingXs),
          tabs: [
            Tab(text: l10n.unpaidPartial),
            Tab(text: l10n.paid),
          ],
        ),
      ),
    );
  }
}
