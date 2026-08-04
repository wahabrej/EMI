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

  // Bank Form Controllers
  final _accNameController = TextEditingController();
  final _accNoController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _refController = TextEditingController();
  final _remarksController = TextEditingController();
  File? _receiptFile;

  @override
  void dispose() {
    _accNameController.dispose();
    _accNoController.dispose();
    _bankNameController.dispose();
    _refController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  // ── Business Logic: Compute Due Amount with Cashback Eligibility ─────
  double get totalPayableAmount {
    double total = 0;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day); // Normalize to midnight

    for (var item in widget.selectedItems) {
      // Logic: totalDue - eligibleCashback[cite: 1]
      double itemTotalDue = double.tryParse(item.totalDue ?? '0') ?? 0;
      double cashbackAmount = double.tryParse(item.cashbackAmount ?? '0') ?? 0;

      DateTime? dueDate;
      if (item.dueDate != null) {
        dueDate = DateTime.parse(item.dueDate!);
        dueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
      }

      double eligibleCashback = 0;
      // If cashbackStatus === "PENDING" and today <= dueDate[cite: 1]
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
        title: const Text(
          'Proceed to Pay',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18),
        ),
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
                  _buildSelectedInstallments(),
                  const SizedBox(height: 16),
                  _buildBankForm(), // Direct Bank Form Entry
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

  // ══════════════════ BANK FORM UI ══════════════════
  Widget _buildBankForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.account_balance_outlined, color: AppColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text('Bank Transfer Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          _buildField(_accNameController, 'Bank Account Name *', 'Enter your account name'),
          const SizedBox(height: 12),
          _buildField(_accNoController, 'Bank Account Number *', 'Enter account number'),
          const SizedBox(height: 12),
          _buildField(_bankNameController, 'Bank Name *', 'e.g. Dutch Bangla Bank'),
          const SizedBox(height: 12),
          _buildField(_refController, 'Reference Number', 'Transaction ID or Ref (Optional)', isReq: false),
          const SizedBox(height: 12),
          _buildField(_remarksController, 'Remarks', 'Add any notes (Optional)', isReq: false),
          const SizedBox(height: 20),
          const Text('Bank Deposit Receipt *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
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
                  Text('Upload Receipt Photo (Max 5MB)', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
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

  Widget _buildSelectedInstallments() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selected Installments', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 12),
          ...widget.selectedItems.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Installment #${item.installmentNumber}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(_formatDate(item.dueDate), style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                Text('৳${item.totalDue}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(CustomerPaymentHistoryViewModel historyVM) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _handleBankPaymentSubmission(historyVM),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          'Submit Bank Payment ৳${NumberFormat('#,##,###').format(totalPayableAmount)}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  // ══════════════════ BANK PAYMENT SUBMISSION HANDLER ══════════════════
  Future<void> _handleBankPaymentSubmission(CustomerPaymentHistoryViewModel historyVM) async {
    if (widget.selectedItems.isEmpty) return;
    final loanId = widget.selectedItems.first.loanId;
    if (loanId == null) return;

    if (_receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bank deposit receipt is required'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final success = await historyVM.submitBankPayment(
        loanId: loanId, //[cite: 1]
        installmentId: widget.selectedItems.length == 1 ? widget.selectedItems.first.id : null, //[cite: 1]
        amount: totalPayableAmount, //[cite: 1]
        bankAccountName: _accNameController.text.trim(), //[cite: 1]
        bankAccountNumber: _accNoController.text.trim(), //[cite: 1]
        bankName: _bankNameController.text.trim(), //[cite: 1]
        referenceNumber: _refController.text.trim(), //[cite: 1]
        remarks: _remarksController.text.trim(), //[cite: 1]
        receiptFile: _receiptFile!, //[cite: 1]
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank payment submitted for verification'), backgroundColor: Colors.green),
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
      child: Row(children: [
        const Icon(Icons.verified_user, color: Color(0xFF2563EB), size: 22),
        const SizedBox(width: 12),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
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

  String _formatDate(String? d) {
    if (d == null) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(d));
    } catch (_) {
      return d;
    }
  }
}