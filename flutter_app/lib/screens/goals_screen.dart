import 'package:flutter/material.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Savings Goals',
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
                  // Total Saved Overview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL PROGRESS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF79747E), letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '₹85,000 / ₹1,50,000',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1D192B)),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: const LinearProgressIndicator(
                            value: 0.56,
                            minHeight: 6,
                            backgroundColor: Color(0xFFEFEBF8),
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5E43A5)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text('Active Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D192B))),
                  const SizedBox(height: 12),

                  _goalCard('Emergency Fund', '₹50,000', '₹50,000', 1.0, Icons.shield_outlined, const Color(0xFF00BA88)),
                  _goalCard('Startup Runway', '₹25,000', '₹75,000', 0.33, Icons.rocket_launch_outlined, const Color(0xFF5E43A5)),
                  _goalCard('Hardware Upgrade', '₹10,000', '₹25,000', 0.40, Icons.laptop_mac_outlined, const Color(0xFFF59E0B)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _goalCard(String name, String saved, String target, double progress, IconData icon, Color color) {
    final pct = (progress * 100).toInt();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFEBF6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D192B))),
                    Text('$saved of $target', style: const TextStyle(fontSize: 11.5, color: Color(0xFF79747E))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9FD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEFEBF6)),
                ),
                child: Text('$pct%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5E43A5))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFEFEBF8),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
