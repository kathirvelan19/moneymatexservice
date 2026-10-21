import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'budget_screen.dart';
import 'goals_screen.dart';
import 'more_screen.dart';
import 'add_expense_screen.dart';
import 'receipt_scan_screen.dart';
import 'upi_scan_screen.dart';
import 'auto_detect_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEBF6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Record',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D192B)),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose how you want to record your transaction',
                style: TextStyle(fontSize: 12, color: Color(0xFF79747E)),
              ),
              const SizedBox(height: 20),
              _modalActionTile(
                icon: Icons.edit_note,
                title: 'Manual Expense Entry',
                subtitle: 'Enter amount, category and notes manually',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
                },
              ),
              const SizedBox(height: 10),
              _modalActionTile(
                icon: Icons.receipt_long_outlined,
                title: 'Gemini Receipt OCR',
                subtitle: 'Scan receipt with camera or gallery',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiptScanScreen()));
                },
              ),
              const SizedBox(height: 10),
              _modalActionTile(
                icon: Icons.phone_android_outlined,
                title: 'UPI Screenshot Parser',
                subtitle: 'Extract details from GPay, PhonePe, Paytm',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UpiScanScreen()));
                },
              ),
              const SizedBox(height: 10),
              _modalActionTile(
                icon: Icons.bolt,
                title: 'Automatic UPI Payment Detection',
                subtitle: 'Auto-detect live notifications & bank SMS',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AutoDetectScreen()));
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9FD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFEBF6)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF5E43A5), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D192B))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF79747E))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF79747E)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onViewTransactionsClick: () => _navigateToTab(1),
        onAddExpenseClick: () => _showAddModal(context),
      ),
      const TransactionsScreen(),
      const BudgetScreen(),
      const GoalsScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // PURPLE SQUIRCLE FAB MATCHING USER SCREENSHOT
      floatingActionButton: FloatingActionButton(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF5E43A5),
        onPressed: () => _showAddModal(context),
        child: const Icon(Icons.add, color: Colors.white, size: 26),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEFEBF6), width: 1.0)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _navigateToTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF5E43A5),
          unselectedItemColor: const Color(0xFF79747E),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded, size: 22),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined, size: 22),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined, size: 22),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined, size: 22),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_rounded, size: 22),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
