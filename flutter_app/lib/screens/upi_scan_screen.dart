import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../models/payment_method.dart';
import '../models/scanned_upi.dart';
import '../providers/expense_provider.dart';

class UpiScanScreen extends StatefulWidget {
  const UpiScanScreen({Key? key}) : super(key: key);

  @override
  State<UpiScanScreen> createState() => _UpiScanScreenState();
}

class _UpiScanScreenState extends State<UpiScanScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  ScannedUPI? _scannedResult;
  bool _isScanning = false;
  String _scanStatusText = 'Parsing UPI transaction with Gemini 2.5 Flash...';
  String? _errorMessage;

  Uint8List? _selectedImageBytes;
  String? _selectedSampleName;

  // Editable fields
  late TextEditingController _receiverController;
  late TextEditingController _amountController;
  late TextEditingController _txnIdController;
  late TextEditingController _notesController;
  Category _selectedCategory = Category.Food;
  DateTime _selectedDate = DateTime.now();

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _receiverController = TextEditingController();
    _amountController = TextEditingController();
    _txnIdController = TextEditingController();
    _notesController = TextEditingController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _receiverController.dispose();
    _amountController.dispose();
    _txnIdController.dispose();
    _notesController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _populateForm(ScannedUPI result) {
    _receiverController.text = result.receiverName;
    _amountController.text = result.paidAmount.toStringAsFixed(2);
    _txnIdController.text = result.transactionId;
    _notesController.text = 'Paid to ${result.receiverName} via UPI';
    _selectedCategory = result.autoCategorized;
    _selectedDate = result.dateTime;
  }

  Future<void> _pickAndScanImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _selectedImageBytes = bytes;
        _selectedSampleName = null;
        _isScanning = true;
        _scannedResult = null;
        _errorMessage = null;
        _scanStatusText = 'Reading UPI screenshot...';
      });

      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() => _scanStatusText = 'Gemini 2.5 Flash inspecting transaction ID & amount...');

      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final result = await provider.scanUpi(base64String);

      if (!mounted) return;
      if (result != null) {
        setState(() {
          _isScanning = false;
          _scannedResult = result;
          _populateForm(result);
        });
      } else {
        setState(() {
          _isScanning = false;
          _errorMessage = provider.errorMessage ?? 'Could not parse UPI screenshot. Please try another image.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _errorMessage = 'Scan error: $e';
      });
    }
  }

  Future<void> _loadSampleUpi(String appName, String receiver, double amount, String txnId, Category category) async {
    setState(() {
      _selectedImageBytes = null;
      _selectedSampleName = appName;
      _isScanning = true;
      _scannedResult = null;
      _errorMessage = null;
      _scanStatusText = 'Loading $appName transaction screenshot...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _scanStatusText = 'Extracting UPI reference and merchant...');
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    final sampleResult = ScannedUPI(
      paidAmount: amount,
      receiverName: receiver,
      dateTime: DateTime.now(),
      transactionId: txnId,
      autoCategorized: category,
      originalImageBase64: '',
    );

    setState(() {
      _isScanning = false;
      _scannedResult = sampleResult;
      _populateForm(sampleResult);
    });
  }

  Future<void> _saveUpiExpense() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid payment amount.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final receiver = _receiverController.text.trim().isEmpty
        ? 'UPI Merchant'
        : _receiverController.text.trim();

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await provider.addExpense(Expense(
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty ? 'UPI to $receiver' : _notesController.text.trim(),
      paymentMethod: PaymentMethod.UPI,
    ));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF00BA88),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('UPI expense of ₹${amount.toStringAsFixed(2)} saved!')),
          ],
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'UPI Screenshot Scanner',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1D192B)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00BA88).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_outlined, color: Color(0xFF00BA88), size: 12),
                  SizedBox(width: 4),
                  Text('UPI 2.0', style: TextStyle(color: Color(0xFF00BA88), fontSize: 10.5, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D192B)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // BANNER WITH SUPPORTED APPS
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C1958), Color(0xFF4C308E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4C308E).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Auto-Parse UPI Screenshots',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'GPay • PhonePe • Paytm • CRED • BHIM',
                                    style: TextStyle(color: Color(0xFFD6C8F5), fontSize: 11.5, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // MAIN UPLOAD BUTTON
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E43A5),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.phone_android, size: 22),
                    label: const Text(
                      'Select UPI Screenshot',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onPressed: _isScanning ? null : _pickAndScanImage,
                  ),

                  const SizedBox(height: 14),

                  // 1-CLICK INSTANT SAMPLES BAR
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEFEBF6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.touch_app_outlined, color: Color(0xFF5E43A5), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Try Demo Screenshots (1-Click Test):',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5E43A5)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _sampleChip(
                              label: '🟢 GPay: Swiggy ₹385',
                              onTap: () => _loadSampleUpi(
                                'Google Pay',
                                'Swiggy Delivery UPI',
                                385.0,
                                'UPI/382910482910',
                                Category.Food,
                              ),
                            ),
                            _sampleChip(
                              label: '🟣 PhonePe: Uber ₹520',
                              onTap: () => _loadSampleUpi(
                                'PhonePe',
                                'Uber India Rides',
                                520.0,
                                'UPI/492019482019',
                                Category.Travel,
                              ),
                            ),
                            _sampleChip(
                              label: '🔵 Paytm: Airtel ₹899',
                              onTap: () => _loadSampleUpi(
                                'Paytm',
                                'Airtel Broadband Ltd',
                                899.0,
                                'UPI/582910482918',
                                Category.Bills,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SCANNING ANIMATION STATE
                  if (_isScanning)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE4D9FA), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5E43A5).withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF00BA88).withValues(
                                    alpha: 0.1 + (_pulseController.value * 0.15),
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF00BA88).withValues(
                                      alpha: 0.4 + (_pulseController.value * 0.6),
                                    ),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(Icons.qr_code, color: Color(0xFF00BA88), size: 36),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _scanStatusText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1D192B), fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Extracting receiver name, amount paid, and UTR reference',
                            style: TextStyle(color: Color(0xFF79747E), fontSize: 11),
                          ),
                        ],
                      ),
                    )

                  // ERROR BANNER
                  else if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12.5, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => setState(() => _errorMessage = null),
                                child: const Text('Dismiss', style: TextStyle(color: Color(0xFF79747E))),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: _pickAndScanImage,
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )

                  // PARSED RESULT (EDITABLE CARD)
                  else if (_scannedResult != null)
                    _buildExtractedUpiCard()

                  // DEFAULT EMPTY PLACEHOLDER
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFEBF6), width: 1.2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3EEFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phonelink_setup, size: 32, color: Color(0xFF5E43A5)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Seamless UPI Parsing',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1D192B)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Select a payment confirmation screenshot from GPay, PhonePe, or Paytm.\nOr click one of the 1-click test buttons above!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF79747E), fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sampleChip({required String label, required VoidCallback onTap}) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D192B))),
      backgroundColor: const Color(0xFFF3EEFF),
      side: const BorderSide(color: Color(0xFFE4D9FA)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: _isScanning ? null : onTap,
    );
  }

  Widget _buildExtractedUpiCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4D9FA), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E43A5).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SUCCESS BADGE HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F6FD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BA88).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle, color: Color(0xFF00BA88), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'UPI Transaction Identified',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1D192B)),
                      ),
                      Text(
                        'Review details before adding to ledger',
                        style: TextStyle(color: Color(0xFF79747E), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.refresh, size: 16, color: Color(0xFF5E43A5)),
                  label: const Text('Rescan', style: TextStyle(color: Color(0xFF5E43A5), fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => setState(() => _scannedResult = null),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEFEBF6)),

          // FORM FIELDS
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Receiver Name
                const Text('RECEIVER / MERCHANT', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF79747E), letterSpacing: 0.6)),
                const SizedBox(height: 6),
                TextField(
                  controller: _receiverController,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1D192B)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_pin_outlined, color: Color(0xFF5E43A5), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFFAF9FD),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5E43A5), width: 1.5)),
                  ),
                ),

                const SizedBox(height: 16),

                // Amount
                const Text('AMOUNT PAID (₹)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF79747E), letterSpacing: 0.6)),
                const SizedBox(height: 6),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF1D192B)),
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('₹', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF00BA88))),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAF9FD),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00BA88), width: 1.5)),
                  ),
                ),

                const SizedBox(height: 16),

                // Transaction Reference ID
                const Text('UPI TRANSACTION REF (UTR)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF79747E), letterSpacing: 0.6)),
                const SizedBox(height: 6),
                TextField(
                  controller: _txnIdController,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1D192B)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.tag, color: Color(0xFF5E43A5), size: 18),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.copy, size: 16, color: Color(0xFF5E43A5)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _txnIdController.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction ID copied!'), duration: Duration(seconds: 1)),
                        );
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAF9FD),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5E43A5), width: 1.5)),
                  ),
                ),

                const SizedBox(height: 16),

                // Category Chips
                const Text('CATEGORY', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF79747E), letterSpacing: 0.6)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: Category.values
                      .where((c) => c != Category.Uncategorized)
                      .map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.name),
                      selected: isSelected,
                      selectedColor: const Color(0xFF5E43A5),
                      backgroundColor: const Color(0xFFFAF9FD),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF1D192B),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 11.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: isSelected ? const Color(0xFF5E43A5) : const Color(0xFFEFEBF6)),
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Date Picker row
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEFEBF6)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF5E43A5)),
                            const SizedBox(width: 10),
                            Text(
                              'Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1D192B)),
                            ),
                          ],
                        ),
                        const Icon(Icons.edit, size: 16, color: Color(0xFF79747E)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BA88),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check, size: 22),
                    label: const Text(
                      'Save UPI Expense',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onPressed: _saveUpiExpense,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
