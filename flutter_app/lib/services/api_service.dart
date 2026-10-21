import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import '../models/scanned_receipt.dart';
import '../models/scanned_upi.dart';
import '../models/detected_payment.dart';

class ApiService {
  static String baseUrl = 'http://localhost:8080/api';

  static Future<List<Expense>> fetchExpenses() async {
    final response = await http.get(Uri.parse('$baseUrl/expenses'));
    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(response.body);
      return list.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load expenses: ${response.statusCode}');
    }
  }

  static Future<Expense> createExpense(Expense expense) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expense.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Expense.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create expense: ${response.statusCode}');
    }
  }

  static Future<Expense> updateExpense(String id, Expense expense) async {
    final response = await http.put(
      Uri.parse('$baseUrl/expenses/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expense.toJson()),
    );
    if (response.statusCode == 200) {
      return Expense.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update expense: ${response.statusCode}');
    }
  }

  static Future<void> deleteExpense(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/expenses/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete expense: ${response.statusCode}');
    }
  }

  static Future<ScannedReceipt> scanReceipt(String base64Image) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/scan-receipt'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'base64Image': base64Image}),
    );
    if (response.statusCode == 200) {
      return ScannedReceipt.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to scan receipt: ${response.body}');
    }
  }

  static Future<ScannedUPI> scanUpi(String base64Image) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/scan-upi'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'base64Image': base64Image}),
    );
    if (response.statusCode == 200) {
      return ScannedUPI.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to scan UPI screenshot: ${response.body}');
    }
  }

  static Future<List<String>> fetchInsights(List<Expense> expenses) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/insights'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'expenses': expenses.map((e) => e.toJson()).toList(),
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> insightsJson = data['insights'] ?? [];
      return insightsJson.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to fetch insights');
    }
  }

  static Future<DetectedPayment> detectPaymentNotification(String message, String sender) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/parse-notification'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message': message,
        'sender': sender,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      return DetectedPayment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to parse payment notification: ${response.body}');
    }
  }
}

