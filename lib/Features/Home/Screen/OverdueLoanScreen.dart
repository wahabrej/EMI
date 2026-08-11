import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/routes/Routes_name.dart';
import '../ViewModel/SalesDashboardViewModel.dart';

class OverdueLoanScreen extends StatefulWidget {
  const OverdueLoanScreen({super.key});

  @override
  State<OverdueLoanScreen> createState() => _OverdueLoanScreenState();
}

class _OverdueLoanScreenState extends State<OverdueLoanScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<SalesDashboardViewModel>(
        builder: (context, viewModel, child) {
          // Filtering overdue loans
          var overdueLoans =
              viewModel.dashboardData?.loans?.where((l) {
                if (l.installments == null) return false;
                return l.installments!.any(
                  (i) =>
                      (i.status ?? '').toUpperCase() == 'PENDING' &&
                      i.dueDate != null &&
                      DateTime.tryParse(i.dueDate!)?.isBefore(DateTime.now()) ==
                          true,
                );
              }).toList() ??
              [];

          // Search filter
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            overdueLoans = overdueLoans.where((l) {
              return (l.customer?.name?.toLowerCase().contains(q) ?? false) ||
                  (l.customer?.phone?.toLowerCase().contains(q) ?? false) ||
                  (l.displayId?.toLowerCase().contains(q) ?? false);
            }).toList();
          }

          // Filter by days
          if (_selectedFilter != 'All') {
            overdueLoans = overdueLoans.where((loan) {
              int maxDays = 0;
              for (var inst in (loan.installments ?? [])) {
                if ((inst.status ?? '').toUpperCase() == 'PENDING' &&
                    inst.dueDate != null) {
                  final dt = DateTime.tryParse(inst.dueDate!);
                  if (dt != null && dt.isBefore(DateTime.now())) {
                    final days = DateTime.now().difference(dt).inDays;
                    if (days > maxDays) maxDays = days;
                  }
                }
              }

              switch (_selectedFilter) {
                case 'Today':
                  return maxDays == 0;
                case '1-7 Days':
                  return maxDays >= 1 && maxDays <= 7;
                case '8-30 Days':
                  return maxDays >= 8 && maxDays <= 30;
                case '30+ Days':
                  return maxDays > 30;
                default:
                  return true;
              }
            }).toList();
          }

          // Metrics calculation
          double totalOverdueAmount = 0;
          int dueTodayCount = 0;

          for (var loan in overdueLoans) {
            for (var inst in (loan.installments ?? [])) {
              if ((inst.status ?? '').toUpperCase() == 'PENDING' &&
                  inst.dueDate != null) {
                final dueDate = DateTime.tryParse(inst.dueDate!);
                if (dueDate != null && dueDate.isBefore(DateTime.now())) {
                  totalOverdueAmount +=
                      double.tryParse(inst.totalDue ?? '0') ?? 0;
                  if (DateUtils.isSameDay(dueDate, DateTime.now())) {
                    dueTodayCount++;
                  }
                }
              }
            }
          }

          return SafeArea(
            top: false,
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // Filter Chips
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildFilterChips(),
                        ),

                        const SizedBox(height: 16),

                        // Metrics
                        _buildMetricsSection(
                          totalLoans: overdueLoans.length,
                          dueToday: dueTodayCount,
                          totalAmount: totalOverdueAmount,
                          currency: currency,
                        ),

                        const SizedBox(height: 16),

                        // Loan List
                        if (overdueLoans.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: _buildEmptyState('No overdue loans found'),
                          )
                        else
                          ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: overdueLoans.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildOverdueCard(
                                  overdueLoans[index],
                                  currency,
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, RouteName.brandSelectionScreen);

        },
        backgroundColor: const Color(0xFF0052CC),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(Icons.add, color: Colors.white, size: 22),
        label: const Text(
          'Add Collection',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ───────────────────── HEADER ─────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0052CC),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Title Row
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Expanded(
                child: Text(
                  'Over Dues',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      RouteName.sellerNotificationScreen,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Search + Filter
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText:
                                'Search by customer name, phone or Loan ID...',
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF0052CC),
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Filter',
                      style: TextStyle(
                        color: Color(0xFF0052CC),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────── FILTER CHIPS ─────────────────────
  Widget _buildFilterChips() {
    final filters = ['All', 'Today', '1-7 Days', '8-30 Days', '30+ Days'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0052CC) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0052CC)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            );
          }),

          // Branch dropdown style chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: const [
                Text(
                  'Branch',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────── METRICS ─────────────────────
  Widget _buildMetricsSection({
    required int totalLoans,
    required int dueToday,
    required double totalAmount,
    required NumberFormat currency,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _metricCard(
              title: 'Total Overdue Loans',
              value: '$totalLoans',
              subtitle: 'Loans',
              icon: Icons.warning_amber_rounded,
              iconBg: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFEF4444),
              valueColor: const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _metricCard(
              title: 'Due Today',
              value: '$dueToday',
              subtitle: 'Loans',
              icon: Icons.calendar_today_outlined,
              iconBg: const Color(0xFFFFF7ED),
              iconColor: const Color(0xFFF59E0B),
              valueColor: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _metricCard(
              title: 'Due Amount',
              value: '৳${currency.format(totalAmount)}',
              subtitle: '',
              icon: Icons.currency_rupee_rounded,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF0052CC),
              valueColor: const Color(0xFF0052CC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: valueColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────── OVERDUE CARD ─────────────────────
  Widget _buildOverdueCard(dynamic loan, NumberFormat currency) {
    final customer = loan.customer;
    final name = customer?.name ?? 'Unknown Customer';
    final phone = customer?.phone ?? 'N/A';
    final loanId = loan.displayId ?? 'LN-000000';
    final device =
        loan.productModel?.name ?? loan.product?.name ?? 'Device Loan';
    final emiAmt =
        double.tryParse(loan.calculationSnapshot?.monthlyEmi ?? '0') ?? 0;

    double outstandingDue = 0;
    int overdueDays = 0;
    String dueDateFormatted = 'N/A';

    if (loan.installments != null) {
      for (var inst in loan.installments) {
        if ((inst.status ?? '').toUpperCase() == 'PENDING' &&
            inst.dueDate != null) {
          final dt = DateTime.tryParse(inst.dueDate!);
          if (dt != null) {
            outstandingDue += double.tryParse(inst.totalDue ?? '0') ?? 0;
            dueDateFormatted = DateFormat('dd MMM yyyy').format(dt);
            if (dt.isBefore(DateTime.now())) {
              final days = DateTime.now().difference(dt).inDays;
              if (days > overdueDays) overdueDays = days;
            }
          }
        }
      }
    }

    final isCritical = overdueDays >= 30;
    final isHigh = overdueDays >= 8;
    final tagBg = isCritical
        ? const Color(0xFFFEF2F2)
        : isHigh
        ? const Color(0xFFFFF7ED)
        : const Color(0xFFFFFBEB);
    final tagColor = isCritical
        ? const Color(0xFFEF4444)
        : isHigh
        ? const Color(0xFFF59E0B)
        : const Color(0xFFD97706);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top content
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'C',
                    style: const TextStyle(
                      color: Color(0xFF0052CC),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Left info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Days tag
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: tagBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$overdueDays Days',
                              style: TextStyle(
                                color: tagColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _infoRow(
                        'Loan ID',
                        loanId,
                        valueColor: const Color(0xFF0052CC),
                      ),
                      const SizedBox(height: 3),
                      _infoRow('Phone', phone),
                      const SizedBox(height: 3),
                      _infoRow('Device', device),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right financial info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Outstanding',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '৳${currency.format(outstandingDue)}',
                      style: TextStyle(
                        color: isCritical
                            ? const Color(0xFFEF4444)
                            : const Color(0xFFF59E0B),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'EMI Amount',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '৳${currency.format(emiAmt)}',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Due Date',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      dueDateFormatted,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Expanded(child: _outlineBtn(Icons.phone_rounded, 'Call')),
                const SizedBox(width: 8),
                Expanded(
                  child: _outlineBtn(Icons.chat_bubble_outline_rounded, 'SMS'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: isCritical
                      ? _outlineBtn(
                          Icons.lock_outline_rounded,
                          'Lock Device',
                          color: const Color(0xFFEF4444),
                        )
                      : _outlineBtn(Icons.near_me_outlined, 'Navigate'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 15,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Receive Payment',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0052CC),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _infoRow(
    String label,
    String value, {
    Color valueColor = const Color(0xFF1E293B),
  }) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label  ',
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _outlineBtn(
    IconData icon,
    String label, {
    Color color = const Color(0xFF0052CC),
  }) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        side: BorderSide(color: color.withOpacity(0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        foregroundColor: color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: Colors.green.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
