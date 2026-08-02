import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constant/App_Colors.dart';
import '../../../core/routes/Routes_name.dart';
import '../viewModel/customer_payment_history_view_model.dart';
import '../../home/viewModel/home_view_model.dart';
import '../../home/model/customer_dashboard_model.dart';
import 'ProceedToPayScreen.dart';

class CustomerPaymentScreen extends StatefulWidget {
  const CustomerPaymentScreen({super.key});

  @override
  State<CustomerPaymentScreen> createState() => _CustomerPaymentScreenState();
}

class _CustomerPaymentScreenState extends State<CustomerPaymentScreen> {
  final Set<String> _selectedInstallmentIds = {};
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerPaymentHistoryViewModel>().fetchPaymentHistory();
      context.read<CustomerHomeViewModel>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyVM = context.watch<CustomerPaymentHistoryViewModel>();
    final homeVM = context.watch<CustomerHomeViewModel>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Payments',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0F172A), size: 26),
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: Color(0xFF94A3B8),
            indicatorColor: AppColors.primaryBlue,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            tabs: [
              Tab(text: 'Pay Loan'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPayLoanTab(homeVM),
            _buildHistorySection(historyVM),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PAY LOAN TAB
  // ═══════════════════════════════════════════════════════════
  Widget _buildPayLoanTab(CustomerHomeViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }

    final loans = vm.dashboardData?.data?.loans ?? [];
    if (loans.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No active loans found.', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    final List<Installments> allInstallments = [];
    double totalOutstanding = 0;
    String loanAccount = loans.first.displayId ?? 'N/A';

    for (var loan in loans) {
      if (loan.installments != null) {
        for (var inst in loan.installments!) {
          allInstallments.add(inst);
          if (inst.status?.toUpperCase() == 'PENDING') {
            totalOutstanding += double.tryParse(inst.totalDue ?? '0') ?? 0;
          }
        }
      }
    }

    final filteredInstallments = allInstallments.where((i) {
      if (_searchQuery.isEmpty) return true;
      return (i.installmentNumber?.toString() ?? '').contains(_searchQuery);
    }).toList();

    double selectedAmount = 0;
    final selectedItems = allInstallments.where((i) => _selectedInstallmentIds.contains(i.id)).toList();
    for (var item in selectedItems) {
      selectedAmount += double.tryParse(item.totalDue ?? '0') ?? 0;
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              children: [
                _buildOutstandingCard(totalOutstanding, loanAccount, allInstallments.length),
                const SizedBox(height: 20),
                _buildSearchRow(),
                const SizedBox(height: 16),
                _buildInstallmentTable(filteredInstallments),
              ],
            ),
          ),
        ),
        if (_selectedInstallmentIds.isNotEmpty)
          _buildBottomPayBar(selectedItems.length, selectedAmount, selectedItems, loanAccount, vm),
      ],
    );
  }

  // ── Outstanding Card ──────────────────────────────────
  Widget _buildOutstandingCard(double balance, String account, int totalInst) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Outstanding Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '৳${NumberFormat('#,##,###').format(balance)}',
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Loan Account', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(account, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Installments', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text('$totalInst', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search + Filter ───────────────────────────────────
  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search by installment #',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: Color(0xFF64748B)),
              SizedBox(width: 6),
              Text('Filter', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Installment Table ─────────────────────────────────
  Widget _buildInstallmentTable(List<Installments> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Row(
              children: [
                const SizedBox(width: 40),
                _headerCell('Inst.', 1.2),
                _headerCell('Due Date', 2.2),
                _headerCell('Amount', 1.8),
                _headerCell('Status', 1.8),
                _headerCell('Action', 1.5),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSelected = _selectedInstallmentIds.contains(item.id);
              final isPaid = item.status?.toUpperCase() == 'PAID';
              final amount = double.tryParse(item.totalDue ?? '0') ?? 0;
              final dueDate = DateTime.tryParse(item.dueDate ?? '');
              final isOverdue = dueDate != null && dueDate.isBefore(DateTime.now()) && !isPaid;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: isSelected,
                        activeColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                        onChanged: isPaid
                            ? null
                            : (v) {
                          setState(() {
                            if (v == true) {
                              _selectedInstallmentIds.add(item.id!);
                            } else {
                              _selectedInstallmentIds.remove(item.id);
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 12,
                      child: Text(
                        '#${(item.installmentNumber ?? 0).toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 22,
                      child: Text(
                        _formatDate(item.dueDate),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 18,
                      child: Text(
                        '৳${NumberFormat('#,##,###').format(amount)}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 18,
                      child: _buildStatusBadge(item.status, isOverdue),
                    ),
                    Expanded(
                      flex: 15,
                      child: Center(
                        child: isPaid
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 22)
                            : SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: () {
                              _goToProceedToPay([item]);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: Size.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('Pay', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, double flex) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildStatusBadge(String? status, bool isOverdue) {
    final isPaid = status?.toUpperCase() == 'PAID';
    final isDue = isOverdue || status?.toUpperCase() == 'PENDING';

    Color bg;
    Color text;
    String label;

    if (isPaid) {
      bg = const Color(0xFFDCFCE7);
      text = const Color(0xFF16A34A);
      label = 'Paid';
    } else if (isDue) {
      bg = const Color(0xFFFEE2E2);
      text = const Color(0xFFEF4444);
      label = 'Due';
    } else {
      bg = const Color(0xFFFFF7ED);
      text = const Color(0xFFF97316);
      label = 'Upcoming';
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text)),
      ),
    );
  }

  // ── Bottom Pay Bar ────────────────────────────────────
  Widget _buildBottomPayBar(int count, double amount, List<Installments> selectedItems, String loanAccount, CustomerHomeViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text('$count Installments', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Amount', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  Text(
                    '৳${NumberFormat('#,##,###').format(amount)}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.primaryBlue),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => _goToProceedToPay(selectedItems, loanAccount: loanAccount),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Proceed to Pay (৳${NumberFormat('#,##,###').format(amount)})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dynamic Customer Name Logic ───────────────────────
  void _goToProceedToPay(List<Installments> selectedItems, {String loanAccount = 'N/A'}) {
    Navigator.pushNamed(
      context,
      RouteName.proceedToPayScreen,
      arguments: {
        'selectedItems': selectedItems,
        'loanAccount': loanAccount,
        'customerName': 'John Doe', // চাইলে profile থেকে নাও
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HISTORY TAB
  // ═══════════════════════════════════════════════════════════
  Widget _buildHistorySection(CustomerPaymentHistoryViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
    }
    if (vm.paymentList.isEmpty) {
      return const Center(child: Text('No payment history found.', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () => vm.fetchPaymentHistory(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vm.paymentList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final payment = vm.paymentList[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.check, color: Color(0xFF16A34A), size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(payment.displayId ?? 'Payment', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('via ${payment.paymentMethod}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Text(
                  '৳${payment.amount}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return dateStr;
    }
  }
}