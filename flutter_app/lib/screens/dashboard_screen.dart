import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import 'receipt_scan_screen.dart';
import 'upi_scan_screen.dart';
import 'auto_detect_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onViewTransactionsClick;
  final VoidCallback? onAddExpenseClick;

  const DashboardScreen({
    Key? key,
    this.onViewTransactionsClick,
    this.onAddExpenseClick,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatIndianCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.notifications_outlined, color: Color(0xFF5E43A5)),
                SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1D192B)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your finances are healthy and under budget for this month!',
              style: TextStyle(color: Color(0xFF79747E), fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E43A5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    final monthlyIncome = provider.monthlyIncome;
    final monthlySpent = provider.monthlySpending;
    final availableThisMonth = provider.availableThisMonth;
    final targetBudget = provider.targetBudget;

    final spentPercent = targetBudget > 0 ? (monthlySpent / targetBudget * 100) : 0.0;
    final isUnderBudget = monthlySpent <= targetBudget;
    final budgetDiffPercent = isUnderBudget
        ? (targetBudget > 0 ? ((targetBudget - monthlySpent) / targetBudget * 100) : 0.0)
        : ((monthlySpent - targetBudget) / targetBudget * 100);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: RefreshIndicator(
              color: const Color(0xFF5E43A5),
              onRefresh: () => provider.loadExpenses(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP HEADER ROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF5E43A5),
                          child: Text(
                            provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getGreeting()}, ${provider.userName}',
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D192B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Your finances at a glance',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF79747E),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none_outlined,
                            color: Color(0xFF1D192B),
                            size: 22,
                          ),
                          onPressed: () => _showNotificationSheet(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // QUICK AI SCANNING SHORTCUTS
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiptScanScreen())),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF5E43A5), Color(0xFF7A57CD)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF5E43A5).withValues(alpha: 0.22),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.receipt_long, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Scan Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                                        Text('Gemini OCR', style: TextStyle(color: Color(0xFFE4D9FA), fontSize: 10.5, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpiScanScreen())),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE4D9FA), width: 1.3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF5E43A5).withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00BA88).withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.qr_code_scanner, color: Color(0xFF00BA88), size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Scan UPI', style: TextStyle(color: Color(0xFF1D192B), fontWeight: FontWeight.w800, fontSize: 13)),
                                        Text('GPay • PhonePe', style: TextStyle(color: Color(0xFF79747E), fontSize: 10.5, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ACTIVE PAYMENT DETECTED ALERT BANNER
                    if (provider.activeAlertPayment != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EEFF),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFF5E43A5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5E43A5).withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF5E43A5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.bolt, color: Colors.white, size: 16),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${provider.activeAlertPayment!.paymentApp} Payment Detected!',
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF5E43A5), fontSize: 13.5),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF79747E)),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => provider.dismissAlertPayment(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        provider.activeAlertPayment!.merchant,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1D192B)),
                                      ),
                                      Text(
                                        'Category: ${provider.activeAlertPayment!.category.name}',
                                        style: const TextStyle(color: Color(0xFF79747E), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${provider.activeAlertPayment!.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF00BA88)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00BA88),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Add to Ledger Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    onPressed: () => provider.confirmDetectedPayment(provider.activeAlertPayment!),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF79747E)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  onPressed: () => provider.dismissAlertPayment(),
                                  child: const Text('Dismiss', style: TextStyle(color: Color(0xFF79747E), fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // AUTO-DETECTION ENGINE STATUS BAR
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AutoDetectScreen())),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEFEBF6)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: provider.autoDetectionActive ? const Color(0xFF00BA88) : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'UPI Auto-Detection: Active',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1D192B)),
                                  ),
                                  Text(
                                    'Listening for PhonePe • Google Pay • Paytm • SMS',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF79747E)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EEFF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Test / Manage', style: TextStyle(color: Color(0xFF5E43A5), fontWeight: FontWeight.bold, fontSize: 11)),
                                  SizedBox(width: 2),
                                  Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF5E43A5)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5E43A5).withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Label + Status Pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'AVAILABLE THIS MONTH',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF79747E),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EEFF),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFE4D9FA)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.shield_outlined,
                                      size: 11,
                                      color: Color(0xFF5E43A5),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Healthy',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF5E43A5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Big Available Amount
                          Text(
                            _formatIndianCurrency(availableThisMonth),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1D192B),
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Income & Spent Split Boxes
                          Row(
                            children: [
                              // Income Box
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF9FD),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFF3EFFB)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Income',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF79747E),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatIndianCurrency(monthlyIncome),
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1D192B),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_upward,
                                            size: 14,
                                            color: Color(0xFF00BA88),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Spent Box
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAF9FD),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFF3EFFB)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Spent',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF79747E),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatIndianCurrency(monthlySpent),
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1D192B),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_downward,
                                            size: 14,
                                            color: Color(0xFF79747E),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CARD 2: THIS MONTH
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5E43A5).withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Title + Receipt Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'This Month',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1D192B),
                                ),
                              ),
                              Icon(
                                Icons.receipt_long_outlined,
                                color: Color(0xFF5E43A5),
                                size: 19,
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Total spent',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF79747E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Spent Amount + Under budget Badge
                          Row(
                            children: [
                              Text(
                                _formatIndianCurrency(monthlySpent),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1D192B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isUnderBudget
                                      ? const Color(0xFFE6F9F3)
                                      : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isUnderBudget
                                        ? const Color(0xFFC1F2E2)
                                        : const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isUnderBudget ? Icons.arrow_downward : Icons.arrow_upward,
                                      size: 11,
                                      color: isUnderBudget
                                          ? const Color(0xFF00BA88)
                                          : const Color(0xFFDC2626),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      isUnderBudget
                                          ? '${budgetDiffPercent.toStringAsFixed(0)}% Under budget'
                                          : '${budgetDiffPercent.toStringAsFixed(0)}% Over budget',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: isUnderBudget
                                            ? const Color(0xFF00BA88)
                                            : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Monthly spending progress bar labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Monthly spending',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF79747E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${spentPercent.toStringAsFixed(0)}% of ${_formatIndianCurrency(targetBudget)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF79747E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: (spentPercent / 100).clamp(0.0, 1.0),
                              minHeight: 5,
                              backgroundColor: const Color(0xFFEFEBF8),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5E43A5)),
                            ),
                          ),

                          const SizedBox(height: 16),
                          const Divider(height: 1, color: Color(0xFFF1EFF8)),
                          const SizedBox(height: 14),

                          // Fixed costs toggle row
                          Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                size: 16,
                                color: Color(0xFF5E43A5),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Fixed costs Included',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1D192B),
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: provider.fixedCostsIncluded,
                                onChanged: (val) => provider.toggleFixedCosts(val),
                                activeThumbColor: Colors.white,
                                activeTrackColor: const Color(0xFF5E43A5),
                                inactiveTrackColor: const Color(0xFFEFEBF8),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // View Transactions Button
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF5E43A5), width: 1.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.white,
                              ),
                              onPressed: widget.onViewTransactionsClick,
                              child: const Text(
                                'View Transactions →',
                                style: TextStyle(
                                  color: Color(0xFF5E43A5),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CARD 3: BUDGET
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5E43A5).withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Title + Pie chart Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Budget',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1D192B),
                                ),
                              ),
                              Icon(
                                Icons.pie_chart_outline,
                                color: Color(0xFF5E43A5),
                                size: 19,
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Budget Status Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Allocated Monthly Budget',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF79747E)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatIndianCurrency(targetBudget),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1D192B),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EEFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${provider.expenses.length} logs',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5E43A5),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Category Mini Indicator Pills
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _categoryMiniChip('Food', Icons.fastfood_outlined),
                              _categoryMiniChip('Travel', Icons.directions_car_outlined),
                              _categoryMiniChip('Shopping', Icons.shopping_bag_outlined),
                              _categoryMiniChip('Bills', Icons.receipt_outlined),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60), // Room for bottom padding
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryMiniChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9FD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEFEBF6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF5E43A5)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D192B),
            ),
          ),
        ],
      ),
    );
  }
}
