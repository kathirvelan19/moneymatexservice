import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'receipt_scan_screen.dart';
import 'upi_scan_screen.dart';
import 'auto_detect_screen.dart';
import 'insights_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'More & Tools',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1D192B)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF5E43A5),
                          child: Text(
                            provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(provider.userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D192B))),
                              const SizedBox(height: 2),
                              Text(provider.userEmail, style: const TextStyle(fontSize: 12, color: Color(0xFF79747E))),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Color(0xFFB3261E)),
                          onPressed: () => provider.logout(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text('AI & Smart Extraction', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF79747E))),
                  const SizedBox(height: 10),

                  _menuTile(
                    context,
                    title: 'Gemini Receipt OCR',
                    subtitle: 'Extract merchant, total & taxes with Gemini 3.6',
                    icon: Icons.receipt_long_outlined,
                    destination: const ReceiptScanScreen(),
                  ),
                  _menuTile(
                    context,
                    title: 'UPI Screenshot Scanner',
                    subtitle: 'Parse GPay, PhonePe & Paytm payment confirmations',
                    icon: Icons.phone_android_outlined,
                    destination: const UpiScanScreen(),
                  ),
                  _menuTile(
                    context,
                    title: 'Automatic UPI Detection',
                    subtitle: 'Auto-detect incoming PhonePe, GPay, Paytm & SMS payments',
                    icon: Icons.bolt,
                    destination: const AutoDetectScreen(),
                  ),
                  _menuTile(
                    context,
                    title: 'AI Spending Insights',
                    subtitle: 'Behavioral financial intelligence by Google Gemini',
                    icon: Icons.auto_awesome_outlined,
                    destination: const InsightsScreen(),
                  ),

                  const SizedBox(height: 20),

                  const Text('Reports & Configuration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF79747E))),
                  const SizedBox(height: 10),

                  _menuTile(
                    context,
                    title: 'Charts & Analytics',
                    subtitle: 'Interactive pie, bar & line visualizations',
                    icon: Icons.bar_chart_outlined,
                    destination: const AnalyticsScreen(),
                  ),
                  _menuTile(
                    context,
                    title: 'Backend Settings',
                    subtitle: 'Spring Boot REST endpoint configuration',
                    icon: Icons.settings_outlined,
                    destination: const SettingsScreen(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget destination,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEBF6)),
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF5E43A5), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D192B))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF79747E))),
        trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF79747E)),
      ),
    );
  }
}
