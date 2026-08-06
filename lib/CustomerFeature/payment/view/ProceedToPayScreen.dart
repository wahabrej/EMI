import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constant/App_Colors.dart';
import '../../home/model/customer_dashboard_model.dart';
import '../../home/viewModel/home_view_model.dart';
import '../viewModel/customer_payment_history_view_model.dart';

class ProceedToPayScreen extends StatefulWidget {
  final List<Installments> selectedItems;
  final String loanAccount;
  final String customerName;
  final String? customerDisplayId;

  const ProceedToPayScreen({
    super.key,
    required this.selectedItems,
    required this.loanAccount,
    required this.customerName,
    this.customerDisplayId,
  });

  @override
  State<ProceedToPayScreen> createState() => _ProceedToPayScreenState();
}

class _ProceedToPayScreenState extends State<ProceedToPayScreen> {
  final _formKey = GlobalKey<FormState>();

  // Payment Method Selection
  String _selectedPaymentMethod = 'BANK'; // 'BANK' or 'BKASH'

  // Bank Form Controllers
  final _accNameController = TextEditingController();
  final _accNoController = TextEditingController();
  final _bankNameController = TextEditingController();

  // bKash Form Controller
  final _bKashMobileController = TextEditingController();

  // Common Controllers
  final _refController = TextEditingController();
  final _remarksController = TextEditingController();
  File? _receiptFile;

  @override
  void dispose() {
    _accNameController.dispose();
    _accNoController.dispose();
    _bankNameController.dispose();
    _bKashMobileController.dispose();
    _refController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  double get totalPayableAmount {
    double total = 0;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    for (var item in widget.selectedItems) {
      double itemTotalDue = double.tryParse(item.totalDue ?? '0') ?? 0;
      double cashbackAmount = double.tryParse(item.cashbackAmount ?? '0') ?? 0;

      DateTime? dueDate;
      if (item.dueDate != null) {
        dueDate = DateTime.parse(item.dueDate!);
        dueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
      }

      double eligibleCashback = 0;
      if (item.cashbackStatus?.toUpperCase() == "PENDING" &&
          dueDate != null &&
          !today.isAfter(dueDate)) {
        eligibleCashback = cashbackAmount;
      }

      total += (itemTotalDue - eligibleCashback);
    }
    return total > 0 ? total : 0;
  }

  Future<void> _pickReceipt() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      setState(() => _receiptFile = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeVM = context.watch<CustomerHomeViewModel>();
    final historyVM = context.watch<CustomerPaymentHistoryViewModel>();
    bool isLoading = homeVM.isPaymentLoading || historyVM.isSubmitting;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)),
        ),
        title: const Text('Proceed to Pay', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildPaymentMethodSelector(),
                  const SizedBox(height: 16),
                  _selectedPaymentMethod == 'BANK' ? _buildBankForm() : _buildBkashForm(),
                  const SizedBox(height: 20),
                  _buildSecurityBanner(),
                  const SizedBox(height: 28),
                  _buildSubmitButton(historyVM),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
            ),
        ],
      ),
    );
  }

  // ══════════════════ PAYMENT METHOD SELECTOR ══════════════════
  Widget _buildPaymentMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _methodTab('Bank Transfer', 'BANK')),
          Expanded(child: _methodTab('bKash', 'BKASH')),
        ],
      ),
    );
  }

  Widget _methodTab(String title, String method) {
    bool isSelected = _selectedPaymentMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primaryBlue : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════ BANK FORM UI ══════════════════
  Widget _buildBankForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bank Transfer Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 16),
          _buildField(_accNameController, 'Your Bank Account Name *', 'Enter account name'),
          const SizedBox(height: 12),
          _buildField(_accNoController, 'Your Bank Account Number *', 'Enter account number'),
          const SizedBox(height: 12),
          _buildField(_bankNameController, 'Bank Name *', 'e.g. Dutch Bangla Bank'),
          const SizedBox(height: 12),
          _buildField(_refController, 'Transaction ID / Reference No.', 'Optional for Bank', isReq: false),
          const SizedBox(height: 12),
          _buildField(_remarksController, 'Remarks', 'Add any notes (Optional)', isReq: false),
          const SizedBox(height: 20),
          _buildReceiptUploader(isRequired: true),
        ],
      ),
    );
  }

  // ══════════════════ BKASH FORM UI ══════════════════
  Widget _buildBkashForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('bKash Payment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFD12053))),
          const SizedBox(height: 16),
          _buildField(_bKashMobileController, 'bKash Account Number *', 'e.g. 01712345678'),
          const SizedBox(height: 12),
          _buildField(_refController, 'Transaction ID (TrxID) *', 'e.g. TRX8A1B2C3D4'),
          const SizedBox(height: 12),
          _buildField(_remarksController, 'Remarks', 'Add any notes (Optional)', isReq: false),
          const SizedBox(height: 20),
          _buildReceiptUploader(isRequired: false), // Optional for bKash
        ],
      ),
    );
  }

  Widget _buildReceiptUploader({required bool isRequired}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Receipt / Screenshot ${isRequired ? '*' : '(Optional)'}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickReceipt,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _receiptFile != null ? AppColors.primaryBlue : const Color(0xFFCBD5E1), width: 1.5),
            ),
            child: _receiptFile != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_receiptFile!, fit: BoxFit.cover),
            )
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: AppColors.primaryBlue, size: 30),
                SizedBox(height: 8),
                Text('Upload Screenshot/Receipt (Max 5MB)', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, String hint, {bool isReq = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 14),
          validator: (v) => (isReq && (v == null || v.trim().isEmpty)) ? 'This field is required' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          _row('Customer ID', widget.customerDisplayId ?? 'N/A'),
          _row('Order ID', widget.loanAccount),
          _row('Total Selected', '${widget.selectedItems.length} Installment(s)'),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Payable Amount', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              Text(
                '৳${NumberFormat('#,##,###').format(totalPayableAmount)}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(CustomerPaymentHistoryViewModel historyVM) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _handlePaymentSubmission(historyVM),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          'Submit Payment ৳${NumberFormat('#,##,###').format(totalPayableAmount)}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  // ══════════════════ SUBMISSION HANDLER ══════════════════
  Future<void> _handlePaymentSubmission(CustomerPaymentHistoryViewModel historyVM) async {
    if (widget.selectedItems.isEmpty) return;
    final loanId = widget.selectedItems.first.loanId;
    if (loanId == null) return;

    // Validate Receipt File for BANK method
    if (_selectedPaymentMethod == 'BANK' && _receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank deposit receipt photo is required'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final success = await historyVM.submitPayment(
        loanId: loanId,
        installmentId: widget.selectedItems.length == 1 ? widget.selectedItems.first.id : null,
        amount: totalPayableAmount,
        paymentMethod: _selectedPaymentMethod,

        // Conditional inputs
        bankAccountName: _selectedPaymentMethod == 'BANK' ? _accNameController.text.trim() : null,
        bankAccountNumber: _selectedPaymentMethod == 'BANK' ? _accNoController.text.trim() : null,
        bankName: _selectedPaymentMethod == 'BANK' ? _bankNameController.text.trim() : null,
        senderMobileNumber: _selectedPaymentMethod == 'BKASH' ? _bKashMobileController.text.trim() : null,

        referenceNumber: _refController.text.trim(),
        remarks: _remarksController.text.trim(),
        receiptFile: _receiptFile,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment submitted successfully for verification'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(historyVM.errorMessage ?? 'Submission failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildSecurityBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
      child: const Row(children: [
        Icon(Icons.verified_user, color: Color(0xFF2563EB), size: 22),
        SizedBox(width: 12),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('100% Secure Payment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text('Your payment information is submitted safely for admin verification.', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            ])),
      ]),
    );
  }

  Widget _row(String l, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
      Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    ]),
  );
}