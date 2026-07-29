import 'package:flutter/material.dart';

class EmiRepaymentScheduleScreen extends StatelessWidget {
  const EmiRepaymentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'EMI Repayment Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Color(0xFF0F172A), size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Product Summary Card
            _buildProductSummaryCard(),
            const SizedBox(height: 16),

            // 2. Three Metric Cards (Monthly EMI, Total Interest, Total Payable)
            _buildMetricsCard(),
            const SizedBox(height: 24),

            // 3. Repayment Schedule Table Section
            const Text(
              'Repayment Schedule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            _buildRepaymentTable(),
            const SizedBox(height: 16),

            // 4. Auto Pay Information Banner
            _buildAutoPayBanner(),
            const SizedBox(height: 16),

            // 5. Enable Reminders Bottom Card
            _buildReminderCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔹 Product Summary Card
  Widget _buildProductSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Container
          Container(
            width: 65,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF8FAFC),
            ),
            child: Image.network(
              'https://m.media-amazon.com/images/I/61cwywLZR-L._AC_SL1500_.jpg',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.phone_iphone, size: 45, color: Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'iPhone 14 128GB',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Blue',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          'Total Payable',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '৳90,300',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Plan: 6 Months EMI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Interest 12% p.a.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Three Metric Columns Card
  Widget _buildMetricsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(
            icon: Icons.calculate_outlined,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            label: 'Monthly EMI',
            value: '৳12,550',
          ),
          Container(width: 1, height: 35, color: const Color(0xFFF1F5F9)),
          _buildMetricItem(
            icon: Icons.percent_rounded,
            iconBg: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF10B981),
            label: 'Total Interest',
            value: '৳5,300',
          ),
          Container(width: 1, height: 35, color: const Color(0xFFF1F5F9)),
          _buildMetricItem(
            icon: Icons.receipt_long_outlined,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF9333EA),
            label: 'Total Payable',
            value: '৳90,300',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🔹 Repayment Schedule Table
  Widget _buildRepaymentTable() {
    final List<Map<String, dynamic>> scheduleData = [
      {'#': '1', 'date': '15 May 2024', 'emi': '৳12,550', 'principal': '৳11,383', 'interest': '৳1,167', 'status': 'Paid'},
      {'#': '2', 'date': '15 Jun 2024', 'emi': '৳12,550', 'principal': '৳11,534', 'interest': '৳1,016', 'status': 'Paid'},
      {'#': '3', 'date': '15 Jul 2024', 'emi': '৳12,550', 'principal': '৳11,686', 'interest': '৳864', 'status': 'Paid'},
      {'#': '4', 'date': '15 Aug 2024', 'emi': '৳12,550', 'principal': '৳11,842', 'interest': '৳708', 'status': 'Upcoming'},
      {'#': '5', 'date': '15 Sep 2024', 'emi': '৳12,550', 'principal': '৳12,002', 'interest': '৳548', 'status': 'Upcoming'},
      {'#': '6', 'date': '15 Oct 2024', 'emi': '৳12,550', 'principal': '৳12,209', 'interest': '৳341', 'status': 'Upcoming'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(0.5),
            1: FlexColumnWidth(2.2),
            2: FlexColumnWidth(1.8),
            3: FlexColumnWidth(1.8),
            4: FlexColumnWidth(1.4),
            5: FlexColumnWidth(1.8),
          },
          children: [
            // Header Row
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
              children: [
                _buildTableCell('#', isHeader: true),
                _buildTableCell('Due Date', isHeader: true),
                _buildTableCell('EMI Amount', isHeader: true),
                _buildTableCell('Principal', isHeader: true),
                _buildTableCell('Interest', isHeader: true),
                _buildTableCell('Status', isHeader: true, alignment: Alignment.centerRight),
              ],
            ),
            // Data Rows
            ...scheduleData.map((row) {
              bool isPaid = row['status'] == 'Paid';
              return TableRow(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                children: [
                  _buildTableCell(row['#']!),
                  _buildTableCell(row['date']!, isBold: true),
                  _buildTableCell(row['emi']!),
                  _buildTableCell(row['principal']!),
                  _buildTableCell(row['interest']!),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                      child: Alignment(1.0, 0.0) == Alignment.centerRight
                          ? Align(
                        alignment: Alignment.centerRight,
                        child: _buildStatusBadge(isPaid),
                      )
                          : _buildStatusBadge(isPaid),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false, Alignment alignment = Alignment.centerLeft}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Align(
          alignment: alignment,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isHeader ? FontWeight.bold : (isBold ? FontWeight.bold : FontWeight.w500),
              color: isHeader ? const Color(0xFF64748B) : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isPaid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Upcoming',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isPaid ? const Color(0xFF10B981) : const Color(0xFF2563EB),
        ),
      ),
    );
  }

  // 🔹 Auto Pay Info Banner
  Widget _buildAutoPayBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'EMI will be auto-debited from your selected account.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Manage Auto Pay',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF2563EB), size: 20),
        ],
      ),
    );
  }

  // 🔹 Reminders Bottom Card
  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Never miss an EMI',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Get reminders before your due date',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF2563EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            child: const Text(
              'Enable Reminders',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}