import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constant/App_Colors.dart';
import 'viewModel/multyform_provider.dart';
import 'order_review_step.dart';
import 'customer_info_step.dart';
import 'kyc_verification_step.dart';
import 'guarantor_step.dart';
import 'Payment_step.dart';
import 'confirmation_step.dart';

class MultyFormScreen extends StatelessWidget {
  const MultyFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckoutViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: AppColors.bgGrey,
          appBar: AppBar(
            backgroundColor: AppColors.accentBlue,
            elevation: 0,
            title: const Text(
              'Checkout Process',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: () {
                // Here using currentDisplayStep getter
                if (vm.currentDisplayStep > 0) {
                  vm.previousStep();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: _buildStepIndicator(vm),
            ),
          ),
          body: _buildStepBody(vm, context),
        );
      },
    );
  }

  Widget _buildStepIndicator(CheckoutViewModel vm) {
    final activeSteps = vm.activeStepIndices;
    final currentDisplayIndex = vm.currentDisplayStep; // Using the getter here
    final totalActiveSteps = vm.totalSteps;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: AppColors.accentBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalActiveSteps, (index) {
          bool isCompleted = currentDisplayIndex > index;
          bool isActive = currentDisplayIndex == index;
          int stepNumber = activeSteps[index] + 1; 

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.white
                        : (isCompleted ? AppColors.successGreen : Colors.white24),
                    shape: BoxShape.circle,
                    border: isActive ? Border.all(color: AppColors.white, width: 2) : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: AppColors.white)
                        : Text(
                            '$stepNumber',
                            style: TextStyle(
                              color: isActive ? AppColors.primaryBlue : AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                if (index < totalActiveSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppColors.successGreen : Colors.white24,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepBody(CheckoutViewModel vm, BuildContext context) {
    switch (vm.currentStep) {
      case 0: return OrderReviewStep(onNext: () => vm.nextStep());
      case 1: return CustomerInfoStep(onNext: () => vm.nextStep());
      case 2: return KycVerificationStep(onNext: () => vm.nextStep());
      case 3: return GuarantorStep(onNext: () => vm.nextStep());
      case 4: return PaymentStep(onNext: () => vm.nextStep());
      case 5: return ConfirmationStep(onSuccess: () => _handleSuccess(vm, context));
      default: return const Center(child: Text("Unknown Step"));
    }
  }

  void _handleSuccess(CheckoutViewModel vm, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Success"),
          ],
        ),
        content: const Text("Your order has been submitted successfully."),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              vm.resetStep();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text("Back to Home", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
