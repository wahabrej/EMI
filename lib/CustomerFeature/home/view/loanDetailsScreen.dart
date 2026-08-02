import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constant/App_Colors.dart';
import '../model/customer_loan_model.dart';
import '../viewModel/loan_view_model.dart';

class CustomerLoanDetailsScreen extends StatefulWidget {
  final String? loanId;
  const CustomerLoanDetailsScreen({super.key, this.loanId});

  @override
  State<CustomerLoanDetailsScreen> createState() => _CustomerLoanDetailsScreenState();
}

class _CustomerLoanDetailsScreenState extends State<CustomerLoanDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.loanId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<CustomerLoanViewModel>().fetchLoanDetails(widget.loanId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomerLoanViewModel>();
    final loan = vm.selectedLoanDetails; // এটা Data টাইপের হবে (একক লোন)

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20),
        ),
        title: const Text(
          'Loan Details',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : loan == null
          ? const Center(child: Text("No loan details found."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Info Header ────────────────────────────
            _buildProductHeader(loan),
            const SizedBox(height: 16),

            // ── Loan Data List ──────────────────────────────────
            _buildLoanInfoList(loan),
            const SizedBox(height: 24),

            // ── Promo Banner ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Pay on time and keep your device active.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Need Help Section ────────────────────────────────
            const Text(
              'Need Help?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildHelpButton(Icons.chat_bubble_outline, 'Chat with Support')),
                const SizedBox(width: 12),
                Expanded(child: _buildHelpButton(Icons.call_outlined, 'Call Us')),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Product Header
  // ─────────────────────────────────────────────
  Widget _buildProductHeader(Data loan) {
    final productName = loan.product?.name ?? loan.productModel?.name ?? 'Unknown Device';
    final productCode = loan.product?.code ?? loan.productModel?.code ?? 'N/A';
    final status = loan.status ?? 'Pending';
    final isActive = status.toUpperCase() == 'ACTIVE' || status.toUpperCase() == 'DISBURSED';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.phone_iphone, size: 40, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Code: $productCode',
                  style: const TextStyle(fontSize: 12, color: AppColors.greyText),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.successBg : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppColors.successGreen : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Loan Info List
  // ─────────────────────────────────────────────
  Widget _buildLoanInfoList(Data loan) {
    double totalOutstanding = 0;
    String nextDueDate = 'N/A';

    if (loan.installments != null && loan.installments!.isNotEmpty) {
      final pendingList = loan.installments!
          .where((i) => i.status?.toUpperCase() == 'PENDING')
          .toList();

      for (var emi in pendingList) {
        totalOutstanding += double.tryParse(emi.totalDue ?? '0') ?? 0;
      }

      if (pendingList.isNotEmpty) {
        // সবচেয়ে কাছের due date
        pendingList.sort((a, b) {
          try {
            return DateTime.parse(a.dueDate ?? '').compareTo(DateTime.parse(b.dueDate ?? ''));
          } catch (_) {
            return 0;
          }
        });

        try {
          final date = DateTime.parse(pendingList.first.dueDate!);
          nextDueDate = DateFormat('dd MMM yyyy').format(date);
        } catch (e) {
          nextDueDate = pendingList.first.dueDate ?? 'N/A';
        }
      }
    }

    final financedAmount = double.tryParse(loan.calculationSnapshot?.financedAmount ?? '0') ?? 0;
    final monthlyEmi = double.tryParse(loan.calculationSnapshot?.monthlyEmi ?? '0') ?? 0;
    final planMonths = loan.calculationSnapshot?.planMonths ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          _buildDataRow('Loan Amount', '৳${financedAmount.toStringAsFixed(0)}'),
          _buildDataRow('Monthly EMI', '৳${monthlyEmi.toStringAsFixed(0)}'),
          _buildDataRow('Tenure', '$planMonths Months'),
          _buildDataRow('Disbursed On', _formatDate(loan.disbursementDate)),
          _buildDataRow('Next Due Date', nextDueDate),
          _buildDataRow(
            'Outstanding',
            '৳${totalOutstanding.toStringAsFixed(0)}',
            isValueRed: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isValueRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isValueRed ? AppColors.errorRed : AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}