import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/calculation_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/billing_calculation_provider.dart';

class BillingPaymentFooter extends StatelessWidget {
  final BillingCalculationProvider provider;
  final TextEditingController paidAmountController;
  final VoidCallback onAddItem;
  final VoidCallback onSave;

  const BillingPaymentFooter({
    super.key,
    required this.provider,
    required this.paidAmountController,
    required this.onAddItem,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Grand Total Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.grandTotal.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.labelSmall?.color?.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  CalculationUtils.formatCurrency(provider.grandTotal),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.textTheme.headlineSmall?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // 2. Paid Amount & Balance Due Row
            Row(
              children: [
                // Paid Amount Box
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            l10n.paidAmount.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.textTheme.labelSmall?.color?.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(NumberFormat.simpleCurrency(name: 'INR').currencySymbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: TextField(
                                controller: paidAmountController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                                ],
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onTap: () {
                                  if (paidAmountController.text == '0') {
                                    paidAmountController.clear();
                                  }
                                },
                                onChanged: (val) {
                                  final amount = double.tryParse(val) ?? 0.0;
                                  provider.setAdvancePayment(amount);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Balance Due Box
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50, // Pinkish tint as in image
                      border: Border.all(color: Colors.red.shade100),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                            l10n.balanceDue.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.red[400],
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CalculationUtils.formatCurrency(provider.balanceDue),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      
            const SizedBox(height: 5),

            // 4. Save Button
            // 4. Action Buttons Row (Add Item & Save)
            Row(
              children: [
                // Add Item Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAddItem,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(l10n.addItem.toUpperCase()),
                    style:  ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 8,
                      shadowColor: Colors.black45,
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Save Button
                Expanded(
                   
                   child: ElevatedButton.icon(
                    onPressed: (provider.hasItems && !provider.hasInvalidItems) ? onSave : null,
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: Text(l10n.next.toUpperCase()),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 8,
                      shadowColor: Colors.black45,
                      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
