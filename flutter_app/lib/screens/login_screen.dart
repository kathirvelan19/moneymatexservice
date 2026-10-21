import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoadingGoogle = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand Logo Circle
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E43A5),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5E43A5).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('U', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title & Subtitle
                  const Text(
                    'MoneyTrace',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1D192B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your finances at a glance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF79747E),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Main Card
                  Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5E43A5).withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D192B)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sign in to access your ledger and budget tracker',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Color(0xFF79747E)),
                        ),

                        const SizedBox(height: 24),

                        // Google Sign-In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFFEFEBF6), width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: _isLoadingGoogle
                                ? null
                                : () async {
                                    setState(() => _isLoadingGoogle = true);
                                    await Future.delayed(const Duration(milliseconds: 400));
                                    if (mounted) {
                                      provider.loginWithGoogle(
                                        name: 'User',
                                        email: 'user@monematex.com',
                                      );
                                      setState(() => _isLoadingGoogle = false);
                                    }
                                  },
                            child: _isLoadingGoogle
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5E43A5)),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                                        height: 20,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 22, color: Color(0xFF4285F4)),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          color: Color(0xFF1D192B),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Demo Mode Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E43A5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              provider.loginAsGuest();
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.rocket_launch_outlined, size: 17),
                                SizedBox(width: 8),
                                Text(
                                  'Enter Interactive Demo Mode',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Feature Highlights
                  Row(
                    children: [
                      Expanded(
                        child: _featureChip(Icons.receipt_long_outlined, 'Receipt OCR'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _featureChip(Icons.phone_android_outlined, 'UPI Parsing'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _featureChip(Icons.auto_awesome_outlined, 'Gemini 3.6'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEBF6)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5E43A5)),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D192B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
