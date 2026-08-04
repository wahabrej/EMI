import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constant/App_Colors.dart';
import '../model/PaymentHistoryModel.dart';
import '../viewmodel/PaymentHistoryViewModel.dart';

class PaymentScreen extends StatefulWidget {
  final String? loanId;

  const PaymentScreen({super.key, this.loanId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentHistoryViewModel>(context, listen: false)
          .fetchPaymentHistory(loanId: widget.loanId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.accentBlue,
        elevation: 0,
        title: const Text(
          'Payment History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PaymentHistoryViewModel>(
        builder: (context, viewModel, child) {
          // 1. Loading State
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          // 2. Error State
          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.fetchPaymentHistory(loanId: widget.loanId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }

          // 3. Empty State
          if (viewModel.payments.isEmpty) {
            return const Center(
              child: Text(
                'No payment history found.',
                style: TextStyle(color: AppColors.greyText, fontSize: 15),
              ),
            );
          }

          // 4. Data List Render
          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchPaymentHistory(loanId: widget.loanId);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(16.0),
              itemCount: viewModel.payments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = viewModel.payments[index];
                return _buildPaymentCard(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(Data payment) {
    final status = payment.status?.toUpperCase() ?? 'PENDING';

    // Status Color Helper
    Color statusColor;
    Color statusBg;
    if (status == 'APPROVED' || status == 'SUCCESS') {
      statusColor = AppColors.successGreen;
      statusBg = AppColors.successBg;
    } else if (status == 'REJECTED' || status == 'FAILED') {
      statusColor = Colors.red;
      statusBg = Colors.red.shade50;
    } else {
      statusColor = Colors.orange;
      statusBg = Colors.orange.shade50;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Customer Name/Display ID & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  payment.loan?.customer?.name ?? 'Trx: ${payment.displayId ?? "N/A"}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(color: AppColors.borderGrey, height: 1),
          const SizedBox(height: 12),

          // Details Rows
          _buildDetailRow('Amount', '৳${payment.amount ?? "0.00"}', isBold: true),
          const SizedBox(height: 6),
          _buildDetailRow('Payment Method', payment.paymentMethod ?? 'N/A'),
          const SizedBox(height: 6),
          if (payment.referenceNumber != null && payment.referenceNumber!.isNotEmpty) ...[
            _buildDetailRow('Ref / Trx ID', payment.referenceNumber!),
            const SizedBox(height: 6),
          ],
          _buildDetailRow('Date', _formatDate(payment.createdAt ?? payment.collectedAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.greyText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.primaryBlue : AppColors.black,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(rawDate);
      return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
    } catch (e) {
      return rawDate;
    }
  }
}