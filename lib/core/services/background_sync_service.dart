
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



class BackgroundSyncService {
  static const String _excelFileName = "furniture_billing_data.xlsx";
  static const String _folderName = "FurnitureBillingData"; // User said "already existing local folder", assuming a standard name or Documents

  /// Main sync method called by the background task
  static Future<bool> syncSupabaseToExcel() async {
    try {
      // 1. Initialize Supabase (since this runs in a separate isolate)
      // We need to load env vars first if possible, or hardcode/pass them. 
      // Background isolate might not have loaded .env.
      // Ideally, pass config via inputData, but for now assuming we can load .env or using what we have.
      // CAUTION: dotenv.load might fail if assets aren't bundled for background.
      // Better approach: Pass SUPABASE_URL and KEY in inputData if dynamic, or assume we can init.
      // Let's try to load .env, if it fails, we might need hardcoded fallback or injected values.
      
      await dotenv.load(fileName: ".env");
      
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
        debugPrint("Background Sync: Missing Supabase credentials");
        return false;
      }

      final supabase = SupabaseClient(supabaseUrl, supabaseKey);

      // 2. Fetch ALL data
      // User requested "import or update all data"
      
      final response = await supabase
          .from('bills')
          .select();

      final List<dynamic> data = response as List<dynamic>;
      
      if (data.isEmpty) {
        debugPrint("Background Sync: No new data to sync.");
        return true;
      }

      // 3. Locate/Create Excel File
      // User said: "already creates the local folder and the Excel file if it does not exist"
      // We will look in ApplicationDocumentsDirectory or ExternalStorage?
      // For "accessible" local folder, usually ExternalStorage or Documents is preferred on Android.
      // Let's use getApplicationDocumentsDirectory for now, or check generic logic.
      
      Directory? baseDir;
      if (Platform.isAndroid) {
         // User requested to store in "phone documents"
         baseDir = Directory('/storage/emulated/0/Documents'); 
      } else {
         baseDir = await getApplicationDocumentsDirectory();
      }

      final dirPath = "${baseDir.path}/$_folderName";
      final directory = Directory(dirPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = "$dirPath/$_excelFileName";
      final file = File(filePath);

      // Always create a fresh Excel file to ensure deleted records are removed
      // and we have a strict mirror of the database.
      Excel excel = Excel.createExcel();
      
      final Sheet sheet = excel['Sheet1'];
      
      // Define headers based on data keys
      if (data.isNotEmpty) {
        final firstRecord = data.first as Map<String, dynamic>;
        // Sort keys to ensure consistent column order if needed, or just use as is
        final headersList = firstRecord.keys.toList();
        
        List<TextCellValue> headers = headersList.map((e) => TextCellValue(e)).toList();
        sheet.appendRow(headers);
        
        // Add all data rows
        for (var record in data) {
           final Map<String, dynamic> rowData = record;
           List<CellValue> rowValues = [];
           
           for (var key in headersList) {
             final val = rowData[key];
             rowValues.add(val != null ? TextCellValue(val.toString()) : TextCellValue(""));
           }
           sheet.appendRow(rowValues);
        }
      }

      // 6. Save
      final fileBytes = excel.save();
      if (fileBytes != null) {
        await file.writeAsBytes(fileBytes);
        debugPrint("Background Sync: Excel updated successfully at ${file.path}");
      }
      
      return true;

    } catch (e, stack) {
      debugPrint("Background Sync Error: $e");
      debugPrint(stack.toString());
      return false;
    }
  }
}
