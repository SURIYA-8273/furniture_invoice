import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/backup_service.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _statusMessage = 'Checking connection...';

  @override
  void initState() {
    super.initState();
    _checkAndSync();
  }

  Future<void> _checkAndSync() async {
    // Artificial delay to show the splashing/loading effect briefly
    await Future.delayed(const Duration(seconds: 1));

    try {
      final isConnected = await SupabaseService.instance.isConnected();

      if (isConnected) {
        if (mounted) {
          setState(() {
            _statusMessage = 'Connected! Backing up data...';
          });
        }
        
        // 1. Run Backup (Export)
        await BackupService.instance.performFullBackup(
          backupType: 'automatic',
          onProgress: (status) {
             // Optional: showing backup progress
          },
        );

        // Allow UI to breathe between heavy operations
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          setState(() {
            _statusMessage = 'Downloading updates...';
          });
        }

        // 2. Run Restore (Import)
        await BackupService.instance.restoreData(
          onProgress: (status) {
            if (mounted) {
              setState(() {
                _statusMessage = status;
              });
            }
          },
        );
      } else {
        if (mounted) {
          setState(() {
            _statusMessage = 'No internet connection. Starting offline...';
          });
        }
        // Brief delay to let user see "Starting offline"
        await Future.delayed(const Duration(milliseconds: 800));
      }
    } catch (e) {
      debugPrint('Error during auto-sync: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Error syncing data. Proceeding...';
        });
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.store, size: 100, color: Colors.brown);
              },
            ),
            const SizedBox(height: 40),
            
            // Loading Indicator
            const CircularProgressIndicator(
              color: Colors.brown,
            ),
            const SizedBox(height: 20),
            
            // Status Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
