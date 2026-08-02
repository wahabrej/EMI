import 'package:flutter/material.dart';
import '../../../../core/constant/App_Colors.dart';
import '../model/customer_loan_application_model.dart';

class CustomerLoanApplicationDetailsScreen extends StatelessWidget {
  final CustomerLoanApplicationModel application;
  const CustomerLoanApplicationDetailsScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20),
        ),
        title: const Text('Application Details', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 16),
            _buildDetailCard(),
            if (application.status == 'REJECTED') _buildRejectionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          _getStatusIcon(),
          const SizedBox(height: 12),
          Text(
            "Application ${application.status}",
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: _getStatusColor()
            ),
          ),
          const SizedBox(height: 4),
          Text("ID: ${application.displayId}", style: const TextStyle(color: AppColors.greyText)),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          _buildRow('Product', application.product?.name ?? 'N/A'),
          _buildRow('Regular Price', '৳${application.regularPrice ?? 0}'),
          _buildRow('Down Payment', '৳${application.downPayment ?? 0}'),
          _buildRow('Tenure', '${application.planMonths ?? 0} Months'),
          _buildRow('Monthly EMI', '৳${application.monthlyEmi ?? 0}'),
          _buildRow('Date', application.issueDate ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildRejectionCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rejection Reason:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.errorRed)),
          const SizedBox(height: 4),
          Text(application.rejectionReason ?? 'No reason provided', style: const TextStyle(color: AppColors.errorRed)),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.greyText, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (application.status == 'APPROVED') return AppColors.successGreen;
    if (application.status == 'REJECTED') return AppColors.errorRed;
    return Colors.orange;
  }

  Widget _getStatusIcon() {
    IconData icon = Icons.hourglass_empty_rounded;
    Color color = Colors.orange;
    if (application.status == 'APPROVED') {
      icon = Icons.check_circle_rounded;
      color = AppColors.successGreen;
    } else if (application.status == 'REJECTED') {
      icon = Icons.cancel_rounded;
      color = AppColors.errorRed;
    }
    return Icon(icon, size: 50, color: color);
  }
}
