import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/multy_form/viewModel/multyform_provider.dart';

class PaymentStep extends StatefulWidget {
  final VoidCallback onNext;

  const PaymentStep({super.key, required this.onNext});

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickBankReceipt(CheckoutViewModel vm) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image != null) {
      vm.setBankReceipt(File(image.path));
    }
  }

  void _handleNext(CheckoutViewModel vm) {
    if (vm.checkoutData.downPaymentMethod == 'BANK' && vm.checkoutData.bankReceipt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload bank receipt'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CheckoutViewModel>(context);
    final data = vm.checkoutData;

    // Calculative values based on Order Review Step
    double totalPayable = data.saleType == 'EMI'
        ? (data.downPayment + (data.monthlyEmi * data.emiTenureMonths))
        : data.mrp;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            const Text(
              'Make Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 2),
            Text(
              data.saleType == 'EMI'
                  ? 'Review initial down payment and payment method'
                  : 'Review the selling price and choose how the full payment will be collected',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // Product Card Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.productModel ?? 'OPPO > A6s PRO (8/256)',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.saleType == 'EMI' ? 'EMI Sale' : 'Selling Price Sale',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        data.saleType == 'EMI' ? 'Down Payment' : 'Collect Full Price',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                      Text(
                        '৳ ${data.saleType == 'EMI' ? data.downPayment.toStringAsFixed(0) : data.mrp.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data.saleType == 'EMI' ? '${data.emiTenureMonths} Months EMI' : 'No EMI',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payment Summary Block
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),

                  // 4 Summary Metric Boxes
                  Row(
                    children: [
                      Expanded(child: _buildSummaryBox('Product Selling Price', '৳ ${data.mrp.toStringAsFixed(0)}')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildSummaryBox(data.saleType == 'EMI' ? 'Down Payment' : 'Full Payment', '৳ ${(data.saleType == 'EMI' ? data.downPayment : data.mrp).toStringAsFixed(0)}')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildSummaryBox('EMI Charge', '৳ ${data.emiCharge.toStringAsFixed(0)}')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildSummaryBox('Total Payable', '৳ ${totalPayable.toStringAsFixed(0)}')),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFF1F5F9)),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sale Type', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      Text(data.saleType == 'EMI' ? 'EMI Sale' : 'Selling Price', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount to Collect', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      Text(
                        '৳ ${(data.saleType == 'EMI' ? data.downPayment : data.mrp).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Collection Method Selection Block
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Full Payment Collection Method',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),

                  // Option 1: Cash
                  _buildPaymentOption(
                    vm: vm,
                    type: 'CASH',
                    title: 'Cash',
                    subtitle: 'Receive at shop counter',
                    badgeText: 'Recommended',
                    iconColor: Colors.red,
                    avatarText: 'C',
                  ),
                  const SizedBox(height: 10),

                  // Option 2: bKash
                  _buildPaymentOption(
                    vm: vm,
                    type: 'BKASH',
                    title: 'bKash',
                    subtitle: 'Merchant Account Payment',
                    avatarText: 'b',
                    iconColor: const Color(0xFFD11559),
                  ),
                  const SizedBox(height: 10),

                  // Option 3: Bank Transfer
                  _buildPaymentOption(
                    vm: vm,
                    type: 'BANK',
                    title: 'Bank',
                    subtitle: 'Upload bank receipt',
                    avatarText: 'B',
                    iconColor: Colors.deepOrange,
                  ),

                  // Extra Fields for Bank Selection
                  if (data.downPaymentMethod == 'BANK') ...[
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 8),

                    // Bank Reference / Account Input
                    TextFormField(
                      initialValue: data.downPaymentReferenceNumber,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Transaction Reference No.',
                        hintText: 'Enter bank transaction/receipt ref no',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: (val) => data.downPaymentReferenceNumber = val.trim(),
                    ),
                    const SizedBox(height: 12),

                    // Bank Receipt Upload
                    InkWell(
                      onTap: () => _pickBankReceipt(vm),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.upload_file, color: Color(0xFF2563EB)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                data.bankReceipt != null ? 'Receipt Uploaded: ${data.bankReceipt!.path.split('/').last}' : 'Upload Bank Deposit Receipt Image',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: data.bankReceipt != null ? Colors.green : const Color(0xFF475569),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (data.bankReceipt != null)
                              const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Next Step Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _handleNext(vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Next Step', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required CheckoutViewModel vm,
    required String type,
    required String title,
    required String subtitle,
    required String avatarText,
    required Color iconColor,
    String? badgeText,
  }) {
    bool isSelected = vm.checkoutData.downPaymentMethod == type;

    return InkWell(
      onTap: () => vm.setPaymentMethod(type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: type,
              groupValue: vm.checkoutData.downPaymentMethod,
              onChanged: (val) {
                if (val != null) vm.setPaymentMethod(val);
              },
              activeColor: const Color(0xFF2563EB),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  avatarText,
                  style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}