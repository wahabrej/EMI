import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constant/App_Colors.dart';
import '../ViewModel/PaymentViewModel.dart';

class CollectPaymentScreen extends StatefulWidget {
  const CollectPaymentScreen({super.key});

  @override
  State<CollectPaymentScreen> createState() => _CollectPaymentScreenState();
}

class _CollectPaymentScreenState extends State<CollectPaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Loan Data
  late String loanId;
  String? installmentId;
  late String customerName;
  late String customerPhone;
  late String customerId;
  late String loanAmount;
  late String monthlyEmi;
  late int tenure;
  List<dynamic>? installments;
  Map<String, dynamic>? nextInstallment;
  double dueAmount = 0;

  // Payment Fields
  String _paymentMethod = 'BANK';
  final _amountController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _senderMobileController = TextEditingController();
  final _referenceController = TextEditingController();
  final _remarksController = TextEditingController();

  File? _receiptFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      loanId = args['loanId'] ?? '';
      installmentId = args['installmentId'];
      customerName = args['customerName'] ?? 'N/A';
      customerPhone = args['customerPhone'] ?? 'N/A';
      customerId = args['customerId'] ?? '';
      loanAmount = args['loanAmount'] ?? '0';
      monthlyEmi = args['monthlyEmi'] ?? '0';
      tenure = args['tenure'] ?? 12;
      installments = args['installments'];
      nextInstallment = args['nextInstallment'];
      dueAmount = args['dueAmount'] ?? 0;

      // Set default amount
      _amountController.text = dueAmount > 0 ? dueAmount.toString() : monthlyEmi;
    }
  }

  Future<void> _pickReceipt() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _receiptFile = File(image.path);
      });
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_receiptFile == null && _paymentMethod == 'BANK') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload receipt'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final viewModel = context.read<PaymentViewModel>();

    bool success = await viewModel.submitPayment(
      loanId: loanId,
      installmentId: installmentId,
      amount: _amountController.text,
      paymentMethod: _paymentMethod,
      bankAccountName: _bankAccountNameController.text,
      bankAccountNumber: _bankAccountNumberController.text,
      bankName: _bankNameController.text,
      senderMobileNumber: _senderMobileController.text,
      referenceNumber: _referenceController.text,
      remarks: _remarksController.text,
      receipt: _receiptFile,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.successMessage ?? 'Payment submitted successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Payment failed'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankAccountNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankNameController.dispose();
    _senderMobileController.dispose();
    _referenceController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collect Payment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Consumer<PaymentViewModel>(
        builder: (context, viewModel, child) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Loan Info ───
                      _buildLoanInfoCard(),
                      const SizedBox(height: 16),

                      // ─── Next Installment ───
                      if (nextInstallment != null)
                        _buildNextInstallmentCard(),
                      const SizedBox(height: 16),

                      // ─── Amount ───
                      _buildAmountField(),
                      const SizedBox(height: 16),

                      // ─── Payment Method ───
                      _buildPaymentMethodSelector(),
                      const SizedBox(height: 16),

                      // ─── Payment Fields ───
                      _buildPaymentFields(),
                      const SizedBox(height: 16),

                      // ─── Remarks ───
                      _buildRemarksField(),
                      const SizedBox(height: 16),

                      // ─── Receipt ───
                      _buildReceiptField(),
                      const SizedBox(height: 24),

                      // ─── Submit Button ───
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: viewModel.isLoading ? null : _submitPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            'Submit Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              if (viewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoanInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                child: Text(
                  customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(customerPhone, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Loan Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('৳${NumberFormat('#,###').format(double.tryParse(loanAmount) ?? 0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('Monthly EMI', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('৳${NumberFormat('#,###').format(double.tryParse(monthlyEmi) ?? 0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('Tenure', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('$tenure Months',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextInstallmentCard() {
    final currency = NumberFormat('#,###');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payments_outlined, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Next Installment',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Installment #', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(nextInstallment?['installmentNumber']?.toString() ?? 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Due Date', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(nextInstallment?['dueDate'] != null
                        ? DateFormat('dd MMM yyyy').format(DateTime.parse(nextInstallment!['dueDate']!))
                        : 'N/A',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Due Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('৳${currency.format(dueAmount)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Payment Amount',
        hintText: 'Enter amount to pay',
        prefixIcon: Icon(Icons.currency_exchange_rounded),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter amount';
        if (double.tryParse(value) == null) return 'Invalid amount';
        if (double.parse(value) <= 0) return 'Amount must be greater than 0';
        return null;
      },
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _methodOption('BANK', Icons.account_balance_outlined),
          ),
          Expanded(
            child: _methodOption('BKASH', Icons.phone_android_rounded),
          ),
        ],
      ),
    );
  }

  Widget _methodOption(String method, IconData icon) {
    final isSelected = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF0052CC) : Colors.grey),
            const SizedBox(width: 8),
            Text(
              method,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF0052CC) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentFields() {
    if (_paymentMethod == 'BANK') {
      return Column(
        children: [
          TextFormField(
            controller: _bankAccountNameController,
            decoration: const InputDecoration(
              labelText: 'Bank Account Name',
              hintText: 'Your bank account name',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Please enter account name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bankAccountNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Bank Account Number',
              hintText: 'Your bank account number',
              prefixIcon: Icon(Icons.numbers_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Please enter account number' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bankNameController,
            decoration: const InputDecoration(
              labelText: 'Bank Name',
              hintText: 'Name of your bank',
              prefixIcon: Icon(Icons.account_balance_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Please enter bank name' : null,
          ),
        ],
      );
    } else {
      // BKASH
      return Column(
        children: [
          TextFormField(
            controller: _senderMobileController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'bKash Account Number',
              hintText: '017xxxxxxxx',
              prefixIcon: Icon(Icons.phone_android_rounded),
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Please enter bKash number' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(
              labelText: 'Transaction ID (TrxID)',
              hintText: 'Enter bKash transaction ID',
              prefixIcon: Icon(Icons.receipt_long_rounded),
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Please enter transaction ID' : null,
          ),
        ],
      );
    }
  }

  Widget _buildRemarksField() {
    return TextFormField(
      controller: _remarksController,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Remarks (Optional)',
        hintText: 'Any additional notes',
        prefixIcon: Icon(Icons.note_outlined),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildReceiptField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.attach_file, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _receiptFile != null
                      ? _receiptFile!.path.split('/').last
                      : 'Upload Receipt${_paymentMethod == 'BANK' ? ' (Required)' : ' (Optional)'}',
                  style: TextStyle(
                    color: _receiptFile != null ? Colors.green : Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: _pickReceipt,
                child: const Text('Choose File'),
              ),
            ],
          ),
        ),
        if (_receiptFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '✅ Receipt selected: ${(_receiptFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          ),
      ],
    );
  }
}