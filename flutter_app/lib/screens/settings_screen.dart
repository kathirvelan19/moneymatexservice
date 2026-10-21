import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/expense_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController(text: ApiService.baseUrl);

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1D192B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D192B)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF5E43A5),
                          child: Text(
                            provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                provider.userName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D192B)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                provider.userEmail,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF79747E)),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EEFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  provider.isGuest ? '🚀 Demo Mode Active' : '🔒 Verified Account',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5E43A5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Color(0xFFB3261E)),
                          tooltip: 'Sign Out',
                          onPressed: () => provider.logout(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Backend Connection Card
                  const Text('Backend Connection', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF79747E))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEBF6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Spring Boot REST API Base URL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF79747E))),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFFAF9FD),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E43A5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              ApiService.baseUrl = _urlController.text.trim();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Backend URL saved successfully!')),
                              );
                            },
                            child: const Text('Save Backend URL', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Architecture Information
                  const Text('System Architecture', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF79747E))),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEBF6)),
                    ),
                    child: Column(
                      children: [
                        _architectureRow('Frontend Framework', 'Flutter 3 (Cross-Platform)'),
                        const Divider(height: 20, color: Color(0xFFF1EFF8)),
                        _architectureRow('Backend Service', 'Spring Boot 3.3.4 (Java 17)'),
                        const Divider(height: 20, color: Color(0xFFF1EFF8)),
                        _architectureRow('AI Engine', 'Google Gemini 3.6 Flash'),
                        const Divider(height: 20, color: Color(0xFFF1EFF8)),
                        _architectureRow('Extraction Services', 'Receipt OCR & UPI Parsing'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _architectureRow(String title, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF79747E), fontWeight: FontWeight.w500)),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D192B))),
      ],
    );
  }
}
