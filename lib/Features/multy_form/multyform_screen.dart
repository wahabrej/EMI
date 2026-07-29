import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/multy_form/viewModel/multyform_provider.dart';

import 'Payment_step.dart';
import 'confirmation_step.dart'; // 🔹 Imported Confirmation Step
import 'customer_info_step.dart';
import 'guarantor_step.dart';
import 'kyc_verification_step.dart';
import 'order_review_step.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CheckoutViewModel(),
      child: Consumer<CheckoutViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: const Text(
                'Checkout Workflow',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              backgroundColor: Colors.white,
              elevation: 0.5,
              leading: vm.currentStep > 0
                  ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => vm.previousStep(),
              )
                  : null,
            ),
            body: vm.isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Submitting Application... Please Wait'),
                ],
              ),
            )
                : Column(
              children: [
                // Step Progress Bar Header
                _buildStepHeader(vm.currentStep),

                // All 6 Steps
                Expanded(
                  child: IndexedStack(
                    index: vm.currentStep,
                    children: [
                      // Step 1: Order Review
                      OrderReviewStep(
                        onNext: () => vm.nextStep(),
                      ),

                      // Step 2: Customer Info
                      CustomerInfoStep(
                        onNext: () => vm.nextStep(),
                      ),

                      // Step 3: KYC Verification
                      KycVerificationStep(
                        onNext: () => vm.nextStep(),
                      ),

                      // Step 4: Guarantor Step
                      GuarantorStep(
                        onNext: () => vm.nextStep(),
                      ),

                      // Step 5: Payment Step
                      PaymentStep(
                        onNext: () => vm.nextStep(),
                      ),

                      // Step 6: Confirmation Step (Connected to ConfirmationStep widget)
                      ConfirmationStep(
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Loan Application Submitted Successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // TODO: Navigate to Home or Success screen if needed
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Header Stepper
  Widget _buildStepHeader(int currentStep) {
    List<String> titles = ['Order', 'Customer', 'KYC', 'Guarantor', 'Payment', 'Confirm'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(titles.length, (index) {
          bool active = index <= currentStep;
          return Column(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: active ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(fontSize: 9, color: active ? Colors.white : Colors.black45),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titles[index],
                style: TextStyle(
                  fontSize: 9,
                  color: active ? const Color(0xFF2563EB) : Colors.black38,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}