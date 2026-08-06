import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/core/routes/Routes_name.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/sales_dashboard_model.dart';
import '../ViewModel/SalesDashboardViewModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppStorage _appStorage = AppStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesDashboardViewModel>(context, listen: false)
          .fetchSalesDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: Consumer<SalesDashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
                    const SizedBox(height: 12),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.black, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                      onPressed: () => viewModel.fetchSalesDashboard(),
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = viewModel.dashboardData;

          // ── Stats calculate from model ──
          final int totalCustomers = data?.customers ?? 0;
          final loans = data?.loans ?? [];
          final applications = data?.applications ?? [];
          final payments = data?.payments ?? [];

          // 🔹 লজিক আপডেট: APPROVED, ACTIVE, এবং DISBURSED সবগুলোকে Active Loan হিসেবে গণনা করা হচ্ছে
          final int activeLoansCount = loans
              .where((l) {
                final status = (l.status ?? '').toUpperCase();
                return status == 'ACTIVE' || status == 'DISBURSED' || status == 'APPROVED';
              })
              .length;

          final int overdueLoansCount = loans.where((l) {
            if (l.installments == null) return false;
            return l.installments!.any((i) =>
            (i.status ?? '').toUpperCase() == 'PENDING' &&
                i.dueDate != null &&
                DateTime.tryParse(i.dueDate!)?.isBefore(DateTime.now()) == true);
          }).length;

          final int pendingAppsCount = applications
              .where((a) => (a.status ?? '').toUpperCase() == 'PENDING')
              .length;

          // Total collection (simple sum if payment objects have amount)
          num totalCollections = 0;
          for (var p in payments) {
            if (p is Map && p['amount'] != null) {
              totalCollections += num.tryParse(p['amount'].toString()) ?? 0;
            }
          }

          return Stack(
            children: [
              // Top Blue Background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),

              SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await viewModel.fetchSalesDashboard();
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(pendingAppsCount),
                        Transform.translate(
                          offset: const Offset(0, -24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildPortfolioCard(
                                  totalCustomers: totalCustomers,
                                  totalCollections: totalCollections,
                                  activeLoans: activeLoansCount,
                                ),
                                const SizedBox(height: 14),
                                _buildStatusGrid(
                                  totalCustomers: totalCustomers,
                                  overdueLoans: overdueLoansCount,
                                  activeLoans: activeLoansCount,
                                  pendingApps: pendingAppsCount,
                                ),
                                const SizedBox(height: 14),
                                _buildCreateCustomerButton(),
                                const SizedBox(height: 20),
                                _buildQuickActions(),
                                const SizedBox(height: 20),
                                _buildRecentApplications(applications),
                                const SizedBox(height: 20),
                                _buildRecentLoans(loans),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteName.brandSelectionScreen);
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── Header ────────────────────────────────────────────
  Widget _buildHeader(int pendingCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/icons/logo.png',
                height: 50,
                errorBuilder: (context, error, stackTrace) =>
                const Text('SMART PAY',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ),
              Row(
                children: [
                  // GestureDetector(
                  //   onTap: () => Navigator.pushNamed(context, RouteName.customerNotificationScreen),
                  //   child: Stack(
                  //     children: [
                  //       Container(
                  //         width: 42,
                  //         height: 42,
                  //         decoration: BoxDecoration(
                  //           color: Colors.white.withValues(alpha: 0.18),
                  //           shape: BoxShape.circle,
                  //         ),
                  //         child: const Icon(Icons.notifications_outlined,
                  //             color: Colors.white, size: 22),
                  //       ),
                  //       if (pendingCount > 0)
                  //         Positioned(
                  //           right: 6,
                  //           top: 6,
                  //           child: Container(
                  //             width: 16,
                  //             height: 16,
                  //             decoration: const BoxDecoration(
                  //                 color: AppColors.errorRed, shape: BoxShape.circle),
                  //             child: Center(
                  //               child: Text(
                  //                 '$pendingCount',
                  //                 style: const TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 9,
                  //                     fontWeight: FontWeight.bold),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, RouteName.profileScreen),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Welcome back,',
            style: TextStyle(
                color: Color(0xFFBFD4FF),
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 4),
          FutureBuilder<String?>(
            future: _appStorage.getUserName(),
            builder: (context, snapshot) {
              final userName = snapshot.data ?? 'Sales Manager';
              return Row(
                children: [
                  Flexible(
                    child: Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Portfolio Card ────────────────────────────────────
  Widget _buildPortfolioCard({
    required int totalCustomers,
    required num totalCollections,
    required int activeLoans,
  }) {
    double progressRatio = totalCustomers > 0
        ? (activeLoans / totalCustomers).clamp(0.0, 1.0)
        : 0.0;
    int percentage = (progressRatio * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio Overview',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.bgGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('This Month',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.greyText,
                            fontWeight: FontWeight.w500)),
                    SizedBox(width: 3),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16, color: AppColors.greyText),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.infoBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.people_alt_outlined,
                    color: AppColors.primaryBlue, size: 26),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalCustomers',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                        height: 1),
                  ),
                  const SizedBox(height: 2),
                  const Text('Total Customers',
                      style:
                      TextStyle(fontSize: 11, color: AppColors.greyText)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Collection",
                      style:
                      TextStyle(fontSize: 11, color: AppColors.greyText)),
                  const SizedBox(height: 2),
                  Text(
                    '৳$totalCollections',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 50,
                height: 50,
                child: CustomPaint(
                  painter: _DonutPainter(progressRatio),
                  child: Center(
                    child: Text(
                      '$percentage%',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 7,
              backgroundColor: AppColors.borderGrey,
              valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Grid ───────────────────────────────────────
  Widget _buildStatusGrid({
    required int totalCustomers,
    required int overdueLoans,
    required int activeLoans,
    required int pendingApps,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.3,
      children: [
        _buildStatusCard(
          icon: Icons.account_balance_wallet_rounded,
          iconBg: AppColors.infoBlue,
          iconColor: AppColors.primaryBlue,
          title: 'Total Customers',
          count: '$totalCustomers',
          subtitle: 'Active',
          onTap: () => Navigator.pushNamed(context, RouteName.totalCustomerScreen),
        ),
        _buildStatusCard(
          icon: Icons.warning_amber_rounded,
          iconBg: const Color(0xFFFEF2F2),
          iconColor: AppColors.errorRed,
          title: 'Over Dues',
          count: '$overdueLoans',
          subtitle: 'Loans',
          onTap: () => Navigator.pushNamed(context, RouteName.overdueLoanScreen),
        ),
        _buildStatusCard(
          icon: Icons.description_outlined,
          iconBg: AppColors.successBg,
          iconColor: AppColors.successGreen,
          title: 'Active Loans',
          count: '$activeLoans',
          subtitle: 'Loans',
          onTap: () => Navigator.pushNamed(context, RouteName.activeLoanScreen),
        ),
        _buildStatusCard(
          icon: Icons.assignment_outlined,
          iconBg: const Color(0xFFFFF7ED),
          iconColor: Colors.orange,
          title: 'Pending Approval',
          count: '$pendingApps',
          subtitle: 'Apps',
          onTap: () => Navigator.pushNamed(context, RouteName.pendingApprovalScreen),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String count,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration:
              BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: iconColor),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        count,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.greyText),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: iconColor, size: 18),
          ],
        ),
      ),
    );
  }

  // ── Create Customer Button ────────────────────────────
  Widget _buildCreateCustomerButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteName.brandSelectionScreen);
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 32,
              height: 32,
              decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Create New Customer',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQABtn(
              Icons.smartphone_outlined,
              'New Loan',
              () => Navigator.pushNamed(context, RouteName.brandSelectionScreen),
            ),
            _buildQABtn(
              Icons.payments_outlined,
              'Receive\nPayment',
              () => Navigator.pushNamed(context, RouteName.activeLoanScreen),
            ),
            _buildQABtn(
              Icons.article_outlined,
              'Applications',
              () => Navigator.pushNamed(context, RouteName.pendingApprovalScreen),
            ),
            _buildQABtn(
              Icons.person_add_alt_1_outlined,
              'Create\nCustomer',
              () => Navigator.pushNamed(context, RouteName.brandSelectionScreen),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQABtn(IconData icon, String label, VoidCallback onTap) {
    final double size = (MediaQuery.of(context).size.width - 80) / 4;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size + 8,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 26),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  height: 1.15),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent Applications ───────────────────────────────
  Widget _buildRecentApplications(List<Applications> apps) {
    final recent = apps.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Applications',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black),
        ),
        const SizedBox(height: 12),
        recent.isEmpty
            ? _buildEmptyBox('No Recent Applications')
            : Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Column(
            children: List.generate(recent.length, (index) {
              final app = recent[index];
              final name = app.name ?? app.customer?.name ?? 'Unknown';
              final status = app.status ?? 'PENDING';
              final isPending = status.toUpperCase() == 'PENDING';

              return _buildListTile(
                initials: name.isNotEmpty ? name[0].toUpperCase() : 'C',
                title: name,
                subtitle: 'MRP: ৳${app.mrp ?? 0} • ${app.planMonths ?? 0} mo',
                badgeText: status,
                badgeBg: isPending
                    ? const Color(0xFFFFF7ED)
                    : AppColors.successBg,
                badgeColor:
                isPending ? Colors.orange : AppColors.successGreen,
                isLast: index == recent.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Recent Loans ──────────────────────────────────────
  Widget _buildRecentLoans(List<Loans> loans) {
    final recent = loans.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Loans',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black),
        ),
        const SizedBox(height: 12),
        recent.isEmpty
            ? _buildEmptyBox('No Recent Loans')
            : Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Column(
            children: List.generate(recent.length, (index) {
              final loan = recent[index];
              final name = loan.customer?.name ?? 'Customer';
              final status = loan.status ?? 'N/A';
              final emi = loan.calculationSnapshot?.monthlyEmi ?? '0';

              return _buildListTile(
                initials: name.isNotEmpty ? name[0].toUpperCase() : 'L',
                title: name,
                subtitle: 'EMI: ৳$emi/mo • ${loan.displayId ?? ''}',
                badgeText: status,
                badgeBg: AppColors.infoBlue,
                badgeColor: AppColors.primaryBlue,
                isLast: index == recent.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── List Tile ─────────────────────────────────────────
  Widget _buildListTile({
    required String initials,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.infoBlue,
                child: Text(
                  initials,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: badgeBg, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  badgeText,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeColor),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 1, color: AppColors.borderGrey),
      ],
    );
  }

  Widget _buildEmptyBox(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Center(
        child: Text(message,
            style: const TextStyle(color: AppColors.greyText, fontSize: 13)),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double progress;
  _DonutPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    const stroke = 5.5;

    final bgPaint = Paint()
      ..color = AppColors.borderGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
