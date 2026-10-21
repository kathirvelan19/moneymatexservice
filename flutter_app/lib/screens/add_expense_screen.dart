import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/payment_method.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  Category _selectedCategory = Category.Food;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.UPI;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      appBar: AppBar(
        title: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1D192B))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D192B)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Input Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFEFEBF6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Amount (₹)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF79747E))),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1D192B)),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF5E43A5)),
                              filled: true,
                              fillColor: const Color(0xFFFAF9FD),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty || double.tryParse(val) == null) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Details Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFEFEBF6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Selector
                          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF79747E))),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Category>(
                            initialValue: _selectedCategory,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFFAF9FD),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                            ),
                            items: Category.values.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCategory = val);
                            },
                          ),

                          const SizedBox(height: 16),

                          // Payment Method Selector
                          const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF79747E))),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<PaymentMethod>(
                            initialValue: _selectedPaymentMethod,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFFAF9FD),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                            ),
                            items: PaymentMethod.values.map((pm) {
                              return DropdownMenuItem(
                                value: pm,
                                child: Text(pm.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedPaymentMethod = val);
                            },
                          ),

                          const SizedBox(height: 16),

                          // Notes
                          const Text('Notes / Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF79747E))),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Grocery shopping, Swiggy',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF79747E)),
                              filled: true,
                              fillColor: const Color(0xFFFAF9FD),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E43A5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: provider.isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            final exp = Expense(
                              amount: double.parse(_amountController.text),
                              category: _selectedCategory,
                              date: _selectedDate,
                              notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                              paymentMethod: _selectedPaymentMethod,
                            );
                            await provider.addExpense(exp);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Expense recorded successfully!')),
                              );
                              Navigator.pop(context);
                            }
                          }
                        },
                        child: provider.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Save Expense', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
