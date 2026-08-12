import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/routes/Routes_name.dart';
import '../ViewModel/SalesDashboardViewModel.dart';

class ActiveLoanScreen extends StatefulWidget {
  const ActiveLoanScreen({super.key});

  @override
  State<ActiveLoanScreen> createState() => _ActiveLoanScreenState();
}

class _ActiveLoanScreenState extends State<ActiveLoanScreen> {
  String _selectedFilter = 'All';
  String _sortBy = 'Newest';
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<SalesDashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0052CC)),
            );
          }

          // ── Data Filtering Logic ──
          var loans = viewModel.dashboardData?.loans?.where((l) {
            final status = (l.status ?? '').toUpperCase();
            final matchesStatus = status == 'ACTIVE' ||
                status == 'DISBURSED' ||
                status == 'APPROVED';

            final query = _searchQuery.toLowerCase();
            final matchesSearch = query.isEmpty ||
                (l.customer?.name?.toLowerCase().contains(query) ?? false) ||
                (l.customer?.phone?.toLowerCase().contains(query) ?? false) ||
                (l.displayId?.toLowerCase().contains(query) ?? false);

            return matchesStatus && matchesSearch;
          }).toList() ??
              [];

          // ── Filter Logic ──
          if (_selectedFilter == 'My Customers') {
            // Add your specific logic here if needed
          } else if (_selectedFilter == 'This Month') {
            final now = DateTime.now();
            loans = loans.where((loan) {
              if (loan.installments != null) {
                for (var inst in loan.installments!) {
                  if (inst.dueDate != null) {
                    try {
                      final date = DateTime.parse(inst.dueDate!);
                      if (date.month == now.month && date.year == now.year) {
                        return true;
                      }
                    } catch (_) {}
                  }
                }
              }
              return false;
            }).toList();
          }

          // ── Sort Logic ──
          if (_sortBy == 'Newest') {
            loans.sort((a, b) =>
                (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
          } else if (_sortBy == 'Oldest') {
            loans.sort((a, b) =>
                (a.createdAt ?? '').compareTo(b.createdAt ?? ''));
          } else if (_sortBy == 'Amount') {
            loans.sort((a, b) {
              final aAmt = double.tryParse(
                  a.calculationSnapshot?.regularPrice ?? '0') ?? 0;
              final bAmt = double.tryParse(
                  b.calculationSnapshot?.regularPrice ?? '0') ?? 0;
              return bAmt.compareTo(aAmt);
            });
          }

          // ── Aggregate Metrics ──
          double totalOutstanding = 0;
          double emiDueThisMonth = 0;
          final now = DateTime.now();
          final Set<String> activeCustomers = {};

          for (var loan in loans) {
            if (loan.customer?.id != null) activeCustomers.add(
                loan.customer!.id!);

            if (loan.installments != null) {
              for (var inst in loan.installments!) {
                if ((inst.status ?? "").toUpperCase() == 'PENDING') {
                  double due = double.tryParse(inst.totalDue ?? "0") ?? 0;
                  totalOutstanding += due;

                  if (inst.dueDate != null) {
                    try {
                      final date = DateTime.parse(inst.dueDate!);
                      if (date.month == now.month && date.year == now.year) {
                        emiDueThisMonth += due;
                      }
                    } catch (_) {}
                  }
                }
              }
            }
          }

          return SafeArea(
            top: false,
            child: Column(
              children: [
                // 1. Header
                _buildHeader(context),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // 2. Metrics
                        _buildMetricsSection(
                          activeLoans: loans.length,
                          outstanding: totalOutstanding,
                          dueThisMonth: emiDueThisMonth,
                          customers: activeCustomers.length,
                          currency: currency,
                        ),

                        const SizedBox(height: 20),

                        // 3. Filter + Sort
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildFilterAndSortSection(),
                        ),

                        const SizedBox(height: 16),

                        // 4. Loan List
                        if (loans.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: _buildEmptyState('No active loans found'),
                          )
                        else
                          ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: loans.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildLoanCard(loans[index], currency),
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

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, RouteName.brandSelectionScreen);
        },
        backgroundColor: const Color(0xFF0052CC),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(Icons.add, color: Colors.white, size: 24),
        label: const Text(
          'New Loan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          // Top Bar
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              const Expanded(
                child: Text(
                  'Active Loans',
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
                    child: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white, size: 28),
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
                      const Icon(Icons.search_rounded,
                          color: Color(0xFF94A3B8), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Search by customer name, phone or Loan ID...',
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
                        Icons.tune_rounded, color: Color(0xFF0052CC), size: 20),
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

  // ───────────────────── METRICS ─────────────────────
  Widget _buildMetricsSection({
    required int activeLoans,
    required double outstanding,
    required double dueThisMonth,
    required int customers,
    required NumberFormat currency,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _metricCard(
            title: 'Total Active\nLoans',
            value: '$activeLoans',
            subtitle: 'Loans',
            icon: Icons.account_balance_wallet_outlined,
            bgColor: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 12),
          _metricCard(
            title: 'Total\nOutstanding',
            value: '৳${currency.format(outstanding)}',
            subtitle: '',
            icon: Icons.currency_exchange_rounded,
            bgColor: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF10B981),
            valueColor: const Color(0xFF10B981),
          ),
          const SizedBox(width: 12),
          _metricCard(
            title: 'EMI Due This\nMonth',
            value: '৳${currency.format(dueThisMonth)}',
            subtitle: '',
            icon: Icons.calendar_today_outlined,
            bgColor: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFF59E0B),
            valueColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 12),
          _metricCard(
            title: 'Active\nCustomers',
            value: '$customers',
            subtitle: '',
            icon: Icons.people_outline_rounded,
            bgColor: const Color(0xFFF5F3FF),
            iconColor: const Color(0xFF8B5CF6),
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
    required Color bgColor,
    required Color iconColor,
    Color? valueColor,
  }) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  // ───────────────────── FILTER + SORT ─────────────────────
  Widget _buildFilterAndSortSection() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'My Customers', 'This Month'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0052CC) : Colors
                          .white,
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
                        color: isSelected ? Colors.white : const Color(
                            0xFF64748B),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight
                            .w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            const Text(
              'Sort by ',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isDense: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF0052CC),
                ),
                style: const TextStyle(
                  color: Color(0xFF0052CC),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                onChanged: (String? newValue) {
                  setState(() => _sortBy = newValue!);
                },
                items: ['Newest', 'Oldest', 'Amount']
                    .map((value) =>
                    DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────── LOAN CARD ─────────────────────
  Widget _buildLoanCard(dynamic loan, NumberFormat currency) {
    final customer = loan.customer;
    final name = customer?.name ?? 'Customer Name';
    final phone = customer?.phone ?? 'N/A';
    final loanId = loan.displayId ?? 'LN-000000';
    final productName = loan.productModel?.name ?? loan.product?.name ??
        'Smartphone Loan';
    final loanAmt = double.tryParse(
        loan.calculationSnapshot?.regularPrice ?? '0') ?? 0;
    final emiAmt = double.tryParse(
        loan.calculationSnapshot?.monthlyEmi ?? '0') ?? 0;
    final tenure = loan.calculationSnapshot?.planMonths ?? 12;

    double outstanding = 0;
    String nextDueDate = 'N/A';

    if (loan.installments != null) {
      for (var inst in loan.installments!) {
        if ((inst.status ?? "").toUpperCase() == 'PENDING') {
          outstanding += double.tryParse(inst.totalDue ?? "0") ?? 0;
          if (nextDueDate == 'N/A' && inst.dueDate != null) {
            try {
              nextDueDate = DateFormat('dd MMM yyyy').format(
                  DateTime.parse(inst.dueDate!));
            } catch (_) {}
          }
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top Section ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
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

                // Customer Info
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                              Icons.phone_rounded, size: 13, color: Color(
                              0xFF64748B)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              phone,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Loan ID  ',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: loanId,
                              style: const TextStyle(
                                color: Color(0xFF0052CC),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Product  ',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: productName,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Middle amounts
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Loan Amount',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '৳${currency.format(loanAmt)}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'EMI Amount',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '৳${currency.format(emiAmt)}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tenure',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$tenure Months',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right side: Active + Outstanding + Next Due
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Color(0xFF16A34A),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Outstanding',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '৳${currency.format(outstanding)}',
                      style: const TextStyle(
                        color: Color(0xFF16A34A),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Next EMI Due',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      nextDueDate,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Bottom Action Buttons ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9)),
              ),
            ),
            child: Row(
              children: [
                // View Details
                Expanded(
                  child: _actionButton(
                    Icons.description_outlined,
                    'View Details',
                    onTap: () => _navigateToLoanDetails(loan),
                  ),
                ),
            //    Payment History
                Expanded(
                  child: _actionButton(
                    Icons.history_rounded,
                    'Payment History',
                    onTap: () {
                     Navigator.pushNamed(context, RouteName.paymentScreen);
                    },
                  ),
                ),
                // Collect Payment
                Expanded(
                  child: _actionButton(
                    Icons.lock_outline_rounded,
                    'Collect Payment',
                    isGreen: true,
                    onTap: () {
                      debugPrint('═══════════════════════════════════════════════════');
                      debugPrint('💰 [Collect Payment] ========== BUTTON CLICKED ==========');
                      debugPrint('💰 [Collect Payment] Loan ID: ${loan.id}');
                      debugPrint('💰 [Collect Payment] Loan Display ID: ${loan.displayId}');
                      debugPrint('💰 [Collect Payment] Customer Name: ${loan.customer?.name}');
                      debugPrint('💰 [Collect Payment] Customer Phone: ${loan.customer?.phone}');

                      // ─── Navigate to Single Loan Detail Screen ───
                      if (loan.id != null && loan.id.toString().isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          RouteName.singleLoanDetailScreen,
                          arguments: loan.id.toString(),
                        );
                        debugPrint('✅ Navigation to SingleLoanDetailScreen with ID: ${loan.id}');
                      } else {
                        debugPrint('❌ Loan ID is null or empty');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid Loan ID'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      debugPrint('═══════════════════════════════════════════════════');
                    },
                  ),
                ),
                // // Contact
                Expanded(
                  child: _actionButton(
                    Icons.phone_in_talk_outlined,
                    'Contact',
                    onTap: () {
                      debugPrint('📞 Contact clicked for loan: ${loan.id}');
                      _makePhoneCall(phone);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Navigation Method ───
// ActiveLoanScreen.dart

  void _navigateToLoanDetails(dynamic loan) {
    debugPrint('🚀 [ActiveLoanScreen] View Details Clicked');
    debugPrint('🆔 Loan ID: ${loan.id}');
    debugPrint('📋 Customer: ${loan.customer?.name}');
    debugPrint('📋 Loan Display ID: ${loan.displayId}');

    if (loan.id == null || loan.id.toString().isEmpty) {
      debugPrint('⚠️ Loan ID is null or empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Loan ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final loanId = loan.id.toString();
      debugPrint('📤 Sending loanId: $loanId');

      // 🔥 LoanApplicationDetailsScreen এ loanId পাঠান
      Navigator.pushNamed(
        context,
        RouteName.loanApplicationDetailsScreen,
        arguments: loanId,
      ).then((result) {
        debugPrint('✅ Navigation completed. Result: $result');
      }).catchError((error) {
        debugPrint('❌ Navigation error: $error');
        _showErrorDialog('Navigation Error', error.toString());
      });

      debugPrint('✅ Navigation command sent successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Navigation Exception: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      _showErrorDialog('Error', 'Could not open loan details: $e');
    }
  }
  // ─── Coming Soon Dialog ───
  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature will be available soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ─── Make Phone Call ───
  void _makePhoneCall(String phoneNumber) {
    if (phoneNumber == 'N/A' || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    debugPrint('📞 Making call to: $phoneNumber');
    // TODO: Implement phone call functionality
    // Use url_launcher package
    // launchUrl(Uri.parse('tel:$phoneNumber'));
  }

  // ─── Error Dialog ───
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      IconData icon,
      String label, {
        bool isGreen = false,
        VoidCallback? onTap,
      }) {
    final color = isGreen ? const Color(0xFF16A34A) : const Color(0xFF0052CC);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey.shade300),
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