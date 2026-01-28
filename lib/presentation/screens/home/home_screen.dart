import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../providers/invoice_provider.dart';
import '../billing/billing_screen.dart';
import '../bill_payments/bill_payments_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../description/description_list_screen.dart';
import 'widgets/home_bottom_navigation_bar.dart';
import 'widgets/exit_confirmation_dialog.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const BillPaymentsScreen(),
    const ReportsScreen(),
    const DescriptionListScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Auto-refresh data when entering Reports screen (index 1)
    if (index == 1) {
      context.read<InvoiceProvider>().loadInvoices();
    }
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => const ExitConfirmationDialog(),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        if (_selectedIndex != 0) {
          _onItemTapped(0);
          return;
        }
        
        final shouldExit = await _showExitConfirmation(context);
        if (shouldExit == true && context.mounted) {
          // Add a small delay to ensure dialog is fully dismissed 
          // before the system starts the exit transition.
          // This prevents transition collisions and black screen issues.
          await Future.delayed(const Duration(milliseconds: 300));
          if (context.mounted) {
            await SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        floatingActionButton: SizedBox(
          height: 64,
          width: 64,
          child: FloatingActionButton(
            onPressed: () async {
               // Navigate to Billing Screen (New Bill)
               final invoiceProvider = context.read<InvoiceProvider>();
               await Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const BillingScreen()),
               );
               invoiceProvider.loadInvoices();
            },
            heroTag: 'home_new_bill_fab',
            backgroundColor: ThemeTokens.primaryColor,
            shape: const CircleBorder(),
            elevation: 4,
            child: const Icon(Icons.add, size: 32, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: HomeBottomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
