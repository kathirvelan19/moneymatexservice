import 'category.dart';
import 'payment_method.dart';

class Expense {
  final String? id;
  final double amount;
  final Category category;
  final DateTime date;
  final String? notes;
  final PaymentMethod paymentMethod;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
    required this.paymentMethod,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      category: Category.fromString(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      paymentMethod: PaymentMethod.fromString(json['paymentMethod'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String().split('T')[0],
      'notes': notes,
      'paymentMethod': paymentMethod.name,
    };
  }
}
