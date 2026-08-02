import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constant/App_Colors.dart';
import '../../../../core/constant/Token_storage.dart';
import '../../parent/viewModel/customerParentViewModel.dart';
import '../../../../core/routes/Routes_name.dart';
import '../viewModel/home_view_model.dart';
import '../model/customer_dashboard_model.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final AppStorage _appStorage = AppStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerHomeViewModel>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomerHomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.accentBlue,
        elevation: 0.5,
        title: Row(
          children: [
            Image.asset(
              'assets/icons/logo.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) => const Text(
                'SMART PAY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(
              context,
              RouteName.customerNotificationScreen,
            ),
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.white,
              size: 26,
            ),
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : vm.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.errorRed,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vm.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.fetchDashboard(),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => vm.fetchDashboard(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserGreeting(),
                    const SizedBox(height: 20),
                    _buildOutstandingCard(context, vm.dashboardData),
                    const SizedBox(height: 24),
                    _buildLoanProgressCard(vm.dashboardData),
                    const SizedBox(height: 24),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionsGrid(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserGreeting() {
    return FutureBuilder<String?>(
      future: _appStorage.getUserName(),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'Customer';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const Text(
              'Good morning!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // Outstanding Balance Card
  // ─────────────────────────────────────────────
  Widget _buildOutstandingCard(
    BuildContext context,
    CustomerDashboardModel? model,
  ) {
    double totalOutstanding = 0;
    String dueDateStr = 'No Pending EMI';
    String daysLeft = '0';
    Installments? nextEmi;
    String? firstLoanId;

    final loans = model?.data?.loans;

    if (loans != null && loans.isNotEmpty) {
      firstLoanId = loans.first.id;

      // সব লোনের সব ইনস্টলমেন্ট থেকে Pending বের করা
      final List<Installments> allPending = [];

      for (var loan in loans) {
        if (loan.installments != null) {
          for (var emi in loan.installments!) {
            if (emi.status?.toUpperCase() == 'PENDING') {
              allPending.add(emi);
              totalOutstanding += double.tryParse(emi.totalDue ?? '0') ?? 0;
            }
          }
        }
      }

      // সবচেয়ে কাছের due date বের করা
      if (allPending.isNotEmpty) {
        allPending.sort((a, b) {
          try {
            return DateTime.parse(
              a.dueDate ?? '',
            ).compareTo(DateTime.parse(b.dueDate ?? ''));
          } catch (_) {
            return 0;
          }
        });

        nextEmi = allPending.first;

        try {
          final date = DateTime.parse(nextEmi.dueDate!);
          dueDateStr = DateFormat('dd MMM yyyy').format(date);
          final diff = date.difference(DateTime.now()).inDays;
          daysLeft = diff > 0 ? '$diff' : '0';
        } catch (e) {
          dueDateStr = nextEmi.dueDate ?? 'N/A';
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Outstanding Balance',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (firstLoanId != null) {
                    Navigator.pushNamed(
                      context,
                      RouteName.customerLoanDetailsScreen,
                      arguments: firstLoanId,
                    );
                  }
                },
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '৳${totalOutstanding.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.errorRed,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Next Payment Due',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dueDateStr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              if (totalOutstanding > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$daysLeft Days Left',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: totalOutstanding > 0
                  ? () => context.read<CustomerParentViewModel>().setIndex(1)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Loan Progress Card
  // ─────────────────────────────────────────────
  Widget _buildLoanProgressCard(CustomerDashboardModel? model) {
    double progress = 0.0;
    int paid = 0;
    int total = 0;

    final loans = model?.data?.loans;

    if (loans != null && loans.isNotEmpty) {
      for (var loan in loans) {
        if (loan.installments != null) {
          total += loan.installments!.length;
          paid += loan.installments!
              .where((i) => i.status?.toUpperCase() == 'PAID')
              .length;
        }
      }
      progress = total > 0 ? paid / total : 0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Loan Progress',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              Text(
                '${(progress * 100).toInt()}% Completed',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.successGreen,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$paid of $total EMIs Paid',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.greyText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Quick Actions
  // ─────────────────────────────────────────────
  Widget _buildQuickActionsGrid(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          Icons.history_toggle_off_rounded,
          'Payments',
          () => context.read<CustomerParentViewModel>().setIndex(1),
        ),
        _buildActionItem(
          Icons.assignment_turned_in_outlined,
          'My Apps',
          () => Navigator.pushNamed(
            context,
            RouteName.customerLoanApplicationListScreen,
          ),
        ),
        _buildActionItem(
          Icons.folder_open_rounded,
          'Docs',
          () => Navigator.pushNamed(context, RouteName.customerDocumentsScreen),
        ),
        _buildActionItem(
          Icons.support_agent_rounded,
          'Support',
          () => context.read<CustomerParentViewModel>().setIndex(2),
        ),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderGrey, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
