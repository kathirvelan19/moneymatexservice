import 'category.dart';

class ScannedReceipt {
  final bool valid;
  final String? message;
  final String merchantName;
  final DateTime date;
  final double totalAmount;
  final double? taxAmount;
  final String originalImageBase64;
  final Category autoCategorized;

  ScannedReceipt({
    this.valid = true,
    this.message,
    required this.merchantName,
    required this.date,
    required this.totalAmount,
    this.taxAmount,
    required this.originalImageBase64,
    required this.autoCategorized,
  });

  factory ScannedReceipt.fromJson(Map<String, dynamic> json) {
    final isValid = json['valid'] as bool? ??
        json['isValid'] as bool? ??
        ((json['totalAmount'] as num?)?.toDouble() ?? 0.0) > 0;

    return ScannedReceipt(
      valid: isValid,
      message: json['message'] as String? ?? json['errorMessage'] as String?,
      merchantName: json['merchantName'] as String? ?? 'Unknown Merchant',
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
      totalAmount: (json['totalAmount'] as num? ?? 0.0).toDouble(),
      taxAmount: json['taxAmount'] != null ? (json['taxAmount'] as num).toDouble() : null,
      originalImageBase64: json['originalImageBase64'] as String? ?? '',
      autoCategorized: Category.fromString(json['autoCategorized'] as String? ?? 'Uncategorized'),
    );
  }
}
