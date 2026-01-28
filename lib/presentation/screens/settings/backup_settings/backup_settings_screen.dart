import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/background_sync_service.dart';
import '../../../../core/background/backup_scheduler.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../../../providers/invoice_provider.dart';
import 'dart:async';
import 'widgets/excel_sync_settings_card.dart';
import 'widgets/manual_export_card.dart';
import 'widgets/backup_info_card.dart';
import 'widgets/restore_info_card.dart';
import 'widgets/excel_sync_status_card.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  final _supabase = SupabaseService.instance;
  final _backup = BackupService.instance;

  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isExcelSyncing = false;
  String _backupProgress = '';
  DateTime? _lastBackupTime;
  int _lastBackupBillsCount = 0;
  int _lastBackupPaymentsCount = 0;
  DateTime? _lastImportTime;
  int _lastImportBillsCount = 0;
  int _lastImportPaymentsCount = 0;
  DateTime? _lastExcelSyncTime;
  bool _isConnected = false;
  bool _isCheckingConnection = false;

  // Auto Backup Settings
  bool _isSchedulerEnabled = true;
  TimeOfDay _backupTime = const TimeOfDay(hour: 0, minute: 0); // 12:00 AM

  // Auto Import Settings
  bool _isImportSchedulerEnabled = false;
  TimeOfDay _importTime = const TimeOfDay(hour: 1, minute: 0); // 1:00 AM

  // Excel Sync Settings
  bool _isExcelSyncEnabled = true;
  int _excelSyncFrequencyDays = 7;

  // Connectivity
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _loadLastBackupTime();
    _loadLastImportTime();
    _loadLastExcelSyncTime();
    _loadSchedulerSettings();
    _initConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      final isConnected = result == ConnectivityResult.mobile || 
                          result == ConnectivityResult.wifi;
      
      if (isConnected) {
        // If we weren't connected before, or if Supabase isn't initialized, try to connect
        if (!_isConnected || !_supabase.isInitialized) {
          _checkConnection();
        }
      }
    });
  }

  Future<void> _loadSchedulerSettings() async {
    setState(() {
      _isSchedulerEnabled = BackupSchedulerService.instance.isBackupEnabled;
      _backupTime = BackupSchedulerService.instance.backupTime;
      _isImportSchedulerEnabled = BackupSchedulerService.instance.isImportEnabled;
      _importTime = BackupSchedulerService.instance.importTime;
      _isExcelSyncEnabled = BackupSchedulerService.instance.isExcelSyncEnabled;
      _excelSyncFrequencyDays = BackupSchedulerService.instance.excelSyncFrequency;
    });
  }

  Future<void> _toggleAutoBackup(bool enabled) async {
    final l10n = AppLocalizations.of(context)!;
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseKey == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.supabaseCredentialsMissing)),
        );
      }
      return;
    }

    await BackupSchedulerService.instance.toggleBackup(
      enabled,
      supabaseUrl: supabaseUrl,
      supabaseKey: supabaseKey,
    );

    setState(() => _isSchedulerEnabled = enabled);
  }

  Future<void> _toggleAutoImport(bool enabled) async {
    final l10n = AppLocalizations.of(context)!;
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseKey == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.supabaseCredentialsMissing)),
        );
      }
      return;
    }

    await BackupSchedulerService.instance.toggleImport(
      enabled,
      supabaseUrl: supabaseUrl,
      supabaseKey: supabaseKey,
    );

    setState(() => _isImportSchedulerEnabled = enabled);
  }

  Future<void> _toggleExcelSync(bool enabled) async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseKey == null) return;

    await BackupSchedulerService.instance.toggleExcelSync(
      enabled,
      supabaseUrl: supabaseUrl,
      supabaseKey: supabaseKey,
    );

    setState(() => _isExcelSyncEnabled = enabled);
  }

  Future<void> _changeExcelSyncFrequency() async {
    final l10n = AppLocalizations.of(context)!;
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseKey == null) return;

    // simple dialog to pick value 1-30
    // user can change the days
    int? selectedDays = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempDays = _excelSyncFrequencyDays;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.syncFrequency),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(l10n.everyDays("$tempDays")),
                   Slider(
                     min: 1,
                     max: 30,
                     divisions: 29,
                     value: tempDays.toDouble(),
                     onChanged: (val) {
                       setState(() => tempDays = val.toInt());
                     },
                   ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, tempDays),
                  child: Text(l10n.save),
                ),
              ],
            );
          }
        );
      },
    );

    if (selectedDays != null && selectedDays != _excelSyncFrequencyDays) {
      await BackupSchedulerService.instance.updateExcelSyncFrequency(
        selectedDays,
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );
      setState(() => _excelSyncFrequencyDays = selectedDays);
    }
  }


  Future<void> _performManualExcelSync() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_supabase.isInitialized) {
      _showErrorDialog(l10n.supabaseNotConfigured, 
        l10n.businessProfileSetupMessage); 
      return;
    }

    setState(() {
      _isExcelSyncing = true;
    });

    try {
      final success = await BackgroundSyncService.syncSupabaseToExcel();

      if (!mounted) return;
      setState(() {
        _isExcelSyncing = false;
      });

      if (success) {
        final now = DateTime.now();
        await _backup.saveLastExcelSyncStats(time: now);
        if (!mounted) return;
        setState(() {
          _lastExcelSyncTime = now;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
             content: Text(l10n.excelExportSuccessMessage),
             backgroundColor: Colors.green,
           ),
        );
      } else {
        _showErrorDialog(l10n.excelExportFailed, l10n.connectionTimeout); // Generic error for now
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExcelSyncing = false);
      _showErrorDialog(l10n.excelExportFailed, e.toString());
    }
  }

  Future<void> _selectBackupTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _backupTime,
    );

    if (picked != null && picked != _backupTime) {
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseKey == null) return;

      await BackupSchedulerService.instance.updateBackupTime(
        picked,
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );

      setState(() => _backupTime = picked);
    }
  }

  Future<void> _selectImportTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _importTime,
    );

    if (picked != null && picked != _importTime) {
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseKey == null) return;

      await BackupSchedulerService.instance.updateImportTime(
        picked,
        supabaseUrl: supabaseUrl,
        supabaseKey: supabaseKey,
      );

      setState(() => _importTime = picked);
    }
  }

  Future<void> _checkConnection() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_supabase.isInitialized) {
      setState(() => _isConnected = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.supabaseNotConfigured),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isCheckingConnection = true);
    final result = await _supabase.testConnection();
    
    setState(() {
      _isConnected = result['success'] as bool;
      _isCheckingConnection = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] 
              ? l10n.connectedSuccessfully(result['latency'].toString())
              : l10n.connectionFailed(result['message'].toString())
          ),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _loadLastBackupTime() async {
    final stats = await _backup.getLastBackupStats();
    if (stats.containsKey('time')) {
      setState(() {
        _lastBackupTime = stats['time'] as DateTime;
        _lastBackupBillsCount = stats['billsCount'] as int;
        _lastBackupPaymentsCount = stats['paymentsCount'] as int;
      });
    }
  }

  Future<void> _loadLastImportTime() async {
    final stats = await _backup.getLastImportStats();
    if (stats.containsKey('time')) {
      setState(() {
        _lastImportTime = stats['time'] as DateTime;
        _lastImportBillsCount = stats['billsCount'] as int;
        _lastImportPaymentsCount = stats['paymentsCount'] as int;
      });
    }
  }

  Future<void> _loadLastExcelSyncTime() async {
    final stats = await _backup.getLastExcelSyncStats();
    if (stats.containsKey('time')) {
      setState(() {
        _lastExcelSyncTime = stats['time'] as DateTime;
      });
    }
  }

  Future<void> _performManualBackup() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_supabase.isInitialized) {
      _showErrorDialog(l10n.supabaseNotConfigured, 
        l10n.configureSupabaseMessage);
      return;
    }

    setState(() {
      _isBackingUp = true;
      _backupProgress = l10n.startingBackup;
    });

    try {
      final result = await _backup.performFullBackup(
        backupType: 'manual',
        onProgress: (message) {
          if (mounted) {
            setState(() => _backupProgress = message);
          }
        },
        l10n: l10n,
      );
      setState(() {
        _isBackingUp = false;
        _lastBackupTime = result.timestamp;
        _lastBackupBillsCount = result.billsSynced;
        _lastBackupPaymentsCount = result.paymentsSynced;
      });

      if (result.success) {
        _showSuccessDialog(result);
      } else {
        _showErrorDialog(l10n.backupFailed, result.errorMessage ?? l10n.unknownError);
      }
    } catch (e) {
      setState(() => _isBackingUp = false);
      _showErrorDialog(l10n.backupError, e.toString());
    }
  }

  void _showSuccessDialog(BackupResult result) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(l10n.backupSuccessful),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dataBackedUpSuccessfully),
            const SizedBox(height: 16),
            _buildStatRow(l10n.billsSynced, '${result.billsSynced}'),
            if (result.billsFailed > 0)
              _buildStatRow(l10n.billsFailed, '${result.billsFailed}', isError: true),
            _buildStatRow(l10n.paymentsSynced, '${result.paymentsSynced}'),
            if (result.paymentsFailed > 0)
              _buildStatRow(l10n.paymentsFailed, '${result.paymentsFailed}', isError: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _performManualImport() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_supabase.isInitialized) {
      _showErrorDialog(l10n.supabaseNotConfigured, 
        l10n.businessProfileSetupMessage); // Using existing descriptive string
      return;
    }

    // Confirm before overwriting local data
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importFromCloudConfirmTitle),
        content: Text(l10n.importFromCloudConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context, true);
            },
            child: Text(l10n.importNow),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRestoring = true;
      _backupProgress = l10n.loading; // Use localized loading string
    });

    try {
      final result = await _backup.restoreData(
        onProgress: (message) {
          if (mounted) {
             setState(() => _backupProgress = message);
          }
        },
        l10n: l10n,
      );
      setState(() {
        _isRestoring = false;
      });

      if (result.success) {
        setState(() {
          _lastImportTime = result.timestamp;
          _lastImportBillsCount = result.billsRestored;
          _lastImportPaymentsCount = result.paymentsRestored;
        });

        // Trigger global data refresh for all dependent screens (Reports, Bill Payments, etc.)
        if (mounted) {
          final invoiceProvider = context.read<InvoiceProvider>();
          await invoiceProvider.loadInvoices();
          debugPrint('UI Data Refreshed after successful import.');
        }

        _showRestoreSuccessDialog(result);
      } else {
        _showErrorDialog(l10n.importFailed, result.errorMessage ?? 'Unknown error');
      }
    } catch (e) {
      setState(() => _isRestoring = false);
      _showErrorDialog(l10n.importError, e.toString());
    }
  }

  void _showRestoreSuccessDialog(RestoreResult result) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(l10n.importSuccessful),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dataImportedSuccessfully),
            const SizedBox(height: 16),
            _buildStatRow(l10n.billsRestored, '${result.billsRestored}'),
            _buildStatRow(l10n.paymentsRestored, '${result.paymentsRestored}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isError ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupSettings),
        elevation: 0,
      ),
      body: (_isBackingUp || _isRestoring) ? _buildBackupProgress() : _buildBackupSettings(theme, l10n),
    );
  }

  Widget _buildBackupProgress() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ThemeTokens.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: ThemeTokens.spacingLg),
            Text(
              _backupProgress,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSettings(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: EdgeInsets.all(ThemeTokens.spacingMd),
      children: [
        // Connection Status Card
        Card(
          child: Padding(
            padding: EdgeInsets.all(ThemeTokens.spacingMd),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.cloud_done : Icons.cloud_off,
                      color: _isConnected ? Colors.green : Colors.grey,
                      size: 32,
                    ),
                    SizedBox(width: ThemeTokens.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.connectionStatus,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _isConnected 
                              ? l10n.connectedToSupabase 
                              : l10n.notConnected,
                            style: TextStyle(
                              color: _isConnected ? Colors.green : theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isConnected)
                      TextButton(
                        onPressed: _isCheckingConnection ? null : _checkConnection,
                        child: _isCheckingConnection
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.retry),
                      ),
                  ],
                ),
                if (!_isConnected) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_ethernet),
                    title: Text(l10n.testConnection),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _checkConnection,
                  ),
                ],
              ],
            ),
          ),
        ),

        SizedBox(height: ThemeTokens.spacingSm),

        // Cloud Backup Settings
        Card(
          child: Padding(
            padding: EdgeInsets.all(ThemeTokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.backup, color: theme.colorScheme.primary),
                    SizedBox(width: ThemeTokens.spacingSm),
                    Expanded(
                      child: Text(
                        l10n.backupSettings,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ThemeTokens.spacingSm),
                Text(l10n.aboutBackupsDescription),
                SizedBox(height: ThemeTokens.spacingMd),
                
                // Auto Backup Toggle
                SwitchListTile(
                  title: Text(l10n.enableAutomaticBackup),
                  subtitle: Text(l10n.automaticBackupDescription),
                  value: _isSchedulerEnabled,
                  onChanged: _isConnected ? _toggleAutoBackup : null,
                  contentPadding: EdgeInsets.zero,
                ),

                if (_isSchedulerEnabled) ...[
                  const Divider(),
                  ListTile(
                    title: Text(l10n.dailyBackupTime),
                    trailing: Text(
                      _backupTime.format(context),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    onTap: _isConnected ? _selectBackupTime : null,
                  ),
                ],

                const Divider(),
                
                SizedBox(height: ThemeTokens.spacingSm),
                
                // Manual Backup Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isConnected && !_isBackingUp && !_isRestoring 
                      ? () {
                          HapticFeedback.selectionClick();
                          _performManualBackup();
                        }
                      : null,
                    icon: _isBackingUp 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.backup),
                    label: Text(_isBackingUp ? l10n.loading : l10n.backupNow),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: ThemeTokens.spacingMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: ThemeTokens.spacingSm),

        // Cloud Restore Settings (Import)
        Card(
          child: Padding(
            padding: EdgeInsets.all(ThemeTokens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud_download, color: theme.colorScheme.primary),
                    SizedBox(width: ThemeTokens.spacingSm),
                    Expanded(
                      child: Text(
                        l10n.importFromSupabase,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ThemeTokens.spacingSm),
                Text(l10n.importFromSupabaseDescription),
                
                // Auto Import Toggle
                SwitchListTile(
                  title: Text(l10n.enableAutomaticImport),
                  subtitle: Text(l10n.automaticImportDescription),
                  value: _isImportSchedulerEnabled,
                  onChanged: _isConnected ? _toggleAutoImport : null,
                  contentPadding: EdgeInsets.zero,
                ),

                if (_isImportSchedulerEnabled) ...[
                  const Divider(),
                  ListTile(
                    title: Text(l10n.dailyImportTime),
                    trailing: Text(
                      _importTime.format(context),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    onTap: _isConnected ? _selectImportTime : null,
                  ),
                ],

                const Divider(),
                
                SizedBox(height: ThemeTokens.spacingSm),
                
                // Manual Restore Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isConnected && !_isRestoring && !_isBackingUp 
                      ? () {
                          HapticFeedback.selectionClick();
                          _confirmImport();
                        }
                      : null,
                    icon: _isRestoring 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.restore),
                    label: Text(_isRestoring ? l10n.loading : l10n.importNow),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: ThemeTokens.spacingMd,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: ThemeTokens.spacingSm),

        // Excel Sync Settings
        ExcelSyncSettingsCard(
          isExcelSyncEnabled: _isExcelSyncEnabled,
          isConnected: _isConnected,
          excelSyncFrequencyDays: _excelSyncFrequencyDays,
          onToggle: _toggleExcelSync,
          onFrequencyChange: _changeExcelSyncFrequency,
        ),

        SizedBox(height: ThemeTokens.spacingSm),

        // Manual Export
        ManualExportCard(
          isConnected: _isConnected,
          isSyncing: _isExcelSyncing,
          canExprot: _isConnected && !_isExcelSyncing && !_isBackingUp && !_isRestoring,
          onExport: _performManualExcelSync,
        ),

        SizedBox(height: ThemeTokens.spacingSm),
       
        // Automatic Backup Info
        BackupInfoCard(
          lastBackupTime: _lastBackupTime,
          billsCount: _lastBackupBillsCount,
          paymentsCount: _lastBackupPaymentsCount,
        ),

        SizedBox(height: ThemeTokens.spacingSm),

        // Automatic Restore Info
        RestoreInfoCard(
          lastImportTime: _lastImportTime,
          billsCount: _lastImportBillsCount,
          paymentsCount: _lastImportPaymentsCount,
        ),

        SizedBox(height: ThemeTokens.spacingSm),

        // Excel Export Info
        ExcelSyncStatusCard(
          lastSyncTime: _lastExcelSyncTime,
        ),

        SizedBox(height: ThemeTokens.spacingLg),
      ],
    );
  }
  void _confirmImport() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importFromCloudConfirmTitle),
        content: Text(l10n.importFromCloudConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _performManualImport();
            },
            child: Text(l10n.importNow),
          ),
        ],
      ),
    );
  }
}
