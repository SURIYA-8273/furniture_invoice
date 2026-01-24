package com.example.furniture_billing

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import java.io.File
import android.content.pm.PackageManager
import java.net.URLEncoder

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.invoice/whatsapp"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "shareToWhatsApp") {
                val filePath = call.argument<String>("filePath")
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")

                if (filePath != null) {
                    shareToWhatsApp(filePath, phoneNumber, message)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "File path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun shareToWhatsApp(filePath: String, phoneNumber: String?, message: String?) {
        val file = File(filePath)
        val uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.provider",
            file
        )

        val intent = Intent(Intent.ACTION_SEND)
        
        // Determine MIME type
        val mimeType = if (filePath.endsWith(".png")) {
            "image/png"
        } else if (filePath.endsWith(".jpg") || filePath.endsWith(".jpeg")) {
            "image/jpeg"
        } else {
            "application/pdf"
        }
        
        intent.type = mimeType
        intent.putExtra(Intent.EXTRA_STREAM, uri)
        
        if (message != null) {
            intent.putExtra(Intent.EXTRA_TEXT, message)
        }

        // Try to target specific contact using JID (Jabber ID) for WhatsApp
        // Format: [countrycode][number]@s.whatsapp.net
        // Note: This is an undocumented extra that works on many versions but not guaranteed.
        if (phoneNumber != null && phoneNumber.isNotEmpty()) {
            intent.putExtra("jid", "$phoneNumber@s.whatsapp.net")
        }

        // WhatsApp targets
        // If phone number is present, we try to target specific contact via API URL (for text) 
        // BUT for file sharing, Android Intent doesn't support 'phone' extra standardly for WhatsApp.
        // We can only target the Package 'com.whatsapp' or 'com.whatsapp.w4b'.
        // So user still has to pick the contact. 
        // If user wants to send text ONLY to specific contact, we use ACTION_VIEW with URL.
        // Here we are sharing a FILE, so we just target the app.
        
        intent.setPackage("com.whatsapp")
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        
        try {
           startActivity(intent)
        } catch (e: Exception) {
           // Try WhatsApp Business if standard fails
           try {
               intent.setPackage("com.whatsapp.w4b")
               startActivity(intent)
           } catch (e2: Exception) {
               // Fallback to chooser if neither specific package works (unlikely if checking queries, but good practice)
               intent.setPackage(null)
               startActivity(Intent.createChooser(intent, "Share Invoice via"))
           }
        }
    }
}
