import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/category.dart';
import '../models/expense.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  Category? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    var filtered = provider.expenses.where((exp) {
      final matchesQuery = _searchQuery.isEmpty ||
          (exp.notes ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          exp.category.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || exp.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Transactions',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Color(0xFF1D192B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF5E43A5)),
            onPressed: () => provider.loadExpenses(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                // Search & Filter Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFEFEBF6)),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: 'Search transactions...',
                            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF79747E)),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF5E43A5), size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () => setState(() => _searchQuery = ''),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Category Filter Pills
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _filterChip('All', null),
                            ...Category.values.map((cat) => _filterChip(cat.name, cat)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Transactions List
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF5E43A5)))
                      : filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3EEFF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.receipt_long_outlined, size: 40, color: Color(0xFF5E43A5)),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No transactions found',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D192B)),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Log an expense or scan a receipt to see it here.',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF79747E)),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final exp = filtered[index];
                                return _transactionTile(exp, provider);
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, Category? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5E43A5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF5E43A5) : const Color(0xFFEFEBF6),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF79747E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _transactionTile(Expense exp, ExpenseProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEBF6)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getCategoryIcon(exp.category), color: const Color(0xFF5E43A5), size: 20),
        ),
        title: Text(
          exp.notes != null && exp.notes!.isNotEmpty ? exp.notes! : exp.category.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1D192B)),
        ),
        subtitle: Row(
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(exp.date),
              style: const TextStyle(fontSize: 11, color: Color(0xFF79747E)),
            ),
            const Text(' • ', style: TextStyle(color: Color(0xFF79747E))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF9FD),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFEFEBF6)),
              ),
              child: Text(
                exp.paymentMethod.name,
                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF5E43A5)),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '-₹${exp.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1D192B)),
            ),
            if (exp.id != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFB3261E)),
                onPressed: () => provider.deleteExpense(exp.id!),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(Category cat) {
    switch (cat) {
      case Category.Food: return Icons.fastfood_outlined;
      case Category.Travel: return Icons.directions_car_outlined;
      case Category.Shopping: return Icons.shopping_bag_outlined;
      case Category.Bills: return Icons.receipt_outlined;
      case Category.Recharge: return Icons.phone_android_outlined;
      case Category.Entertainment: return Icons.movie_outlined;
      case Category.Healthcare: return Icons.medical_services_outlined;
      default: return Icons.category_outlined;
    }
  }
}
