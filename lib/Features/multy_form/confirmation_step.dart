// lib/features/checkout/screens/confirmation_step.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
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
              _buildRow(
                'Product Price (MRP)',
                '৳ ${data.mrp.toStringAsFixed(0)}',
              ),
              if (data.saleType == 'EMI') ...[
                _buildRow(
                  'Down Payment',
                  '৳ ${data.downPayment.toStringAsFixed(0)}',
                ),
                _buildRow(
                  'Monthly EMI',
                  '৳ ${data.monthlyEmi.toStringAsFixed(0)}',
                ),
                _buildRow(
                  'Payment Date',
                  data.monthlyPaymentDate != null
                      ? DateFormat(
                          'dd MMM yyyy',
                        ).format(DateTime.parse(data.monthlyPaymentDate!))
                      : 'N/A',
                ),
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
              _buildRow('ID Type', data.customerIdType ?? 'NID'),
              _buildRow(
                '${data.customerIdType ?? "NID"} Number',
                data.nidPassportNumber ?? 'N/A',
              ),
              _buildRow(
                'Monthly Income',
                '৳ ${data.monthlyIncome.toStringAsFixed(0)}',
              ),
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
              _buildFileStatus('Customer Video', vm.customerVideoFile != null),
              if (data.customerIdType == 'NID') ...[
                _buildFileStatus('NID Front Image', data.nidFront != null),
                _buildFileStatus('NID Back Image', data.nidBack != null),
              ] else ...[
                _buildFileStatus('Passport Copy', data.nidFront != null),
              ],
              _buildFileStatus(
                'Income Proof Document',
                data.incomeProof != null,
              ),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    _buildRow('Type', g.type ?? 'N/A'),
                    _buildRow('Phone', g.phone ?? 'N/A'),
                    _buildRow('ID Type', g.idType ?? 'NID'),
                    _buildRow(
                      '${g.idType ?? "NID"} Number',
                      g.nidPassportNumber ?? 'N/A',
                    ),
                    if (g.idType == 'NID') ...[
                      _buildFileStatus('NID Front', g.nidFront != null),
                      _buildFileStatus('NID Back', g.nidBack != null),
                    ] else ...[
                      _buildFileStatus('Passport Copy', g.nidFront != null),
                    ],
                    const SizedBox(height: 4),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // 5. Payment Summary
          // lib/features/checkout/screens/confirmation_step.dart

          // ─── Payment Summary ───
          _buildSummarySection(
            title: '5. Payment Details',
            icon: Icons.payment_outlined,
            children: [
              _buildRow('Payment Method', data.downPaymentMethod ?? 'CASH'),

              // ✅ 👇 এখানে যোগ করুন
              if (data.downPaymentMethod == 'BANK') ...[
                _buildRow('Bank Account Name', data.bankAccountName ?? 'N/A'),
                _buildRow(
                  'Bank Account Number',
                  data.bankAccountNumber ?? 'N/A',
                ),
                _buildRow('Bank Name', data.bankName ?? 'N/A'),
                _buildRow(
                  'Transaction Ref No',
                  data.downPaymentReferenceNumber ?? 'N/A',
                ),
                _buildFileStatus(
                  'Bank Deposit Receipt',
                  data.bankReceipt != null,
                ),
              ],

              //  BKASH এর জন্যও যোগ করতে পারেন
              if (data.downPaymentMethod == 'BKASH') ...[
                _buildRow(
                  'Sender Mobile',
                  data.downPaymentReferenceNumber ?? 'N/A',
                ),
                _buildRow(
                  'Transaction ID',
                  data.downPaymentReferenceNumber ?? 'N/A',
                ),
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
                      debugPrint("═══════════════════════════════════════");
                      debugPrint(
                        "🔘 [ConfirmationStep] 'SUBMIT' Button Clicked",
                      );
                      debugPrint("📦 Full Order Data:");
                      debugPrint("═══════════════════════════════════════");
                      debugPrint("📋 BASIC INFO:");
                      debugPrint("   Sale Type: ${data.saleType}");
                      debugPrint("   Customer Name: ${data.name}");
                      debugPrint("   Phone: ${data.phone}");
                      debugPrint(
                        "   Password: ${data.password.isNotEmpty ? '********' : 'empty'}",
                      );
                      debugPrint("   Present Address: ${data.presentAddress}");
                      debugPrint(
                        "   Permanent Address: ${data.permanentAddress}",
                      );
                      debugPrint("═══════════════════════════════════════");
                      debugPrint("📋 ID & INCOME:");
                      debugPrint("   ID Type: ${data.customerIdType}");
                      debugPrint(
                        "   NID/Passport Number: ${data.nidPassportNumber}",
                      );
                      debugPrint("   Source of Income: ${data.sourceOfIncome}");
                      debugPrint("   Monthly Income: ${data.monthlyIncome}");
                      debugPrint("═══════════════════════════════════════");
                      debugPrint("📋 PRODUCT INFO:");
                      debugPrint("   Product ID: ${data.productId}");
                      debugPrint("   Product Model: ${data.productModel}");
                      debugPrint("   Product Model ID: ${data.productModelId}");
                      debugPrint("   Brand Name: ${data.brandName}");
                      debugPrint("   MRP: ${data.mrp}");
                      debugPrint("═══════════════════════════════════════");
                      debugPrint("📋 EMI INFO:");
                      debugPrint("   EMI Mode: ${data.emiMode}");
                      debugPrint("   EMI Plan ID: ${data.emiPlanId}");
                      debugPrint("   Tenure: ${data.emiTenureMonths}");
                      debugPrint("   Down Payment: ${data.downPayment}");
                      debugPrint("   Monthly EMI: ${data.monthlyEmi}");

                      debugPrint("   EMI Charge: ${data.emiCharge}");
                      debugPrint("   App EMI Charge: ${data.appEmiCharge}");
                      debugPrint("   Financed Amount: ${data.financedAmount}");
                      debugPrint("   Total Payable: ${data.totalPayable}");
                      debugPrint("   Cashback Earned: ${data.cashbackEarned}");
                      debugPrint("═══════════════════════════════════════");
                      debugPrint("📋 STORE HIERARCHY:");
                      debugPrint("   Shop ID: ${data.shopId}");
                      debugPrint("   Agent ID: ${data.agentId}");
                      debugPrint("   Manager ID: ${data.managerId}");
                      debugPrint("   Sales Person ID: ${data.salesPersonId}");
                      debugPrint("═══════════════════════════════════════");
                      debugPrint("📋 PAYMENT:");
                      debugPrint(
                        "   Payment Method: ${data.downPaymentMethod}",
                      );
                      debugPrint(
                        "   Income Proof Type: ${data.incomeProofDocumentType}",
                      );
                      debugPrint(
                        "   Down Payment Ref No: ${data.downPaymentReferenceNumber ?? 'N/A'}",
                      );
                      debugPrint("═══════════════════════════════════════");
                      debugPrint("📋 FILE STATUS:");
                      debugPrint(
                        "   Customer Image: ${vm.customerImageFile != null ? '✅ Attached (${vm.customerImageFile!.path.split('/').last})' : '❌ Not Provided'}",
                      );
                      debugPrint(
                        "   Customer Video: ${vm.customerVideoFile != null ? '✅ Attached (${vm.customerVideoFile!.path.split('/').last})' : '❌ Not Provided'}",
                      );
                      debugPrint(
                        "   NID Front: ${data.nidFront != null ? '✅ Attached (${data.nidFront!.path.split('/').last})' : '❌ Not Provided'}",
                      );
                      debugPrint(
                        "   NID Back: ${data.nidBack != null ? '✅ Attached (${data.nidBack!.path.split('/').last})' : '❌ Not Provided'}",
                      );
                      debugPrint(
                        "   Income Proof: ${data.incomeProof != null ? '✅ Attached (${data.incomeProof!.path.split('/').last})' : '❌ Not Provided'}",
                      );
                      debugPrint(
                        "   Bank Receipt: ${data.bankReceipt != null ? '✅ Attached (${data.bankReceipt!.path.split('/').last})' : '❌ Not Provided'}",
                      );
                      debugPrint("═══════════════════════════════════════");
                      debugPrint("📋 GUARANTORS (${data.guarantors.length}):");

                      debugPrint(
                        "═══════════════             *********************      ════════════════════════",
                      );

                      for (int i = 0; i < data.guarantors.length; i++) {
                        final g = data.guarantors[i];
                        debugPrint("   Guarantor ${i + 1}:");
                        debugPrint("     Name: ${g.name}");
                        debugPrint("     Phone: ${g.phone}");
                        debugPrint("     Type: ${g.type}");
                        debugPrint("     Relationship: ${g.relationship}");
                        debugPrint("     ID Type: ${g.idType}");
                        debugPrint("     ID Number: ${g.nidPassportNumber}");
                        debugPrint(
                          "     NID Front: ${g.nidFront != null ? '✅ Attached' : '❌ Not Provided'}",
                        );
                        debugPrint(
                          "     NID Back: ${g.nidBack != null ? '✅ Attached' : '❌ Not Provided'}",
                        );
                      }
                      debugPrint("═══════════════════════════════════════");
                      debugPrint("🔄 Calling vm.submitOrder()...");

                      bool success = await vm.submitOrder();

                      debugPrint(
                        "📊 [ConfirmationStep] Submission Result: $success",
                      );

                      if (!context.mounted) return;

                      if (success) {
                        debugPrint(
                          "✅ [ConfirmationStep] Submission SUCCESSFUL!",
                        );
                        _showResponseDialog(
                          context: context,
                          isSuccess: true,
                          message:
                              "Your application has been submitted successfully!",
                          vm: vm,
                        );
                      } else {
                        debugPrint("❌ [ConfirmationStep] Submission FAILED!");
                        debugPrint("   Error: ${vm.errorMessage}");
                        _showResponseDialog(
                          context: context,
                          isSuccess: false,
                          message:
                              vm.errorMessage ??
                              "Something went wrong. Please try again.-------",
                          vm: vm,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: vm.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'SUBMIT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
    debugPrint(
      "📢 [ConfirmationStep] Showing ${isSuccess ? 'SUCCESS' : 'FAILURE'} Dialog",
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Main Message ───
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.iconGrey,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),

            // ─── 🔥 Backend Error Details (Only for Failure) ───
            if (!isSuccess && vm.errorMessage != null) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.errorRed, thickness: 1),
              const SizedBox(height: 12),
              const Text(
                'Error Details:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.errorRed.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  vm.errorMessage!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.errorRed.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please check the error above and try again.',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.iconGrey.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess
                    ? AppColors.primaryBlue
                    : AppColors.errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              onPressed: () {
                if (isSuccess) {
                  debugPrint("🏠 [ConfirmationStep] Navigating back to Home");
                  vm.resetStep();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                } else {
                  debugPrint(
                    "🔄 [ConfirmationStep] Closing Dialog to Try Again",
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(
                isSuccess ? "Back to Home" : "Try Again",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryBlue),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.black,
                ),
              ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
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
                  color: isUploaded
                      ? AppColors.successGreen
                      : AppColors.errorRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
