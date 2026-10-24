import 'category.dart';

class DetectedPayment {
  final bool valid;
  final String? message;
  final String id;
  final double amount;
  final String merchant;
  final String paymentApp;
  final String transactionId;
  final DateTime dateTime;
  final Category category;
  final bool isDebit;
  final String rawMessage;
  final String summary;
  bool isLogged;

  DetectedPayment({
    this.valid = true,
    this.message,
    required this.id,
    required this.amount,
    required this.merchant,
    required this.paymentApp,
    required this.transactionId,
    required this.dateTime,
    required this.category,
    this.isDebit = true,
    this.rawMessage = '',
    this.summary = '',
    this.isLogged = false,
  });

  factory DetectedPayment.fromJson(Map<String, dynamic> json) {
    final isValid = json['valid'] as bool? ??
        json['isValid'] as bool? ??
        (((json['paidAmount'] as num?)?.toDouble() ?? (json['amount'] as num?)?.toDouble() ?? 0.0) > 0);

    Category cat = Category.Others;
    if (json['autoCategorized'] != null) {
      final catStr = json['autoCategorized'].toString();
      cat = Category.values.firstWhere(
        (c) => c.name.toLowerCase() == catStr.toLowerCase(),
        orElse: () => Category.Others,
      );
    }

    DateTime dt = DateTime.now();
    if (json['dateTime'] != null) {
      try {
        dt = DateTime.parse(json['dateTime'].toString());
      } catch (_) {}
    }

    return DetectedPayment(
      valid: isValid,
      message: json['message'] as String? ?? json['errorMessage'] as String?,
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: (json['paidAmount'] as num?)?.toDouble() ?? (json['amount'] as num?)?.toDouble() ?? 0.0,
      merchant: json['merchant'] ?? json['receiverName'] ?? 'Unknown Merchant',
      paymentApp: json['paymentApp'] ?? 'UPI',
      transactionId: json['transactionId'] ?? 'N/A',
      dateTime: dt,
      category: cat,
      isDebit: json['isDebit'] ?? true,
      rawMessage: json['rawMessage'] ?? '',
      summary: json['summary'] ?? '',
      isLogged: json['isLogged'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paidAmount': amount,
      'merchant': merchant,
      'paymentApp': paymentApp,
      'transactionId': transactionId,
      'dateTime': dateTime.toIso8601String(),
      'autoCategorized': category.name,
      'isDebit': isDebit,
      'rawMessage': rawMessage,
      'summary': summary,
      'isLogged': isLogged,
    };
  }
}
