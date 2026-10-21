import 'category.dart';

class ScannedUPI {
  final double paidAmount;
  final String receiverName;
  final DateTime dateTime;
  final String transactionId;
  final String originalImageBase64;
  final Category autoCategorized;

  ScannedUPI({
    required this.paidAmount,
    required this.receiverName,
    required this.dateTime,
    required this.transactionId,
    required this.originalImageBase64,
    required this.autoCategorized,
  });

  factory ScannedUPI.fromJson(Map<String, dynamic> json) {
    return ScannedUPI(
      paidAmount: (json['paidAmount'] as num? ?? 0.0).toDouble(),
      receiverName: json['receiverName'] as String? ?? 'Unknown Receiver',
      dateTime: DateTime.parse(json['dateTime'] as String? ?? DateTime.now().toIso8601String()),
      transactionId: json['transactionId'] as String? ?? 'N/A',
      originalImageBase64: json['originalImageBase64'] as String? ?? '',
      autoCategorized: Category.fromString(json['autoCategorized'] as String? ?? 'Uncategorized'),
    );
  }
}
