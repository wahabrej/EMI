import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/routes/Routes_name.dart';
import '../Model/singleLoanModel.dart';
import '../ViewModel/PaymentViewModel.dart';

class SingleLoanDetailScreen extends StatefulWidget {
  final String loanId;

  const SingleLoanDetailScreen({super.key, required this.loanId});

  @override
  State<SingleLoanDetailScreen> createState() => _SingleLoanDetailScreenState();
}

class _SingleLoanDetailScreenState extends State<SingleLoanDetailScreen> {
  String _paymentMethod = 'CASH';
  final _amountController = TextEditingController();
  final _bankAccountNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _senderMobileController = TextEditingController();
  final _referenceController = TextEditingController();
  final _remarksController = TextEditingController();

  File? _receiptFile;
  final ImagePicker _picker = ImagePicker();
  bool _showPaymentForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentViewModel>().fetchLoanDetails(widget.loanId);
    });
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20),
        ),
        title: const Text(
          'Loan Details',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<PaymentViewModel>().fetchLoanDetails(widget.loanId);
            },
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryBlue, size: 22),
          ),
        ],
      ),
      body: Consumer<PaymentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.loanData == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0052CC)),
                  SizedBox(height: 16),
                  Text('Loading loan details...'),
                ],
              ),
            );
          }

          if (viewModel.errorMessage != null && viewModel.loanData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.fetchLoanDetails(widget.loanId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final loan = viewModel.loanData?.data;
          if (loan == null) {
            return const Center(child: Text('No loan data found'));
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(loan.status ?? 'N/A'),
                const SizedBox(height: 16),
                _buildCustomerInfoCard(loan, currency),
                const SizedBox(height: 16),
                _buildLoanInfoCard(loan, currency),
                const SizedBox(height: 16),
                _buildShopHierarchySection(loan),
                const SizedBox(height: 16),
                if (loan.customer?.guarantors != null && loan.customer!.guarantors!.isNotEmpty)
                  _buildGuarantorsSection(loan.customer!.guarantors!),
                const SizedBox(height: 16),
                _buildInstallmentsSection(loan, currency),
                const SizedBox(height: 16),
                if (viewModel.isLoanCollectible())
                  _buildPaymentButton(viewModel),
                const SizedBox(height: 16),
                if (_showPaymentForm)
                  _buildPaymentForm(viewModel),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBanner(String status) {
    Color color = Colors.orange;
    String displayStatus = status.toUpperCase();

    if (displayStatus == 'APPROVED' || displayStatus == 'ACTIVE' || displayStatus == 'DISBURSED') {
      color = AppColors.successGreen;
    } else if (displayStatus == 'REJECTED' || displayStatus == 'CANCELLED') {
      color = AppColors.errorRed;
    } else if (displayStatus == 'PENDING') {
      color = Colors.orange;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            displayStatus == 'APPROVED' || displayStatus == 'ACTIVE' || displayStatus == 'DISBURSED'
                ? Icons.check_circle_outline
                : displayStatus == 'REJECTED'
                ? Icons.cancel_outlined
                : Icons.hourglass_empty_outlined,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Status: $displayStatus',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          if (displayStatus == 'APPROVED' || displayStatus == 'ACTIVE' || displayStatus == 'DISBURSED')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Collectible',
                style: TextStyle(
                  color: AppColors.successGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(Data loan, NumberFormat currency) {
    final customer = loan.customer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Divider(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                child: Text(
                  customer?.name?.isNotEmpty == true
                      ? customer!.name![0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer?.name ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          customer?.phone ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          'Customer ID: ${customer?.displayId ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loan.displayId ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0052CC),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _infoChip(
                  'Source of Income',
                  customer?.sourceOfIncome ?? 'N/A',
                  Icons.work_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _infoChip(
                  'Monthly Income',
                  '৳${currency.format(double.tryParse(customer?.monthlyIncome ?? '0') ?? 0)}',
                  Icons.currency_exchange_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Color(0xFF64748B)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanInfoCard(Data loan, NumberFormat currency) {
    final calc = loan.calculationSnapshot;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loan Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _loanInfoItem(
                  'Product',
                  loan.product?.name ?? 'N/A',
                  Icons.smartphone_rounded,
                ),
              ),
              Expanded(
                child: _loanInfoItem(
                  'Brand',
                  loan.product?.name ?? 'N/A',
                  Icons.business_center_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _loanInfoItem(
                  'Loan Amount',
                  '৳${currency.format(double.tryParse(calc?.regularPrice ?? '0') ?? 0)}',
                  Icons.currency_exchange_rounded,
                ),
              ),
              Expanded(
                child: _loanInfoItem(
                  'Monthly EMI',
                  '৳${currency.format(double.tryParse(calc?.monthlyEmi ?? '0') ?? 0)}',
                  Icons.payments_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _loanInfoItem(
                  'Tenure',
                  '${calc?.planMonths ?? 0} Months',
                  Icons.calendar_month_rounded,
                ),
              ),
              Expanded(
                child: _loanInfoItem(
                  'Down Payment',
                  '৳${currency.format(double.tryParse(calc?.downPaymentAmount ?? '0') ?? 0)}',
                  Icons.download_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _loanInfoItem(
                  'Financed Amount',
                  '৳${currency.format(double.tryParse(calc?.financedAmount ?? '0') ?? 0)}',
                  Icons.account_balance_wallet_outlined,
                ),
              ),
              Expanded(
                child: _loanInfoItem(
                  'Total Payable',
                  '৳${currency.format(double.tryParse(calc?.totalScheduledPayable ?? '0') ?? 0)}',
                  Icons.balance,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loanInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Color(0xFF0052CC)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopHierarchySection(Data loan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shop Hierarchy',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _hierarchyItem(
                  'Shop',
                  loan.shop?.name ?? 'N/A',
                  Icons.storefront_rounded,
                ),
              ),
              Expanded(
                child: _hierarchyItem(
                  'Agent',
                  loan.agent?.name ?? 'N/A',
                  Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _hierarchyItem(
                  'Manager',
                  loan.manager?.name ?? 'N/A',
                  Icons.manage_accounts_rounded,
                ),
              ),
              Expanded(
                child: _hierarchyItem(
                  'Sales Person',
                  loan.salesPerson?.name ?? 'N/A',
                  Icons.person_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hierarchyItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Color(0xFF0052CC)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuarantorsSection(List<Guarantors> guarantors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guarantors',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Divider(height: 20),
          ...guarantors.map((g) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        child: Text(
                          g.name?.isNotEmpty == true ? g.name![0].toUpperCase() : 'G',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.name ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${g.relationship ?? 'N/A'} • ${g.phone ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: g.type == 'FAMILY'
                              ? AppColors.successGreen.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          g.type ?? 'N/A',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: g.type == 'FAMILY'
                                ? AppColors.successGreen
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NID: ${g.nidPassportNumber ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInstallmentsSection(Data loan, NumberFormat currency) {
    final installments = loan.installments ?? [];
    if (installments.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'No installments found',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
      );
    }

    int paidCount = 0;
    int pendingCount = 0;
    double totalDue = 0;
    for (var inst in installments) {
      if (inst.status?.toUpperCase() == 'PAID') {
        paidCount++;
      } else {
        pendingCount++;
        totalDue += double.tryParse(inst.totalDue ?? '0') ?? 0;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Installments',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Tap to view details',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _summaryChip('Paid', '$paidCount', AppColors.successGreen),
                const SizedBox(width: 8),
                _summaryChip('Pending', '$pendingCount', Colors.orange),
                const SizedBox(width: 8),
                _summaryChip('Total Due', '৳${currency.format(totalDue)}', const Color(0xFF0052CC)),
              ],
            ),
          ),
          ...installments.map((inst) {
            final isPaid = inst.status?.toUpperCase() == 'PAID';
            final isOverdue = !isPaid && DateTime.tryParse(inst.dueDate ?? '')?.isBefore(DateTime.now()) == true;

            return InkWell(
              onTap: () {
                _showInstallmentDetailsDialog(context, inst, currency);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: const Color(0xFFF1F5F9)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isPaid
                            ? AppColors.successGreen.withOpacity(0.1)
                            : isOverdue
                            ? AppColors.errorRed.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${inst.installmentNumber ?? ''}',
                          style: TextStyle(
                            color: isPaid
                                ? AppColors.successGreen
                                : isOverdue
                                ? AppColors.errorRed
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Installment #${inst.installmentNumber ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            inst.dueDate != null
                                ? DateFormat('dd MMM yyyy').format(DateTime.parse(inst.dueDate!))
                                : 'No due date',
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? AppColors.errorRed : Color(0xFF64748B),
                              fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '৳${currency.format(double.tryParse(inst.totalDue ?? '0') ?? 0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isPaid ? AppColors.successGreen : Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? AppColors.successGreen.withOpacity(0.1)
                                : isOverdue
                                ? AppColors.errorRed.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPaid ? 'PAID' : isOverdue ? 'OVERDUE' : 'PENDING',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: isPaid
                                  ? AppColors.successGreen
                                  : isOverdue
                                  ? AppColors.errorRed
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showInstallmentDetailsDialog(BuildContext context, Installments inst, NumberFormat currency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Installment #${inst.installmentNumber ?? ''}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Status', inst.status ?? 'N/A'),
            _detailRow('Due Date', inst.dueDate != null
                ? DateFormat('dd MMM yyyy').format(DateTime.parse(inst.dueDate!))
                : 'N/A'),
            _detailRow('Original Amount', '৳${currency.format(double.tryParse(inst.originalAmount ?? '0') ?? 0)}'),
            _detailRow('Paid Amount', '৳${currency.format(double.tryParse(inst.paidAmount ?? '0') ?? 0)}'),
            _detailRow('Remaining Amount', '৳${currency.format(double.tryParse(inst.remainingAmount ?? '0') ?? 0)}'),
            _detailRow('Penalty Amount', '৳${currency.format(double.tryParse(inst.penaltyAmount ?? '0') ?? 0)}'),
            _detailRow('Total Due', '৳${currency.format(double.tryParse(inst.totalDue ?? '0') ?? 0)}'),
            if (inst.cashbackAmount != null && double.tryParse(inst.cashbackAmount!) != 0)
              _detailRow('Cashback', '৳${currency.format(double.tryParse(inst.cashbackAmount ?? '0') ?? 0)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(PaymentViewModel viewModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showPaymentForm = !_showPaymentForm;
                if (!_showPaymentForm) {
                  _amountController.text = viewModel.getNextInstallmentDueAmount().toStringAsFixed(2);
                }
              });
            },
            icon: Icon(
              _showPaymentForm ? Icons.keyboard_arrow_up_rounded : Icons.payments_outlined,
              color: Colors.white,
              size: 22,
            ),
            label: Text(
              _showPaymentForm ? 'Hide Payment Form' : 'Make Payment',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _showPaymentForm ? AppColors.greyText : const Color(0xFF0052CC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        if (_showPaymentForm)
          const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPaymentForm(PaymentViewModel viewModel) {
    final nextDue = viewModel.getNextInstallmentDueAmount();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const Divider(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Next Installment Due',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '৳${NumberFormat('#,###').format(nextDue)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _methodOption('CASH', Icons.money_rounded),
                const SizedBox(width: 4),
                _methodOption('BANK', Icons.account_balance_outlined),
                const SizedBox(width: 4),
                _methodOption('BKASH', Icons.phone_android_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: 'Enter payment amount',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.currency_exchange_rounded),
            ),
          ),
          const SizedBox(height: 12),

          if (_paymentMethod == 'BANK') ...[
            TextFormField(
              controller: _bankAccountNameController,
              decoration: const InputDecoration(
                labelText: 'Bank Account Name',
                hintText: 'Enter account holder name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bankAccountNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bank Account Number',
                hintText: 'Enter account number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bankNameController,
              decoration: const InputDecoration(
                labelText: 'Bank Name',
                hintText: 'Enter bank name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (_paymentMethod == 'BKASH') ...[
            TextFormField(
              controller: _senderMobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'bKash Account Number',
                hintText: '017xxxxxxxx',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_android_rounded),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (_paymentMethod != 'CASH')
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Reference Number',
                hintText: 'Transaction ID / Reference',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt_long_rounded),
              ),
            ),
          const SizedBox(height: 12),

          if (_paymentMethod != 'CASH')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _paymentMethod == 'BANK' ? 'Bank Receipt (Required)' : 'Payment Screenshot (Optional)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
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
                              : _paymentMethod == 'BANK'
                              ? 'Upload receipt (Required)'
                              : 'Upload screenshot (Optional)',
                          style: TextStyle(
                            color: _receiptFile != null ? Colors.green : Colors.grey,
                            fontSize: 13,
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
                      '✅ Selected: ${(_receiptFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),

          TextFormField(
            controller: _remarksController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Remarks (Optional)',
              hintText: 'Any additional notes',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_outlined),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: viewModel.isLoading ? null : () => _submitPayment(context, viewModel),
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
        ],
      ),
    );
  }

  Widget _methodOption(String method, IconData icon) {
    final isSelected = _paymentMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
              Icon(
                icon,
                color: isSelected ? const Color(0xFF0052CC) : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                method,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0052CC) : Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _submitPayment(BuildContext context, PaymentViewModel viewModel) async {
    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter payment amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_paymentMethod == 'BANK' && _receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload bank receipt'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_paymentMethod == 'BKASH' && _referenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter bKash transaction ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await viewModel.submitPayment(
      loanId: widget.loanId,
      installmentId: viewModel.getNextInstallment()?.id,
      amount: amount,
      paymentMethod: _paymentMethod,
      bankAccountName: _bankAccountNameController.text.trim(),
      bankAccountNumber: _bankAccountNumberController.text.trim(),
      bankName: _bankNameController.text.trim(),
      senderMobileNumber: _senderMobileController.text.trim(),
      referenceNumber: _referenceController.text.trim(),
      remarks: _remarksController.text.trim(),
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
      setState(() {
        _showPaymentForm = false;
        _receiptFile = null;
        _amountController.clear();
        _bankAccountNameController.clear();
        _bankAccountNumberController.clear();
        _bankNameController.clear();
        _senderMobileController.clear();
        _referenceController.clear();
        _remarksController.clear();
      });
      viewModel.fetchLoanDetails(widget.loanId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Payment failed'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}