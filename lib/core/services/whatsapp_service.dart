import 'dart:io';
import 'package:flutter/services.dart'; // For MethodChannel
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/invoice_entity.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

/// Service for WhatsApp sharing integration
class WhatsAppService {
  WhatsAppService._();
  static final WhatsAppService instance = WhatsAppService._();

  /// Share invoice via WhatsApp
  Future<bool> shareInvoice({
    required String phoneNumber,
    required InvoiceEntity invoice,
    required File file,
  }) async {
    // Validate phone number - Removed check to allow empty phone for "Select Chat"
    // if (phoneNumber.isEmpty) {
    //   throw Exception('Phone number is required for WhatsApp sharing');
    // }

    // Clean phone number (remove +, spaces, etc.)
    var cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Auto-prepend 91 if 10 digits (India)
    if (cleanPhone.length == 10) {
      cleanPhone = '91$cleanPhone';
    }

    // Create message
    final message = _createInvoiceMessage(invoice);

    try {
      // 1. Try Native Direct Share (File + WhatsApp Package)
      const platform = MethodChannel('com.example.invoice/whatsapp');
      await platform.invokeMethod('shareToWhatsApp', {
        'filePath': file.path,
        'phoneNumber': cleanPhone, // Native code currently ignores this for file sharing intent, but passing it anyway
        'message': message,
      });
      return true;
    } catch (e) {
      debugPrint("Direct WhatsApp share failed: $e");
      
      // 2. Fallback: Use share_plus (System Share Sheet)
      try {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: message,
          subject: 'Invoice ${invoice.invoiceNumber}',
        );
        return true;
      } catch (e2) {
        debugPrint("Share Plus failed: $e2");
        // 3. Final Fallback: Text only via URL (Original logic)
        final whatsappUrl = 'whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}';
        final uri = Uri.parse(whatsappUrl);
        if (await canLaunchUrl(uri)) {
          return await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        
        final webUrl = 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}';
        final webUri = Uri.parse(webUrl);
        if (await canLaunchUrl(webUri)) {
          return await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      }
    }
    return false;
  }

  /// Create pre-filled message for invoice
  String _createInvoiceMessage(InvoiceEntity invoice) {
    final buffer = StringBuffer();
    buffer.writeln('Hello,');
    buffer.writeln();
    buffer.writeln('Your invoice ${invoice.invoiceNumber} details:');
    buffer.writeln('Amount: ₹${invoice.grandTotal.toStringAsFixed(2)}');
    
    if (invoice.paidAmount > 0) {
      buffer.writeln('Paid: ₹${invoice.paidAmount.toStringAsFixed(2)}');
    }
    
    if (invoice.balanceAmount > 0) {
      buffer.writeln('Balance: ₹${invoice.balanceAmount.toStringAsFixed(2)}');
    }
    
    buffer.writeln();
    buffer.writeln('Thank you for your business!');

    return buffer.toString();
  }

  /// Create WhatsApp URL
  String _createWhatsAppUrl(String phoneNumber, String message) {
    final encodedMessage = Uri.encodeComponent(message);
    
    // Use WhatsApp API URL
    if (phoneNumber.isEmpty) {
      // General share (select contact)
      return 'whatsapp://send?text=$encodedMessage';
    }

    // Specific number
    if (Platform.isAndroid || Platform.isIOS) {
      return 'whatsapp://send?phone=$phoneNumber&text=$encodedMessage';
    } else {
      return 'https://wa.me/$phoneNumber?text=$encodedMessage';
    }
  }

  /// Check if WhatsApp is available
  Future<bool> isWhatsAppAvailable() async {
    final uri = Uri.parse('whatsapp://send');
    return await canLaunchUrl(uri);
  }

  /// Share text message via WhatsApp
  Future<bool> shareTextMessage({
    required String phoneNumber,
    required String message,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappUrl = _createWhatsAppUrl(cleanPhone, message);
    
    final uri = Uri.parse(whatsappUrl);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('WhatsApp is not installed on this device');
    }
  }
}
