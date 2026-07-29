import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/multy_form/viewModel/multyform_provider.dart';

class ConfirmationStep extends StatelessWidget {
  final VoidCallback onSuccess;

  const ConfirmationStep({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CheckoutViewModel>(context);
    final data = vm.checkoutData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '6. Order Confirmation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Please review all collected details before final submission',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // 1. Order Review Summary
          _buildSummarySection(
            title: '1. Order Review',
            icon: Icons.shopping_bag_outlined,
            children: [
              _buildRow('Sale Type', data.saleType ?? 'N/A'),
              _buildRow('Product Price (MRP)', '৳ ${data.mrp.toStringAsFixed(0)}'),
              if (data.saleType == 'EMI') ...[
                _buildRow('Down Payment', '৳ ${data.downPayment.toStringAsFixed(0)}'),
                _buildRow('Monthly EMI', '৳ ${data.monthlyEmi.toStringAsFixed(0)}'),
                _buildRow('EMI Tenure', '${data.emiTenureMonths} Months'),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // 2. Customer Info Summary
          _buildSummarySection(
            title: '2. Customer Information',
            icon: Icons.person_outline,
            children: [
              _buildRow('Full Name', data.name ?? 'N/A'),
              _buildRow('Phone', data.phone ?? 'N/A'),
              _buildRow('NID / Passport', data.nidPassportNumber ?? 'N/A'),
              _buildRow('Income Source', data.incomeSource ?? 'N/A'),
              _buildRow('Monthly Income', '৳ ${data.monthlyIncome.toStringAsFixed(0)}'),
              _buildRow('Present Address', data.presentAddress ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 12),

          // 3. KYC Verification Summary
          _buildSummarySection(
            title: '3. KYC Documents',
            icon: Icons.badge_outlined,
            children: [
              _buildFileStatus('Customer Image', vm.customerImageFile != null),
              _buildFileStatus('NID Front Image', data.nidFront != null),
              _buildFileStatus('NID Back Image', data.nidBack != null),
              _buildFileStatus('Income Proof Document', data.incomeProof != null),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Guarantor Info Summary
          _buildSummarySection(
            title: '4. Guarantors (${data.guarantors.length})',
            icon: Icons.group_outlined,
            children: data.guarantors.asMap().entries.map((entry) {
              int idx = entry.key;
              var g = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Guarantor #${idx + 1}: ${g.name ?? "N/A"} (${g.relationship ?? "N/A"})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    _buildRow('Phone', g.phone ?? 'N/A'),
                    _buildRow('NID Number', g.nidPassportNumber ?? 'N/A'),
                    const SizedBox(height: 4),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // 5. Payment Summary
          _buildSummarySection(
            title: '5. Payment Details',
            icon: Icons.payment_outlined,
            children: [
              _buildRow('Payment Method', data.downPaymentMethod ?? 'CASH'),
              if (data.downPaymentMethod == 'BANK') ...[
                _buildRow('Transaction Ref No', data.downPaymentReferenceNumber ?? 'N/A'),
                _buildFileStatus('Bank Deposit Receipt', data.bankReceipt != null),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Submit / Confirm Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                bool success = await vm.submitOrder();

                // Check if the widget is still in the tree before using context
                if (!context.mounted) return;

                if (success) {
                  onSuccess();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(vm.errorMessage ?? 'Failed to submit loan application'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // Green Color as per screenshot
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: vm.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Confirm & Pay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummarySection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _buildFileStatus(String label, bool isUploaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Row(
            children: [
              Icon(
                isUploaded ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: isUploaded ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                isUploaded ? 'Attached' : 'Not Provided',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isUploaded ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
