import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/expense.dart';
import '../models/scanned_receipt.dart';
import '../models/scanned_upi.dart';
import '../models/detected_payment.dart';

class ApiService {
  /// Base API URL pointing to the deployed backend service.
  /// Defaults to [ApiConfig.apiBaseUrl].
  static String baseUrl = ApiConfig.apiBaseUrl;

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Helper to handle network errors and format user-friendly messages.
  static String _formatNetworkError(dynamic error) {
    if (error is SocketException) {
      return 'Network connection failed. If the backend is hosted on Render free tier, it may be waking up from sleep. Please wait a moment and try again.';
    } else if (error is TimeoutException) {
      return 'Request timed out waiting for server response. Please check your internet connection or retry.';
    }
    return error.toString();
  }

  static Future<List<Expense>> fetchExpenses() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/expenses'), headers: _jsonHeaders)
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        return list.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load expenses (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(_formatNetworkError(e));
    }
  }

  static Future<Expense> createExpense(Expense expense) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/expenses'),
            headers: _jsonHeaders,
            body: json.encode(expense.toJson()),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Expense.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create expense (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(_formatNetworkError(e));
    }
  }

  static Future<Expense> updateExpense(String id, Expense expense) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/expenses/$id'),
            headers: _jsonHeaders,
            body: json.encode(expense.toJson()),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return Expense.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update expense (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(_formatNetworkError(e));
    }
  }

  static Future<void> deleteExpense(String id) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl/expenses/$id'), headers: _jsonHeaders)
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete expense (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(_formatNetworkError(e));
    }
  }

  static Future<ScannedReceipt> scanReceipt(String base64Image) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/ai/scan-receipt'),
            headers: _jsonHeaders,
            body: json.encode({'base64Image': base64Image}),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return ScannedReceipt.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to scan receipt (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(_formatNetworkError(e));
    }
  }

  static Future<ScannedUPI> scanUpi(String base64Image) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/ai/scan-upi'),
            headers: _jsonHeaders,
            body: json.encode({'base64Image': base64Image}),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return ScannedUPI.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to scan UPI screenshot (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(_formatNetworkError(e));
    }
  }

  static Future<List<String>> fetchInsights(List<Expense> expenses) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/ai/insights'),
            headers: _jsonHeaders,
            body: json.encode({
              'expenses': expenses.map((e) => e.toJson()).toList(),
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> insightsJson = data['insights'] ?? [];
        return insightsJson.map((e) => e.toString()).toList();
      } else {
        throw Exception('Failed to fetch insights (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(_formatNetworkError(e));
    }
  }

  static Future<DetectedPayment> detectPaymentNotification(String message, String sender) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/ai/parse-notification'),
            headers: _jsonHeaders,
            body: json.encode({
              'message': message,
              'sender': sender,
              'timestamp': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return DetectedPayment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to parse payment notification (HTTP ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception(_formatNetworkError(e));
    }
  }
}
