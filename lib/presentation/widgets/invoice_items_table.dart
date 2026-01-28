import 'package:flutter/material.dart';
import '../../core/theme/theme_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/entities/invoice_item_entity.dart';

class InvoiceItemsTable extends StatelessWidget {
  final List<InvoiceItemEntity> items;

  const InvoiceItemsTable({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: ThemeTokens.invoiceTableBorder),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3), // Description
          1: FlexColumnWidth(1), // Length
          2: FlexColumnWidth(1), // Qty
          3: FlexColumnWidth(1.2), // Rate
          4: FlexColumnWidth(1.2), // Total Len
          5: FlexColumnWidth(1.5), // Total
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: ThemeTokens.invoiceTableBorder),
          verticalInside: BorderSide(color: ThemeTokens.invoiceTableBorder),
        ),
        children: [
          // Header
          TableRow(
            decoration: const BoxDecoration(
              color: ThemeTokens.invoiceTableHeader,
            ),
            children: [
              _buildTableHeaderText(l10n.descriptionShort, isHeader: true),
              _buildTableHeaderText(l10n.lengthShort, isHeader: true),
              _buildTableHeaderText(l10n.qtyShort, isHeader: true),
              _buildTableHeaderText(l10n.rateShort, isHeader: true),
              _buildTableHeaderText(l10n.totalLenShort, isHeader: true),
              _buildTableHeaderText(l10n.totalShort, isHeader: true),
            ],
          ),

          // Items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isEvenRow = index % 2 == 0;
            const cellStyle = TextStyle(fontSize: 11, color: ThemeTokens.lightTextPrimary, fontWeight: FontWeight.w500);

            return TableRow(
              decoration: BoxDecoration(
                color: isEvenRow ? ThemeTokens.invoiceRowAlternate : Colors.white,
              ),
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                    child:Text(
                  item.productName.isNotEmpty && item.size.isNotEmpty
                      ? '${item.productName} - ${item.size}'
                      : item.productName.isNotEmpty
                          ? item.productName
                          : item.size,
                  style: const TextStyle(fontSize: 11), // Slightly smaller font for compactness
                ),
                    
                   
                  ),
                ),
                _buildTableCell(item.length == 0 ? '-' : item.length.toStringAsFixed(2), cellStyle),
                _buildTableCell(item.quantity == 0 ? '-' : '${item.quantity}', cellStyle),
                _buildTableCell(item.rate == 0 ? '-' : '₹${item.rate.toStringAsFixed(0)}', cellStyle),
                 _buildTableCell(item.totalLength == 0 ? '-' : item.totalLength.toStringAsFixed(2), cellStyle),
                _buildTableCell('₹${item.totalAmount.toStringAsFixed(2)}',
                    cellStyle.copyWith(fontWeight: FontWeight.bold)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, TextStyle style) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Center(child: Text(text, style: style, textAlign: TextAlign.center)),
      ),
    );
  }

  Widget _buildTableHeaderText(String text, {required bool isHeader, TextAlign align = TextAlign.center}) {
    return Padding(
       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
       child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: ThemeTokens.invoiceHeaderText,
            letterSpacing: 0.5,
          ),
          textAlign: align,
        ),
      ),
    );
  }
}
