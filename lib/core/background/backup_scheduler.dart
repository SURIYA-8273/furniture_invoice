import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../services/backup_service.dart';
import '../services/background_sync_service.dart';
import '../../data/models/business_profile_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/payment_history_model.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/invoice_item_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/models/description_model.dart';

/// Background task handler for automatic backups
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Background task started: $task');

    try {
      // Initialize Hive for background task
      await Hive.initFlutter();

      // Register all adapters (MUST match HiveService)
      Hive.registerAdapter(BusinessProfileModelAdapter()); // typeId: 0
      Hive.registerAdapter(ProductModelAdapter()); // typeId: 2
      Hive.registerAdapter(PaymentHistoryModelAdapter()); // typeId: 3
      Hive.registerAdapter(InvoiceModelAdapter()); // typeId: 4
      Hive.registerAdapter(InvoiceItemModelAdapter()); // typeId: 5
      Hive.registerAdapter(PaymentModelAdapter()); // typeId: 6
      Hive.registerAdapter(DescriptionModelAdapter()); // typeId: 10

      // Get Supabase credentials from input data
      final supabaseUrl = inputData?['supabase_url'] as String?;
      final supabaseKey = inputData?['supabase_key'] as String?;

      if (supabaseUrl == null || supabaseKey == null) {
        debugPrint('Missing Supabase credentials in background task');
        return Future.value(false);
      }

      // Initialize Supabase
      await SupabaseService.instance.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );

    // Perform automatic backup or import based on task name
      if (task == 'daily_backup_task') {
        final result = await BackupService.instance.performFullBackup(
          backupType: 'automatic',
          onProgress: (message) => debugPrint('Backup progress: $message'),
        );

        debugPrint('Automatic backup completed: ${result.statusMessage}');
        debugPrint('Bills synced: ${result.billsSynced}, failed: ${result.billsFailed}');
        debugPrint('Payments synced: ${result.paymentsSynced}, failed: ${result.paymentsFailed}');

        // Return success if backup completed (even with some errors)
        return Future.value(result.success);
      } else if (task == 'daily_import_task') {
        final result = await BackupService.instance.restoreData(
          onProgress: (message) => debugPrint('Import progress: $message'),
        );

        debugPrint('Automatic import completed');
        debugPrint('Bills restored: ${result.billsRestored}');
        debugPrint('Payments restored: ${result.paymentsRestored}');
        
        return Future.value(result.success);
      } else if (task == 'weekly_excel_sync_task') {
        final result = await BackgroundSyncService.syncSupabaseToExcel();
        debugPrint('Weekly Excel sync completed: $result');
        return Future.value(result);
      }
      
      return Future.value(false);
    } catch (e) {
      debugPrint('Error in background task ($task): $e');
      return Future.value(false);
    }
  });
}


/// Service for managing automatic backup scheduling
class BackupSchedulerService {
  BackupSchedulerService._();
  static final BackupSchedulerService instance = BackupSchedulerService._();

  static const String _dailyBackupTask = 'daily_backup_task';
  static const String _dailyImportTask = 'daily_import_task';
  static const String _weeklyExcelSyncTask = 'weekly_excel_sync_task';
  
  // Preference keys
  static const String _prefBackupEnabled = 'backup_enabled';
  static const String _prefBackupHour = 'backup_hour';
  static const String _prefBackupMinute = 'backup_minute';
  static const String _prefImportEnabled = 'import_enabled';
  static const String _prefImportHour = 'import_hour';
  static const String _prefImportMinute = 'import_minute';
  static const String _prefExcelSyncEnabled = 'excel_sync_enabled';
  static const String _prefExcelSyncFrequencyDays = 'excel_sync_frequency_days';

  bool _isInitialized = false;
  
  // Default settings
  bool _isBackupEnabled = true;
  TimeOfDay _backupTime = const TimeOfDay(hour: 0, minute: 0); // 12:00 AM
  
  bool _isImportEnabled = false;
  TimeOfDay _importTime = const TimeOfDay(hour: 1, minute: 0); // 1:00 AM

  // Excel Sync Settings
  bool _isExcelSyncEnabled = true; // Default to true as per previous request implementation
  int _excelSyncFrequencyDays = 7;

  /// Initialize the backup scheduler
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    if (_isInitialized) {
      debugPrint('BackupSchedulerService already initialized');
      return;
    }

    try {
      // Load preferences
      await _loadPreferences();

      // Initialize Workmanager
      await Workmanager().initialize(
        callbackDispatcher,
      );

      // Schedule or cancel based on preferences
      if (_isBackupEnabled) {
        await scheduleDailyBackup(
          supabaseUrl: supabaseUrl,
          supabaseKey: supabaseKey,
        );
      } else {
        await cancelScheduledBackups();
      }

      if (_isImportEnabled) {
        await scheduleDailyImport(
          supabaseUrl: supabaseUrl,
          supabaseKey: supabaseKey,
        );
      } else {
        await cancelScheduledImport();
      }

      if (_isExcelSyncEnabled) {
        await scheduleWeeklyExcelSync(
          supabaseUrl: supabaseUrl,
          supabaseKey: supabaseKey,
        );
      } else {
        await cancelWeeklyExcelSync();
      }

      _isInitialized = true;
      debugPrint('BackupSchedulerService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing BackupSchedulerService: $e');
      rethrow;
    }
  }

  /// Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Backup prefs
    _isBackupEnabled = prefs.getBool(_prefBackupEnabled) ?? true;
    final backupHour = prefs.getInt(_prefBackupHour) ?? 0; // Default 12:00 AM
    final backupMinute = prefs.getInt(_prefBackupMinute) ?? 0;
    _backupTime = TimeOfDay(hour: backupHour, minute: backupMinute);

    // Import prefs
    _isImportEnabled = prefs.getBool(_prefImportEnabled) ?? false;
    final importHour = prefs.getInt(_prefImportHour) ?? 1; // Default 1:00 AM
    final importMinute = prefs.getInt(_prefImportMinute) ?? 0;
    _importTime = TimeOfDay(hour: importHour, minute: importMinute);

    // Excel Sync prefs
    _isExcelSyncEnabled = prefs.getBool(_prefExcelSyncEnabled) ?? true;
    _excelSyncFrequencyDays = prefs.getInt(_prefExcelSyncFrequencyDays) ?? 7;
  }

  /// Save preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Backup prefs
    await prefs.setBool(_prefBackupEnabled, _isBackupEnabled);
    await prefs.setInt(_prefBackupHour, _backupTime.hour);
    await prefs.setInt(_prefBackupMinute, _backupTime.minute);

    // Import prefs
    await prefs.setBool(_prefImportEnabled, _isImportEnabled);
    await prefs.setInt(_prefImportHour, _importTime.hour);
    await prefs.setInt(_prefImportMinute, _importTime.minute);

    // Excel Sync prefs
    await prefs.setBool(_prefExcelSyncEnabled, _isExcelSyncEnabled);
    await prefs.setInt(_prefExcelSyncFrequencyDays, _excelSyncFrequencyDays);
  }

  /// Toggle automatic backup
  Future<void> toggleBackup(bool enabled, {
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    _isBackupEnabled = enabled;
    await _savePreferences();

    if (enabled) {
      await scheduleDailyBackup(
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );
    } else {
      await cancelScheduledBackups();
    }
  }

  /// Toggle automatic import
  Future<void> toggleImport(bool enabled, {
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    _isImportEnabled = enabled;
    await _savePreferences();

    if (enabled) {
      await scheduleDailyImport(
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );
    } else {
      await cancelScheduledImport();
    }
  }

  /// Update backup time
  Future<void> updateBackupTime(TimeOfDay time, {
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    _backupTime = time;
    await _savePreferences();

    if (_isBackupEnabled) {
      await scheduleDailyBackup(
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );
    }
  }

  /// Update import time
  Future<void> updateImportTime(TimeOfDay time, {
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    _importTime = time;
    await _savePreferences();

    if (_isImportEnabled) {
      await scheduleDailyImport(
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );
    }
  }

  /// Schedule daily backup at the configured time
  Future<void> scheduleDailyBackup({
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    try {
      // Cancel existing task if any
      await Workmanager().cancelByUniqueName(_dailyBackupTask);

      // Calculate initial delay to reach the configured backup time
      final now = DateTime.now();
      var nextBackup = DateTime(
        now.year, 
        now.month, 
        now.day, 
        _backupTime.hour, 
        _backupTime.minute
      );
      
      // If the time has already passed today, schedule for tomorrow
      if (now.isAfter(nextBackup)) {
        nextBackup = nextBackup.add(const Duration(days: 1));
      }

      final initialDelay = nextBackup.difference(now);

      debugPrint('Scheduling daily backup at ${_backupTime.formatLog()}');
      debugPrint('Next backup in: ${initialDelay.inHours}h ${initialDelay.inMinutes % 60}m');

      // Register periodic task (runs every 24 hours)
      await Workmanager().registerPeriodicTask(
        _dailyBackupTask,
        _dailyBackupTask,
        frequency: const Duration(hours: 24),
        initialDelay: initialDelay,
        constraints: Constraints(
          networkType: NetworkType.connected, // Require internet connection
        ),
        inputData: {
          'supabase_url': supabaseUrl,
          'supabase_key': supabaseKey,
        },
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );

      debugPrint('Daily backup scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling daily backup: $e');
      rethrow;
    }
  }

  /// Schedule daily import at the configured time
  Future<void> scheduleDailyImport({
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    try {
      // Cancel existing task if any
      await Workmanager().cancelByUniqueName(_dailyImportTask);

      // Calculate initial delay to reach the configured import time
      final now = DateTime.now();
      var nextImport = DateTime(
        now.year, 
        now.month, 
        now.day, 
        _importTime.hour, 
        _importTime.minute
      );
      
      // If the time has already passed today, schedule for tomorrow
      if (now.isAfter(nextImport)) {
        nextImport = nextImport.add(const Duration(days: 1));
      }

      final initialDelay = nextImport.difference(now);

      debugPrint('Scheduling daily import at ${_importTime.formatLog()}');
      debugPrint('Next import in: ${initialDelay.inHours}h ${initialDelay.inMinutes % 60}m');

      // Register periodic task (runs every 24 hours)
      await Workmanager().registerPeriodicTask(
        _dailyImportTask,
        _dailyImportTask,
        frequency: const Duration(hours: 24),
        initialDelay: initialDelay,
        constraints: Constraints(
          networkType: NetworkType.connected, // Require internet connection
        ),
        inputData: {
          'supabase_url': supabaseUrl,
          'supabase_key': supabaseKey,
        },
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );

      debugPrint('Daily import scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling daily import: $e');
      rethrow;
    }
  }

  /// Toggle Excel Sync
  Future<void> toggleExcelSync(bool enabled, {
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    _isExcelSyncEnabled = enabled;
    await _savePreferences();

    if (enabled) {
      await scheduleWeeklyExcelSync(
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );
    } else {
      await cancelWeeklyExcelSync();
    }
  }

  /// Update Excel Sync Frequency
  Future<void> updateExcelSyncFrequency(int days, {
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    if (days < 1) return;
    _excelSyncFrequencyDays = days;
    await _savePreferences();

    if (_isExcelSyncEnabled) {
      await scheduleWeeklyExcelSync(
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );
    }
  }

  /// Schedule weekly Excel sync
  Future<void> scheduleWeeklyExcelSync({
    required String supabaseUrl,
    required String supabaseKey,
  }) async {
    try {
      // Register periodic task
      // We use the configured frequency
      await Workmanager().registerPeriodicTask(
        _weeklyExcelSyncTask,
        _weeklyExcelSyncTask,
        frequency: Duration(days: _excelSyncFrequencyDays),
        constraints: Constraints(
          networkType: NetworkType.connected, // Require internet connection
        ),
        inputData: {
          'supabase_url': supabaseUrl,
          'supabase_key': supabaseKey,
        },
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace, // Replace to update frequency
      );

      debugPrint('Excel sync scheduled successfully (every $_excelSyncFrequencyDays days)');
    } catch (e) {
      debugPrint('Error scheduling Excel sync: $e');
    }
  }

  /// Cancel scheduled backups
  Future<void> cancelScheduledBackups() async {
    try {
      await Workmanager().cancelByUniqueName(_dailyBackupTask);
      debugPrint('Scheduled backups cancelled');
    } catch (e) {
      debugPrint('Error cancelling scheduled backups: $e');
    }
  }

  /// Cancel scheduled import
  Future<void> cancelScheduledImport() async {
    try {
      await Workmanager().cancelByUniqueName(_dailyImportTask);
      debugPrint('Scheduled import cancelled');
    } catch (e) {
      debugPrint('Error cancelling scheduled import: $e');
    }
  }

  /// Cancel all scheduled tasks
  Future<void> cancelAll() async {
    try {
      await Workmanager().cancelAll();
      _isInitialized = false;
      debugPrint('All scheduled tasks cancelled');
    } catch (e) {
      debugPrint('Error cancelling all tasks: $e');
    }
  }

  /// Cancel scheduled Excel sync
  Future<void> cancelWeeklyExcelSync() async {
    try {
      await Workmanager().cancelByUniqueName(_weeklyExcelSyncTask);
      debugPrint('Scheduled Excel sync cancelled');
    } catch (e) {
      debugPrint('Error cancelling Excel sync: $e');
    }
  }

  /// Check if backup is enabled (preference)
  bool get isBackupEnabled => _isBackupEnabled;
  
  /// Get current backup time
  TimeOfDay get backupTime => _backupTime;

  /// Check if import is enabled (preference)
  bool get isImportEnabled => _isImportEnabled;

  /// Get current import time
  TimeOfDay get importTime => _importTime;

  /// Check if Excel Sync is enabled
  bool get isExcelSyncEnabled => _isExcelSyncEnabled;

  /// Get Excel Sync Frequency
  int get excelSyncFrequency => _excelSyncFrequencyDays;
}

// Extension to help format TimeOfDay without context for logging
extension TimeOfDayExtension on TimeOfDay {
  String formatLog() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
