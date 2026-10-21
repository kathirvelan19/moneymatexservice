import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/payment_method.dart';
import '../models/scanned_receipt.dart';
import '../models/scanned_upi.dart';
import '../models/detected_payment.dart';
import '../services/api_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  List<String> _insights = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Auto Payment Detection State
  bool _autoDetectionActive = true;
  bool _autoLogDirectly = false;
  List<DetectedPayment> _detectedPayments = [];
  DetectedPayment? _activeAlertPayment;

  // Budget & Financial Overview State
  double _monthlyIncome = 25000.0;
  double _targetBudget = 25000.0;
  bool _fixedCostsIncluded = true;

  // Authentication & User State
  bool _isLoggedIn = true;
  bool _isGuest = true;
  String _userName = 'User';
  String _userEmail = 'user@monematex.com';
  String? _userPhotoUrl;

  List<Expense> get expenses => _expenses;
  List<String> get insights => _insights;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get autoDetectionActive => _autoDetectionActive;
  bool get autoLogDirectly => _autoLogDirectly;
  List<DetectedPayment> get detectedPayments => _detectedPayments;
  DetectedPayment? get activeAlertPayment => _activeAlertPayment;


  double get monthlyIncome => _monthlyIncome;
  double get targetBudget => _targetBudget;
  bool get fixedCostsIncluded => _fixedCostsIncluded;

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get userPhotoUrl => _userPhotoUrl;

  double get totalSpending => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get monthlySpending {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get availableThisMonth => (_monthlyIncome - monthlySpending).clamp(0.0, double.infinity);

  double get remainingBudget => _targetBudget - monthlySpending;

  double get budgetUtilizationPercent {
    if (_targetBudget <= 0) return 0.0;
    return (monthlySpending / _targetBudget * 100).clamp(0.0, 999.0);
  }

  void setMonthlyIncome(double income) {
    _monthlyIncome = income;
    notifyListeners();
  }

  void updateTargetBudget(double newBudget) {
    _targetBudget = newBudget;
    notifyListeners();
  }

  void toggleFixedCosts(bool value) {
    _fixedCostsIncluded = value;
    notifyListeners();
  }

  void loginAsGuest() {
    _isLoggedIn = true;
    _isGuest = true;
    _userName = 'User';
    _userEmail = 'user@monematex.com';
    _userPhotoUrl = null;
    notifyListeners();
    loadExpenses();
  }

  void loginWithGoogle({String? name, String? email, String? photoUrl}) {
    _isLoggedIn = true;
    _isGuest = false;
    _userName = name ?? 'User';
    _userEmail = email ?? 'user@gmail.com';
    _userPhotoUrl = photoUrl;
    notifyListeners();
    loadExpenses();
  }

  void logout() {
    _isLoggedIn = false;
    _expenses = [];
    _insights = [];
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    _setLoading(true);
    try {
      _expenses = await ApiService.fetchExpenses();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addExpense(Expense expense) async {
    _setLoading(true);
    try {
      final created = await ApiService.createExpense(expense);
      _expenses.insert(0, created);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await ApiService.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<ScannedReceipt?> scanReceipt(String base64Image) async {
    _setLoading(true);
    try {
      final result = await ApiService.scanReceipt(base64Image);
      _errorMessage = null;
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<ScannedUPI?> scanUpi(String base64Image) async {
    _setLoading(true);
    try {
      final result = await ApiService.scanUpi(base64Image);
      _errorMessage = null;
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchInsights() async {
    _setLoading(true);
    try {
      _insights = await ApiService.fetchInsights(_expenses);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void toggleAutoDetection(bool value) {
    _autoDetectionActive = value;
    notifyListeners();
  }

  void toggleAutoLogDirectly(bool value) {
    _autoLogDirectly = value;
    notifyListeners();
  }

  void dismissAlertPayment() {
    _activeAlertPayment = null;
    notifyListeners();
  }

  Future<DetectedPayment?> processIncomingNotification(String message, String sender) async {
    if (!_autoDetectionActive) return null;
    try {
      final detected = await ApiService.detectPaymentNotification(message, sender);
      if (detected.amount > 0 && detected.isDebit) {
        _detectedPayments.insert(0, detected);

        if (_autoLogDirectly) {
          await confirmDetectedPayment(detected);
        } else {
          _activeAlertPayment = detected;
          notifyListeners();
        }
        return detected;
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> confirmDetectedPayment(DetectedPayment payment) async {
    final expense = Expense(
      amount: payment.amount,
      category: payment.category,
      date: payment.dateTime,
      notes: '${payment.paymentApp}: ${payment.merchant} (${payment.transactionId})',
      paymentMethod: PaymentMethod.UPI,
    );

    await addExpense(expense);
    payment.isLogged = true;
    if (_activeAlertPayment?.id == payment.id) {
      _activeAlertPayment = null;
    }
    notifyListeners();
  }

  Future<void> simulatePresetNotification(String appPreset) async {
    String msg = '';
    String sender = 'UPI';

    switch (appPreset.toLowerCase()) {
      case 'gpay':
      case 'google pay':
        sender = 'Google Pay';
        msg = 'Paid ₹385.00 to Swiggy on Google Pay. UPI Ref: 429108492019';
        break;
      case 'phonepe':
        sender = 'PhonePe';
        msg = 'Transaction Successful! ₹520 sent to Uber India via PhonePe. Txn ID: T26081920';
        break;
      case 'paytm':
        sender = 'Paytm';
        msg = 'Paid Rs.1,450.00 to D-Mart Supermarket via Paytm UPI. UTR: 910293810293';
        break;
      case 'bank':
      case 'hdfc':
        sender = 'HDFC Bank';
        msg = 'HDFC Bank: A/c debited with INR 799.00 on 21-Oct-26 via UPI transfer to Airtel Broadband.';
        break;
      default:
        sender = 'UPI';
        msg = 'Paid ₹250.00 to Chai Point via UPI. Ref: 1029384756';
    }

    await processIncomingNotification(msg, sender);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
