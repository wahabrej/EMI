import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/constant/Api_End_point.dart';
import '../ViewModel/CustomerDetailViewModel.dart';
class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailsScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}
class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerDetailViewModel>().fetchCustomerDetail(
        widget.customerId,
      );
    });
  }

  void _makePhoneCall(String phoneNumber) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      await launchUrl(phoneUri);
    } catch (e) {
      print('Call error: $e');
    }
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.black,
            size: 20,
          ),
        ),
        title: const Text(
          'Customer Details',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<CustomerDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0052CC)),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final customer = viewModel.customerDetail;
          if (customer == null)
            return const Center(child: Text("No details found"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(customer),
                const SizedBox(height: 24),

                _sectionHeader("Personal Information"),
                _buildInfoCard([
                  _infoRow("Full Name", customer.name ?? 'N/A'),
                  _infoRow(
                    "Phone",
                    customer.phone ?? 'N/A',
                    isPhone: true,
                  ), // ← isPhone: true যোগ করুন
                  _infoRow("Email", customer.email ?? 'N/A'),
                  _infoRow("NID/Passport", customer.nidPassportNumber ?? 'N/A'),
                  _infoRow(
                    "Source of Income",
                    customer.sourceOfIncome ?? 'N/A',
                  ),
                  _infoRow(
                    "Monthly Income",
                    "৳${currency.format(customer.monthlyIncome ?? 0)}",
                  ),
                  _infoRow("Present Address", customer.presentAddress ?? 'N/A'),
                  _infoRow(
                    "Permanent Address",
                    customer.permanentAddress ?? 'N/A',
                  ),
                ]),

                const SizedBox(height: 24),
                _sectionHeader("Documents"),
                _buildDocumentSection(customer),

                if (customer.activeLoans != null &&
                    customer.activeLoans!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionHeader("Active Loans"),
                  ...customer.activeLoans!
                      .map((loan) => _buildLoanCard(loan, currency))
                      .toList(),
                ],

                if (customer.guarantors != null &&
                    customer.guarantors!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionHeader("Guarantor Details"),
                  ...customer.guarantors!
                      .map((g) => _buildGuarantorCard(g))
                      .toList(),
                ],

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic customer) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFEFF6FF),
            backgroundImage: customer.profileImage != null
                ? NetworkImage(ApiEndPoint.assetUrl(customer.profileImage!))
                : null,
            child: customer.profileImage == null
                ? Text(
                    customer.name?[0].toUpperCase() ?? 'C',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0052CC),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "ID: ${customer.displayId ?? 'N/A'}",
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    customer.status ?? 'ACTIVE',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String value, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                // 🔥 Call Now বাটন - সব নম্বরের জন্য দেখাবে
                if (isPhone && value.isNotEmpty && value != 'N/A')
                  GestureDetector(
                    onTap: () => _makePhoneCall(value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0052CC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Call Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildDocumentSection(dynamic customer) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (customer.nidFront != null)
            _docThumbnail("NID Front", customer.nidFront),
          if (customer.nidBack != null)
            _docThumbnail("NID Back", customer.nidBack),
          if (customer.incomeProof != null)
            _docThumbnail("Income Proof", customer.incomeProof),
        ],
      ),
    );
  }

  Widget _docThumbnail(String label, String? url) {
    if (url == null) return const SizedBox.shrink();
    final fullUrl = ApiEndPoint.assetUrl(url);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 100,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              fullUrl,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                width: 100,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoanCard(dynamic loan, NumberFormat currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loan.productName ?? 'Unknown Loan',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                loan.status ?? '',
                style: TextStyle(
                  color: loan.status == 'ACTIVE' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
           Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _loanStat("Total", "৳${currency.format(loan.totalAmount ?? 0)}"),
              _loanStat("Paid", "৳${currency.format(loan.paidAmount ?? 0)}"),
              _loanStat(
                "Remaining",
                "৳${currency.format(loan.remainingAmount ?? 0)}",
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loanStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:  TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
         SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGuarantorCard(dynamic g) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            g.name ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            "${g.relationship} • ${g.phone}",
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (g.nidFront != null) _docThumbnail("NID Front", g.nidFront),
              if (g.nidBack != null) _docThumbnail("NID Back", g.nidBack),
            ],
          ),
        ],
      ),
    );
  }
}
