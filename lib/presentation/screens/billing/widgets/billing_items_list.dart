import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/billing_calculation_provider.dart';
import 'editable_billing_row.dart';

class BillingItemsList extends StatelessWidget {
  final BillingCalculationProvider provider;

  const BillingItemsList({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (provider.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: Text(l10n.noItemsAdded, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor))),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: provider.items.length,
      separatorBuilder: (ctx, i) => const Divider(height: 1, thickness: 1),
      itemBuilder: (context, index) {
        final item = provider.items[index];
        return Dismissible(
          key: ValueKey(item.id), 
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            provider.removeItem(index);
          },
          child: EditableBillingRow(
            key: ValueKey(item.id), // Important for focus stability
            item: item,
            index: index,
            provider: provider,
          ),
        );
      },
    );
  }
}
