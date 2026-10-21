import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../models/payment_method.dart';
import '../models/scanned_receipt.dart';
import '../providers/expense_provider.dart';

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  ScannedReceipt? _scannedResult;
  bool _isScanning = false;
  String _scanStatusText = 'Initializing Gemini 2.5 Vision OCR...';
  String? _errorMessage;

  Uint8List? _selectedImageBytes;
  String? _selectedSampleName;

  // Controllers for editable fields
  late TextEditingController _merchantController;
  late TextEditingController _amountController;
  late TextEditingController _taxController;
  late TextEditingController _notesController;
  Category _selectedCategory = Category.Food;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.Card;
  DateTime _selectedDate = DateTime.now();

  late AnimationController _scannerAnimController;

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController();
    _amountController = TextEditingController();
    _taxController = TextEditingController();
    _notesController = TextEditingController();

    _scannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    _scannerAnimController.dispose();
    super.dispose();
  }

  void _populateForm(ScannedReceipt result) {
    _merchantController.text = result.merchantName;
    _amountController.text = result.totalAmount.toStringAsFixed(2);
    _taxController.text = (result.taxAmount ?? 0.0).toStringAsFixed(2);
    _notesController.text = 'Scanned via Gemini AI: ${result.merchantName}';
    _selectedCategory = result.autoCategorized;
    _selectedDate = result.date;
    _selectedPaymentMethod = PaymentMethod.Card;
  }

  Future<void> _pickAndScanImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
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
        _scanStatusText = 'Uploading receipt image...';
      });

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() => _scanStatusText = 'Gemini 2.5 Flash analyzing text & items...');

      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final result = await provider.scanReceipt(base64String);

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
          _errorMessage = provider.errorMessage ?? 'Unable to parse receipt. Please verify image or try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _errorMessage = 'Scanning error: $e';
      });
    }
  }

  // Quick 1-click preset sample test
  Future<void> _loadSampleReceipt(String name, String merchant, double amount, double tax, Category category) async {
    setState(() {
      _selectedImageBytes = null;
      _selectedSampleName = name;
      _isScanning = true;
      _scannedResult = null;
      _errorMessage = null;
      _scanStatusText = 'Loading $name sample receipt...';
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _scanStatusText = 'Extracting totals & categories with Gemini AI...');
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    final sampleResult = ScannedReceipt(
      merchantName: merchant,
      date: DateTime.now(),
      totalAmount: amount,
      taxAmount: tax,
      autoCategorized: category,
      originalImageBase64: '',
    );

    setState(() {
      _isScanning = false;
      _scannedResult = sampleResult;
      _populateForm(sampleResult);
    });
  }

  Future<void> _saveScannedExpense() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid expense amount.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final merchant = _merchantController.text.trim().isEmpty
        ? 'Scanned Receipt'
        : _merchantController.text.trim();

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await provider.addExpense(Expense(
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty ? merchant : _notesController.text.trim(),
      paymentMethod: _selectedPaymentMethod,
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
            Expanded(child: Text('Receipt expense of ₹${amount.toStringAsFixed(2)} logged!')),
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
              'Gemini Receipt OCR',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF1D192B)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF5E43A5), Color(0xFF8B64DC)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 11),
                  SizedBox(width: 4),
                  Text('2.5 Flash', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                  // INSPIRATIONAL HEADER CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5E43A5), Color(0xFF7B5ACD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5E43A5).withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_long, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instant Receipt Scanning',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Capture paper bills or upload digital invoices to auto-parse amounts, tax, and categories.',
                                style: TextStyle(color: Color(0xFFE4D9FA), fontSize: 12, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ACTION BUTTONS (Camera & Upload)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5E43A5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.camera_alt_outlined, size: 20),
                          label: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          onPressed: _isScanning ? null : () => _pickAndScanImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF5E43A5), width: 1.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF5E43A5),
                          ),
                          icon: const Icon(Icons.photo_library_outlined, size: 20),
                          label: const Text('Upload File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          onPressed: _isScanning ? null : () => _pickAndScanImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 1-CLICK DEMO SAMPLES BAR
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
                            Icon(Icons.bolt, color: Color(0xFFE89215), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Try Instant Preset Receipts (1-Click Test):',
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
                              label: '☕ Starbucks ₹450',
                              onTap: () => _loadSampleReceipt('Starbucks', 'Starbucks Coffee', 450.0, 22.5, Category.Food),
                            ),
                            _sampleChip(
                              label: '🛒 D-Mart ₹1,480',
                              onTap: () => _loadSampleReceipt('D-Mart', 'D-Mart Supermarket', 1480.0, 74.0, Category.Food),
                            ),
                            _sampleChip(
                              label: '⛽ Shell Petrol ₹2,200',
                              onTap: () => _loadSampleReceipt('Shell', 'Shell Fuel Station', 2200.0, 0.0, Category.Travel),
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
                          // Animated Scanner Graphic
                          SizedBox(
                            width: 160,
                            height: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 140,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3EEFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF5E43A5), width: 1.5),
                                  ),
                                  child: const Icon(Icons.receipt, size: 48, color: Color(0xFF5E43A5)),
                                ),
                                AnimatedBuilder(
                                  animation: _scannerAnimController,
                                  builder: (context, child) {
                                    return Positioned(
                                      top: 15 + (_scannerAnimController.value * 70),
                                      left: 10,
                                      right: 10,
                                      child: Container(
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00BA88),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF00BA88).withValues(alpha: 0.8),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _scanStatusText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5E43A5), fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Extracting store name, totals, GST tax, and transaction dates',
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
                                onPressed: () {
                                  setState(() => _errorMessage = null);
                                },
                                child: const Text('Dismiss', style: TextStyle(color: Color(0xFF79747E))),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _pickAndScanImage(ImageSource.gallery),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )

                  // EXTRACTED RESULT (EDITABLE DIGITAL TICKET)
                  else if (_scannedResult != null)
                    _buildExtractedResultCard()

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
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3EEFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.document_scanner_outlined, size: 32, color: Color(0xFF5E43A5)),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Ready to Scan Your Receipts',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1D192B)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Take a picture of any physical receipt, invoice, or supermarket bill.\nOr click one of the 1-click test buttons above to see the magic!',
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
      avatar: const Icon(Icons.flash_on, size: 14, color: Color(0xFF5E43A5)),
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D192B))),
      backgroundColor: const Color(0xFFF3EEFF),
      side: const BorderSide(color: Color(0xFFE4D9FA)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: _isScanning ? null : onTap,
    );
  }

  Widget _buildExtractedResultCard() {
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
          // TICKET TOP HEADER
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
                        'Parsed by Gemini Vision AI',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1D192B)),
                      ),
                      Text(
                        'Review or adjust details before saving',
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

          // EDITABLE FIELDS FORM
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Merchant Name
                const Text('MERCHANT / STORE NAME', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF79747E), letterSpacing: 0.6)),
                const SizedBox(height: 6),
                TextField(
                  controller: _merchantController,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1D192B)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.storefront_outlined, color: Color(0xFF5E43A5), size: 20),
                    filled: true,
                    fillColor: const Color(0xFFFAF9FD),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5E43A5), width: 1.5)),
                  ),
                ),

                const SizedBox(height: 16),

                // Amount & Tax row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL AMOUNT (₹)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF79747E), letterSpacing: 0.6)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF1D192B)),
                            decoration: InputDecoration(
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('₹', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF5E43A5))),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFFAF9FD),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5E43A5), width: 1.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GST / TAX (₹)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF79747E), letterSpacing: 0.6)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _taxController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1D192B)),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFFAF9FD),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEFEBF6))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5E43A5), width: 1.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Category Selection Chips
                const Text('EXPENSE CATEGORY', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF79747E), letterSpacing: 0.6)),
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

                // Payment Method
                const Text('PAYMENT METHOD', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF79747E), letterSpacing: 0.6)),
                const SizedBox(height: 8),
                Row(
                  children: PaymentMethod.values.map((method) {
                    final isSelected = _selectedPaymentMethod == method;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedPaymentMethod = method),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF3EEFF) : const Color(0xFFFAF9FD),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isSelected ? const Color(0xFF5E43A5) : const Color(0xFFEFEBF6), width: isSelected ? 1.5 : 1),
                            ),
                            child: Center(
                              child: Text(
                                method.name,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF5E43A5) : const Color(0xFF79747E),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
                      'Save to Ledger',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onPressed: _saveScannedExpense,
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
