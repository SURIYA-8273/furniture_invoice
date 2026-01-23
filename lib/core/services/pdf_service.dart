import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/invoice_entity.dart';
import '../../domain/entities/business_profile_entity.dart';

/// Service for generating PDF invoices
class PdfService {
  PdfService._();
  static final PdfService instance = PdfService._();

  /// Generate PDF invoice
  Future<File> generateInvoicePdf({
    required InvoiceEntity invoice,
    required BusinessProfileEntity businessProfile,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(businessProfile),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Invoice Details
              _buildInvoiceDetails(invoice),
              pw.SizedBox(height: 20),

              // Items Table
              _buildItemsTable(invoice),
              pw.SizedBox(height: 20),

              // Totals
              _buildTotals(invoice),
              pw.Spacer(),

              // Footer
              _buildFooter(businessProfile),
            ],
          );
        },
      ),
    );

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  pw.Widget _buildHeader(BusinessProfileEntity business) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          business.businessName,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        if (business.businessAddress != null) ...[
          pw.SizedBox(height: 5),
          pw.Text(business.businessAddress!),
        ],
        if (business.primaryPhone != null) ...[
          pw.SizedBox(height: 5),
          pw.Text('Phone: ${business.primaryPhone}'),
        ],
        if (business.gstNumber != null) ...[
          pw.SizedBox(height: 5),
          pw.Text('GST: ${business.gstNumber}'),
        ],
      ],
    );
  }

  pw.Widget _buildInvoiceDetails(InvoiceEntity invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Bill Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text('Invoice: ${invoice.invoiceNumber}', style: pw.TextStyle(fontSize: 14)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Date: ${_formatDate(invoice.invoiceDate)}'),
            pw.Text('Status: ${invoice.status.toUpperCase()}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(InvoiceEntity invoice) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Product', isHeader: true),
            _buildTableCell('Size', isHeader: true),
            _buildTableCell('Sq.Ft', isHeader: true),
            _buildTableCell('Qty', isHeader: true),
            _buildTableCell('Total Qty', isHeader: true),
            _buildTableCell('MRP', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
          ],
        ),
        // Items
        ...invoice.items.map((item) => pw.TableRow(
              children: [
                _buildTableCell(item.productName),
                _buildTableCell(item.size),
                _buildTableCell(item.squareFeet.toStringAsFixed(2)),
                _buildTableCell(item.quantity.toString()),
                _buildTableCell(item.totalQuantity.toStringAsFixed(2)),
                _buildTableCell('₹${item.mrp.toStringAsFixed(2)}'),
                _buildTableCell('₹${item.totalAmount.toStringAsFixed(2)}'),
              ],
            )),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 10 : 9,
        ),
      ),
    );
  }

  pw.Widget _buildTotals(InvoiceEntity invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _buildTotalRow('Subtotal:', '₹${invoice.subtotal.toStringAsFixed(2)}'),
        if (invoice.discount > 0)
          _buildTotalRow('Discount:', '-₹${invoice.discount.toStringAsFixed(2)}'),
        if (invoice.gst > 0)
          _buildTotalRow('GST:', '₹${invoice.gst.toStringAsFixed(2)}'),
        pw.Divider(),
        _buildTotalRow('Grand Total:', '₹${invoice.grandTotal.toStringAsFixed(2)}', isBold: true),
        if (invoice.paidAmount > 0)
          _buildTotalRow('Paid:', '₹${invoice.paidAmount.toStringAsFixed(2)}'),
        if (invoice.balanceAmount > 0)
          _buildTotalRow('Balance:', '₹${invoice.balanceAmount.toStringAsFixed(2)}', isBold: true),
      ],
    );
  }

  pw.Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.SizedBox(width: 20),
          pw.Container(
            width: 100,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(BusinessProfileEntity business) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 12)),
        if (business.websiteUrl != null)
          pw.Text(business.websiteUrl!, style: pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
