import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetController = TextEditingController();
  final _incomeController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  void _showEditBudgetDialog(BuildContext context, ExpenseProvider provider) {
    _budgetController.text = provider.targetBudget.toStringAsFixed(0);
    _incomeController.text = provider.monthlyIncome.toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Financial Targets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Income (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF79747E))),
            const SizedBox(height: 6),
            TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFAF9FD),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Monthly Spending Budget (₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF79747E))),
            const SizedBox(height: 6),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFAF9FD),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF79747E))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E43A5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final inc = double.tryParse(_incomeController.text);
              final bud = double.tryParse(_budgetController.text);
              if (inc != null && inc >= 0) provider.setMonthlyIncome(inc);
              if (bud != null && bud >= 0) provider.updateTargetBudget(bud);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget targets updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    // Calculate category spending
    final Map<Category, double> categorySpending = {};
    for (var exp in provider.expenses) {
      categorySpending[exp.category] = (categorySpending[exp.category] ?? 0.0) + exp.amount;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Budget Planner',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1D192B)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF5E43A5)),
            onPressed: () => _showEditBudgetDialog(context, provider),
          ),
        ],
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
                  // Main Target Card
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'MONTHLY BUDGET LIMIT',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF79747E), letterSpacing: 0.8),
                            ),
                            InkWell(
                              onTap: () => _showEditBudgetDialog(context, provider),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EEFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Adjust Limit',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5E43A5)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₹${provider.targetBudget.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF1D192B)),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spent: ₹${provider.monthlySpending.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF79747E), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Remaining: ₹${provider.remainingBudget.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: provider.remainingBudget >= 0 ? const Color(0xFF00BA88) : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (provider.budgetUtilizationPercent / 100).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: const Color(0xFFEFEBF8),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              provider.remainingBudget >= 0 ? const Color(0xFF5E43A5) : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Fixed Costs Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                          child: const Icon(Icons.lock_outline, color: Color(0xFF5E43A5), size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Fixed costs Included', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1D192B))),
                              SizedBox(height: 2),
                              Text('Rent, utility bills, subscriptions', style: TextStyle(fontSize: 11, color: Color(0xFF79747E))),
                            ],
                          ),
                        ),
                        Switch(
                          value: provider.fixedCostsIncluded,
                          onChanged: (val) => provider.toggleFixedCosts(val),
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF5E43A5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text('Category Spending', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D192B))),
                  const SizedBox(height: 12),

                  if (categorySpending.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFEBF6)),
                      ),
                      child: const Center(
                        child: Text('No categorized spending recorded yet.', style: TextStyle(color: Color(0xFF79747E), fontSize: 13)),
                      ),
                    )
                  else
                    ...categorySpending.entries.map((entry) {
                      final pct = provider.totalSpending > 0 ? (entry.value / provider.totalSpending * 100) : 0.0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFEFEBF6)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3EEFF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.circle, size: 12, color: Color(0xFF5E43A5)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.key.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                  Text('${pct.toStringAsFixed(1)}% of total spent', style: const TextStyle(fontSize: 11, color: Color(0xFF79747E))),
                                ],
                              ),
                            ),
                            Text(
                              '₹${entry.value.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1D192B)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
