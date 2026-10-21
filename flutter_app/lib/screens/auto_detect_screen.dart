import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/detected_payment.dart';
import '../providers/expense_provider.dart';

class AutoDetectScreen extends StatefulWidget {
  const AutoDetectScreen({Key? key}) : super(key: key);

  @override
  State<AutoDetectScreen> createState() => _AutoDetectScreenState();
}

class _AutoDetectScreenState extends State<AutoDetectScreen> {
  final TextEditingController _customMsgController = TextEditingController();
  String _selectedSender = 'Google Pay';
  bool _isProcessingCustom = false;

  final List<String> _senders = ['Google Pay', 'PhonePe', 'Paytm', 'CRED', 'HDFC Bank', 'SBI', 'ICICI Bank'];

  @override
  void dispose() {
    _customMsgController.dispose();
    super.dispose();
  }

  Future<void> _processCustomNotification(ExpenseProvider provider) async {
    final text = _customMsgController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an SMS or notification text to parse')),
      );
      return;
    }

    setState(() => _isProcessingCustom = true);

    final detected = await provider.processIncomingNotification(text, _selectedSender);

    setState(() => _isProcessingCustom = false);

    if (mounted) {
      if (detected != null) {
        _customMsgController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF00BA88),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Detected: ₹${detected.amount.toStringAsFixed(2)} to ${detected.merchant}')),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text('Could not extract valid debit transaction from this message.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'UPI Auto-Detection',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1D192B)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: provider.autoDetectionActive ? const Color(0xFF00BA88).withValues(alpha: 0.15) : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: provider.autoDetectionActive ? const Color(0xFF00BA88) : Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    provider.autoDetectionActive ? 'ACTIVE' : 'PAUSED',
                    style: TextStyle(
                      color: provider.autoDetectionActive ? const Color(0xFF00BA88) : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D192B)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // MAIN HERO STATUS CARD
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E195E), Color(0xFF5E43A5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5E43A5).withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.bolt, color: Color(0xFFFFD54F), size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Automatic Payment Detection',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                                    ),
                                    Text(
                                      'Google Pay • PhonePe • Paytm • SMS',
                                      style: TextStyle(color: Color(0xFFD7C7F7), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              value: provider.autoDetectionActive,
                              onChanged: (val) => provider.toggleAutoDetection(val),
                              activeThumbColor: Colors.white,
                              activeTrackColor: const Color(0xFF00BA88),
                              inactiveTrackColor: Colors.white24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          provider.autoDetectionActive
                              ? 'Automatic detection is listening for UPI payment notifications and bank SMS on this device. Expenses are parsed instantly using AI.'
                              : 'Automatic detection is currently turned OFF. Toggle on to auto-log transactions.',
                          style: const TextStyle(color: Color(0xFFEFE8FC), fontSize: 12, height: 1.35),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PREFERENCES ROW (Auto-Log Directly vs Confirm)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFEBF6)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_mode, color: Color(0xFF5E43A5), size: 22),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instant Auto-Log to Ledger',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1D192B)),
                              ),
                              Text(
                                'Record detected payments automatically without prompt',
                                style: TextStyle(color: Color(0xFF79747E), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: provider.autoLogDirectly,
                          onChanged: (val) => provider.toggleAutoLogDirectly(val),
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF5E43A5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 1-CLICK LIVE TEST SIMULATION BOX
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEBF6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EEFF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.play_circle_outline, color: Color(0xFF5E43A5), size: 18),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Test Live Mobile Notifications (1-Click)',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1D192B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap any button below to simulate an incoming payment notification from your phone. Watch it get detected and parsed in real time!',
                          style: TextStyle(color: Color(0xFF79747E), fontSize: 12),
                        ),
                        const SizedBox(height: 14),

                        // Simulation Grid Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _simulationButton(
                                label: 'Google Pay',
                                subtitle: 'Swiggy ₹385',
                                icon: Icons.g_mobiledata,
                                color: const Color(0xFF1A73E8),
                                onTap: () => provider.simulatePresetNotification('gpay'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _simulationButton(
                                label: 'PhonePe',
                                subtitle: 'Uber ₹520',
                                icon: Icons.payments,
                                color: const Color(0xFF5F259F),
                                onTap: () => provider.simulatePresetNotification('phonepe'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _simulationButton(
                                label: 'Paytm UPI',
                                subtitle: 'D-Mart ₹1,450',
                                icon: Icons.account_balance_wallet,
                                color: const Color(0xFF002E6E),
                                onTap: () => provider.simulatePresetNotification('paytm'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _simulationButton(
                                label: 'Bank SMS',
                                subtitle: 'Airtel ₹799',
                                icon: Icons.sms,
                                color: const Color(0xFF00BA88),
                                onTap: () => provider.simulatePresetNotification('bank'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CUSTOM NOTIFICATION PARSER INPUT
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEFEBF6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paste Any Payment SMS or Notification',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1D192B)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Test with real notification text from your phone:',
                          style: TextStyle(color: Color(0xFF79747E), fontSize: 11.5),
                        ),
                        const SizedBox(height: 12),

                        // Sender Dropdown
                        Row(
                          children: [
                            const Text('Sender: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF79747E))),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _selectedSender,
                              underline: const SizedBox(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF5E43A5)),
                              items: _senders.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedSender = val);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        TextField(
                          controller: _customMsgController,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'e.g. Paid Rs.350 to Starbucks on GPay. Ref: 409182910',
                            filled: true,
                            fillColor: const Color(0xFFFAF9FD),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                          ),
                        ),

                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5E43A5),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: _isProcessingCustom
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.auto_awesome, size: 18),
                            label: Text(_isProcessingCustom ? 'Parsing with Gemini AI...' : 'Run Auto-Detection'),
                            onPressed: _isProcessingCustom ? null : () => _processCustomNotification(provider),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // DETECTED PAYMENTS FEED
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detected Payments Stream',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1D192B)),
                      ),
                      Text(
                        '${provider.detectedPayments.length} Detected',
                        style: const TextStyle(color: Color(0xFF79747E), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (provider.detectedPayments.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFEFEBF6)),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(Icons.notifications_active_outlined, color: Color(0xFF5E43A5), size: 36),
                            SizedBox(height: 10),
                            Text('No payments detected yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1D192B))),
                            SizedBox(height: 4),
                            Text('Tap one of the test buttons above to simulate a live notification!', style: TextStyle(color: Color(0xFF79747E), fontSize: 11.5)),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.detectedPayments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final payment = provider.detectedPayments[index];
                        return _detectedPaymentTile(payment, provider);
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _simulationButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: color)),
                  Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Color(0xFF79747E), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detectedPaymentTile(DetectedPayment payment, ExpenseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
            child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF5E43A5), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4D9FA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        payment.paymentApp,
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF5E43A5)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        payment.merchant,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1D192B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment.category.name} • ${payment.dateTime.toString().split(' ')[0]}',
                  style: const TextStyle(color: Color(0xFF79747E), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1D192B)),
              ),
              const SizedBox(height: 4),
              payment.isLogged
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F9F3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 10, color: Color(0xFF00BA88)),
                          SizedBox(width: 2),
                          Text('Logged', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF00BA88))),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 26,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BA88),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () => provider.confirmDetectedPayment(payment),
                        child: const Text('Add', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
