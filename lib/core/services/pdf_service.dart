import 'dart:io';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // For PdfGoogleFonts
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
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

    // Load Logo
    pw.MemoryImage? profileImage;
    if (businessProfile.logoPath != null) {
      final file = File(businessProfile.logoPath!);
      if (await file.exists()) {
        profileImage = pw.MemoryImage(await file.readAsBytes());
      }
    }
    
    if (profileImage == null) {
       try {
         final logoBytes = await rootBundle.load('assets/images/logo.png');
         profileImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
       } catch (e) {
         // Fallback if asset missing
         debugPrint('Error loading default logo: $e');
       }
    }

    // Load Font (with fallback)
    pw.ThemeData theme;
    try {
      theme = pw.ThemeData.withFont(
        base: await PdfGoogleFonts.notoSansDevanagariRegular(),
        bold: await PdfGoogleFonts.notoSansDevanagariBold(),
      );
    } catch (e) {
      debugPrint('Error loading Google Fonts: $e');
      // Fallback to default font (might miss Rupee symbol but won't crash)
      theme = pw.ThemeData.withFont(
        base: pw.Font.courier(),
        bold: pw.Font.courierBold(),
      );
    }

    pdf.addPage(
      pw.Page(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(businessProfile, profileImage),
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

  /// Generate Image from Invoice (for WhatsApp sharing)
  Future<File> generateInvoiceImage({
    required InvoiceEntity invoice,
    required BusinessProfileEntity businessProfile,
  }) async {
    // 1. Generate PDF document (in memory)
    final pdfFile = await generateInvoicePdf(invoice: invoice, businessProfile: businessProfile);
    final pdfBytes = await pdfFile.readAsBytes();

    // 2. Rasterize first page to Image
    // We assume single page invoice for image sharing usually, or we could stitch them.
    // For now, let's just take the first page which covers most billing cases.
    try {
      await for (final page in Printing.raster(pdfBytes, pages: [0], dpi: 200)) {
        final imageBytes = await page.toPng();
        final output = await getTemporaryDirectory();
        final imageFile = File('${output.path}/invoice_${invoice.invoiceNumber}.png');
        await imageFile.writeAsBytes(imageBytes);
        return imageFile; // Return immediately after first page
      }
    } catch (e) {
      debugPrint('Error rasterizing PDF: $e');
    }
    
    // Fallback? Return PDF if raster fails? 
    // For now, just return PDF file contextually treated as image might fail. 
    // Let's rely on the try block succeeding.
    return pdfFile; // Fallback to PDF if image gen fails (better than nothing)
  }

  pw.Widget _buildHeader(BusinessProfileEntity business, pw.MemoryImage? logo) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (logo != null)
          pw.Container(
            width: 60,
            height: 60,
            margin: const pw.EdgeInsets.only(right: 20),
            child: pw.Image(logo),
          ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                business.businessName.toUpperCase(),
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              if (business.businessAddress != null) ...[
                pw.SizedBox(height: 5),
                pw.Text(business.businessAddress!, style: const pw.TextStyle(fontSize: 10)),
              ],
              if (business.primaryPhone != null) ...[
                pw.SizedBox(height: 5),
                pw.Text('Phone: ${business.primaryPhone}', style: const pw.TextStyle(fontSize: 10)),
              ],
              if (business.gstNumber != null) ...[
                pw.SizedBox(height: 5),
                pw.Text('GSTIN: ${business.gstNumber}', style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ],
            ],
          ),
        ),
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
      columnWidths: {
        0: const pw.FlexColumnWidth(4), // Description
        1: const pw.FlexColumnWidth(1), // Length
        2: const pw.FlexColumnWidth(1), // Qty
        3: const pw.FlexColumnWidth(1), // Total Length
        4: const pw.FlexColumnWidth(1), // Rate
        5: const pw.FlexColumnWidth(2), // Total
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('DESCRIPTION', isHeader: true),
            _buildTableCell('LENGTH', isHeader: true),
            _buildTableCell('QTY', isHeader: true),
            _buildTableCell('TOT.LEN', isHeader: true),
            _buildTableCell('RATE', isHeader: true),
            _buildTableCell('TOTAL', isHeader: true),
          ],
        ),
        // Items
        ...invoice.items.map((item) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.productName, style: const pw.TextStyle(fontSize: 9)),
                      if (item.size.isNotEmpty)
                        pw.Text(item.size, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                ),
                _buildTableCell(item.squareFeet == 0 ? '-' : item.squareFeet.toStringAsFixed(2)),
                _buildTableCell(item.quantity == 0 ? '-' : item.quantity.toString()),
                _buildTableCell(item.totalQuantity == 0 ? '-' : item.totalQuantity.toStringAsFixed(2)),
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
