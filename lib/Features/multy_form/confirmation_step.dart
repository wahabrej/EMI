import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/multy_form/viewModel/multyform_provider.dart';
import '../../../../core/constant/App_Colors.dart';

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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black),
          ),
          const SizedBox(height: 4),
          const Text(
            'Please review all collected details before final submission',
            style: TextStyle(fontSize: 12, color: AppColors.greyText),
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
            height: 52,
            child: ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                debugPrint("🔘 [ConfirmationStep] 'Confirm & Submit' clicked");
                bool success = await vm.submitOrder();
                debugPrint("🔄 [ConfirmationStep] Submission result: $success");

                if (!context.mounted) return;

                if (success) {
                  _showResponseDialog(
                    context: context,
                    isSuccess: true,
                    message: "Your application has been submitted successfully!",
                    vm: vm,
                  );
                } else {
                  _showResponseDialog(
                    context: context,
                    isSuccess: false,
                    message: vm.errorMessage ?? "Something went wrong. Please try again.",
                    vm: vm,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: vm.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'SUBMIT',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showResponseDialog({
    required BuildContext context,
    required bool isSuccess,
    required String message,
    required CheckoutViewModel vm,
  }) {
    debugPrint("📢 [ConfirmationStep] Showing ${isSuccess ? 'SUCCESS' : 'FAILURE'} Dialog");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: isSuccess ? AppColors.successGreen : AppColors.errorRed,
              size: 70,
            ),
            const SizedBox(height: 16),
            Text(
              isSuccess ? "Success!" : "Submission Failed",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isSuccess ? AppColors.successGreen : AppColors.errorRed,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.iconGrey, fontWeight: FontWeight.w500, height: 1.5),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? AppColors.primaryBlue : AppColors.errorRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              onPressed: () {
                if (isSuccess) {
                  debugPrint("🏠 [ConfirmationStep] Navigating back to Home");
                  vm.resetStep();
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                } else {
                  debugPrint("🔄 [ConfirmationStep] Closing Dialog to Try Again");
                  Navigator.pop(context);
                }
              },
              child: Text(
                isSuccess ? "Back to Home" : "Try Again",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.black)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.bgGrey),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.greyText, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.black)),
        ],
      ),
    );
  }

  Widget _buildFileStatus(String label, bool isUploaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.greyText, fontWeight: FontWeight.w500)),
          Row(
            children: [
              Icon(
                isUploaded ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: isUploaded ? AppColors.successGreen : AppColors.errorRed,
              ),
              const SizedBox(width: 4),
              Text(
                isUploaded ? 'Attached' : 'Not Provided',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isUploaded ? AppColors.successGreen : AppColors.errorRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
