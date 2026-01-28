import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/entities/invoice_entity.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';

class InvoiceListItem extends StatelessWidget {
  final InvoiceEntity invoice;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isDeleting;

  const InvoiceListItem({
    super.key,
    required this.invoice,
    required this.onTap,
    this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    Color statusColor;
    String statusText;

    if (invoice.isFullyPaid) {
      statusColor = ThemeTokens.successColor;
      statusText = l10n.paid.toUpperCase();
    } else if (invoice.paidAmount > 0) {
      statusColor = ThemeTokens.warningColor;
      statusText = l10n.partial.toUpperCase();
    } else {
      statusColor = ThemeTokens.errorColor;
      statusText = l10n.pending.toUpperCase();
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ThemeTokens.spacingMd,
        vertical: 3,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        side: BorderSide(
          color: ThemeTokens.lightBorder.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: isDeleting ? null : onTap,
        borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(ThemeTokens.spacingSm),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.billNo} : ${invoice.invoiceNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.brightness == Brightness.light ? Colors.black : Colors.white,
                        fontWeight: ThemeTokens.fontWeightBold,
                      ),
                    ),
                  ),
                  if (onDelete != null)
                    isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            onPressed: onDelete,
                            icon: Icon(
                              Icons.delete_outline,
                              color: ThemeTokens.errorColor,
                              size: ThemeTokens.iconSizeSmall + 4,
                            ),
                            tooltip: l10n.deleteBill,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                          ),
                  const SizedBox(width: ThemeTokens.spacingSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeTokens.spacingSm,
                      vertical: ThemeTokens.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusLarge),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: ThemeTokens.fontWeightBold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: theme.brightness == Brightness.light ? 0.1 : 0.2),
                      borderRadius: BorderRadius.circular(ThemeTokens.radiusMedium),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: theme.colorScheme.primary,
                      size: ThemeTokens.iconSizeMedium,
                    ),
                  ),
                  SizedBox(width: ThemeTokens.spacingSm + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.total.toUpperCase()}: ${currencyFormat.format(invoice.grandTotal)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.brightness == Brightness.light ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          '${l10n.date.toUpperCase()} : ${dateFormat.format(invoice.invoiceDate)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.brightness == Brightness.light ? Colors.black87 : Colors.white70,
                            fontSize: ThemeTokens.fontSizeBodySmall,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (invoice.customerName != null && invoice.customerName!.isNotEmpty) ...[
                          Text(
                            '${l10n.customer.toUpperCase()} : ${invoice.customerName!}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.brightness == Brightness.light ? Colors.black87 : Colors.white70,
                              fontSize: ThemeTokens.fontSizeBodySmall,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(invoice.balanceAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: invoice.isFullyPaid
                              ? ThemeTokens.successColor
                              : ThemeTokens.errorColor,
                          fontWeight: ThemeTokens.fontWeightBold,
                        ),
                      ),
                      
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
