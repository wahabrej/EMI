import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/core/routes/Routes_name.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/sales_dashboard_model.dart';
import '../ViewModel/SalesDashboardViewModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color kBlue = Color(0xFF2458E8);
  static const Color kRed = Color(0xFFEF4444);
  static const Color kGreen = Color(0xFF10B981);
  static const Color kOrange = Color(0xFFF97316);
  static const Color kTextDark = Color(0xFF0F172A);
  static const Color kTextMid = Color(0xFF475569);
  static const Color kTextLight = Color(0xFF94A3B8);
  static const Color kBorder = Color(0xFFF1F5F9);

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
      backgroundColor: const Color(0xFFF0F4FF),
      body: Consumer<SalesDashboardViewModel>(
        builder: (context, viewModel, child) {
          // 1. Loading State
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kBlue),
            );
          }

          // 2. Error State
          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: kRed),
                    const SizedBox(height: 12),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kTextDark, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: kBlue),
                      onPressed: () {
                        viewModel.fetchSalesDashboard();
                      },
                      child: const Text('Retry', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = viewModel.dashboardData;

          // 3. Success State with Dynamic Data
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
                    color: kBlue,
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
                        // Header Section
                        _buildHeader(data),

                        // Main Content
                        Transform.translate(
                          offset: const Offset(0, -24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildPortfolioCard(data?.stats),
                                const SizedBox(height: 14),
                                _buildStatusGrid(data?.stats),
                                const SizedBox(height: 14),
                                _buildCreateCustomerButton(),
                                const SizedBox(height: 20),
                                _buildQuickActions(),
                                const SizedBox(height: 20),
                                _buildRecentApplications(data?.recentApplications ?? []),
                                const SizedBox(height: 20),
                                _buildRecentPayments(data?.recentPayments ?? []),
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
        backgroundColor: kBlue,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ── HEADER SECTION ──────────────────────────────────────────────────────────
  Widget _buildHeader(Data? data) {
    final pendingCount = data?.stats?.pendingApplications ?? 0;

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
                const Text('SMART PAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                      ),
                      if (pendingCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(color: kRed, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '$pendingCount',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_outline, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getGreetingMessage(),
            style: const TextStyle(color: Color(0xFFBFD4FF), fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 4),

          // 🔹 FutureBuilder tile local storage theke User Name read korbe
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

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  // ── PORTFOLIO OVERVIEW CARD ─────────────────────────────────────────────────
  Widget _buildPortfolioCard(Stats? stats) {
    final num totalCollections = stats?.totalCollections ?? 0;
    final int totalCustomers = stats?.totalCustomers ?? 0;
    final int activeLoans = stats?.activeLoans ?? 0;

    double progressRatio = totalCustomers > 0
        ? (activeLoans / totalCustomers).clamp(0.0, 1.0)
        : 0.0;
    int percentage = (progressRatio * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kTextDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Text('This Month', style: TextStyle(fontSize: 12, color: kTextMid, fontWeight: FontWeight.w500)),
                    SizedBox(width: 3),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: kTextMid),
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
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.people_alt_outlined, color: kBlue, size: 26),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalCustomers',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kTextDark, height: 1),
                  ),
                  const SizedBox(height: 2),
                  const Text('Total Customers', style: TextStyle(fontSize: 11, color: kTextLight)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Collection", style: TextStyle(fontSize: 11, color: kTextLight)),
                  const SizedBox(height: 2),
                  Text(
                    '৳$totalCollections',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kBlue),
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
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kTextDark),
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
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(kBlue),
            ),
          ),
        ],
      ),
    );
  }

  // ── STATS GRID SECTION ──────────────────────────────────────────────────────
  Widget _buildStatusGrid(Stats? stats) {
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
          iconBg: const Color(0xFFEFF6FF),
          iconColor: kBlue,
          title: 'Total Customers',
          count: '${stats?.totalCustomers ?? 0}',
          subtitle: 'Active',
        ),
        _buildStatusCard(
          icon: Icons.warning_amber_rounded,
          iconBg: const Color(0xFFFEF2F2),
          iconColor: kRed,
          title: 'Over Dues',
          count: '${stats?.overdueLoans ?? 0}',
          subtitle: 'Loans',
        ),
        _buildStatusCard(
          icon: Icons.description_outlined,
          iconBg: const Color(0xFFECFDF5),
          iconColor: kGreen,
          title: 'Active Loans',
          count: '${stats?.activeLoans ?? 0}',
          subtitle: 'Loans',
        ),
        _buildStatusCard(
          icon: Icons.assignment_outlined,
          iconBg: const Color(0xFFFFF7ED),
          iconColor: kOrange,
          title: 'Pending Approval',
          count: '${stats?.pendingApplications ?? 0}',
          subtitle: 'Apps',
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
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
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: iconColor),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      count,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: kTextLight),
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
    );
  }

  // ── CREATE CUSTOMER BUTTON ──────────────────────────────────────────────────
  Widget _buildCreateCustomerButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RouteName.brandSelectionScreen);
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(color: kBlue, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: kBlue, size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Create New Customer',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 24),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  // ── QUICK ACTIONS ──────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextDark),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQABtn(Icons.smartphone_outlined, 'New Loan'),
            _buildQABtn(Icons.payments_outlined, 'Receive\nPayment'),
            _buildQABtn(Icons.article_outlined, 'Applications'),
            _buildQABtn(Icons.person_add_alt_1_outlined, 'Create\nCustomer'),
          ],
        ),
      ],
    );
  }

  Widget _buildQABtn(IconData icon, String label) {
    final double size = (MediaQuery.of(context).size.width - 80) / 4;
    return Container(
      width: size,
      height: size + 8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kBlue, size: 26),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextDark, height: 1.15),
          ),
        ],
      ),
    );
  }

  // ── RECENT APPLICATIONS LIST ────────────────────────────────────────────────
  Widget _buildRecentApplications(List<RecentApplications> recentApps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Applications',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextDark),
        ),
        const SizedBox(height: 12),
        recentApps.isEmpty
            ? _buildEmptyBox('No Recent Applications')
            : Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: List.generate(recentApps.length, (index) {
              final app = recentApps[index];
              final String name = app.name ?? 'Unknown Customer';
              final String status = app.status ?? 'PENDING';
              final isPending = status.toUpperCase() == 'PENDING';

              return _buildListTile(
                initials: name.isNotEmpty ? name[0].toUpperCase() : 'C',
                title: name,
                subtitle: 'EMI: ৳${app.monthlyEmi ?? 0}/mo',
                badgeText: status,
                badgeBg: isPending ? const Color(0xFFFFF7ED) : const Color(0xFFECFDF5),
                badgeColor: isPending ? kOrange : kGreen,
                isLast: index == recentApps.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── RECENT PAYMENTS LIST ────────────────────────────────────────────────────
  Widget _buildRecentPayments(List<RecentPayments> recentPayments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Payments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextDark),
        ),
        const SizedBox(height: 12),
        recentPayments.isEmpty
            ? _buildEmptyBox('No Recent Payments')
            : Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: List.generate(recentPayments.length, (index) {
              final pay = recentPayments[index];
              final String customerName = pay.loan?.customer?.name ?? 'Customer';
              final String method = pay.paymentMethod ?? 'CASH';

              return _buildListTile(
                initials: customerName.isNotEmpty ? customerName[0].toUpperCase() : 'P',
                title: customerName,
                subtitle: 'Method: $method',
                badgeText: '৳${pay.amount ?? 0}',
                badgeBg: const Color(0xFFEFF6FF),
                badgeColor: kBlue,
                isLast: index == recentPayments.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── HELPER LIST TILE ────────────────────────────────────────────────────────
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
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  initials,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kBlue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kTextDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: kTextLight),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(20)),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeColor),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, thickness: 1, color: Color(0xFFF8F8F8)),
      ],
    );
  }

  Widget _buildEmptyBox(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: kTextLight, fontSize: 13)),
      ),
    );
  }
}

// ── CUSTOM DONUT PAINTER ─────────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final double progress;
  _DonutPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    const stroke = 5.5;

    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = const Color(0xFF2458E8)
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