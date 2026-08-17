import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/routes/Routes_name.dart';
import '../ViewModel/SalesDashboardViewModel.dart';
import '../Model/sales_dashboard_model.dart';

class TotalCustomerScreen extends StatefulWidget {
  const TotalCustomerScreen({super.key});

  @override
  State<TotalCustomerScreen> createState() => _TotalCustomerScreenState();
}

class _TotalCustomerScreenState extends State<TotalCustomerScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<SalesDashboardViewModel>(
        builder: (context, viewModel, child) {
          final data = viewModel.dashboardData;

          if (data == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF0052CC)),
            );
          }

          // Extract Unique Customers
          final Map<String, Customer> uniqueCustomers = {};

          if (data.loans != null) {
            for (var loan in data.loans!) {
              if (loan.customer != null && loan.customer!.id != null) {
                uniqueCustomers[loan.customer!.id!] = loan.customer!;
              }
            }
          }

          if (data.applications != null) {
            for (var app in data.applications!) {
              if (app.customer != null && app.customer!.id != null) {
                uniqueCustomers[app.customer!.id!] = app.customer!;
              } else if (app.name != null && app.name!.isNotEmpty) {
                final String guestKey = app.phone ?? app.name!;
                if (!uniqueCustomers.containsKey(guestKey)) {
                  uniqueCustomers[guestKey] = Customer(
                    id: null,
                    name: app.name,
                    phone: app.phone,
                    displayId: 'Pending applicant',
                  );
                }
              }
            }
          }

          final allCustomers = uniqueCustomers.values.toList();
          final int activeCount = allCustomers
              .where((c) => c.id != null)
              .length;
          final int pendingCount = allCustomers
              .where((c) => c.id == null)
              .length;

          // Filter + Search
          final filteredCustomers = allCustomers.where((customer) {
            final matchesFilter =
                _selectedFilter == 'All' ||
                (_selectedFilter == 'Active' && customer.id != null) ||
                (_selectedFilter == 'Pending' && customer.id == null);

            final query = _searchQuery.toLowerCase();
            final matchesSearch =
                query.isEmpty ||
                (customer.name?.toLowerCase().contains(query) ?? false) ||
                (customer.phone?.toLowerCase().contains(query) ?? false);

            return matchesFilter && matchesSearch;
          }).toList();

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

                        // Metrics
                        _buildMetricsSection(
                          total: data.customers ?? allCustomers.length,
                          active: activeCount,
                          pending: pendingCount,
                        ),

                        const SizedBox(height: 20),

                        // Filter chips
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildFilterChips(),
                        ),

                        const SizedBox(height: 16),

                        // Customer list
                        if (filteredCustomers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 80),
                            child: _buildEmptyState(
                              'No customer records found',
                            ),
                          )
                        else
                          ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredCustomers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _buildCustomerCard(
                                  filteredCustomers[index],
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
          debugPrint('➕ Add Customer clicked');
        },
        backgroundColor: const Color(0xFF0052CC),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(
          Icons.person_add_alt_1_rounded,
          color: Colors.white,
          size: 22,
        ),
        label: const Text(
          'Add Customer',
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
                  'Total Customers',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 18),
          Container(
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
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Search by name, phone or ID...',
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
        ],
      ),
    );
  }

  // ───────────────────── METRICS ─────────────────────
  Widget _buildMetricsSection({
    required int total,
    required int active,
    required int pending,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _metricCard(
              title: 'Total Customers',
              value: '$total',
              icon: Icons.people_alt_outlined,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF0052CC),
              valueColor: const Color(0xFF0052CC),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _metricCard(
              title: 'Active Accounts',
              value: '$active',
              icon: Icons.verified_user_outlined,
              iconBg: const Color(0xFFECFDF5),
              iconColor: const Color(0xFF10B981),
              valueColor: const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _metricCard(
              title: 'Pending Applicants',
              value: '$pending',
              icon: Icons.hourglass_top_rounded,
              iconBg: const Color(0xFFFFF7ED),
              iconColor: const Color(0xFFF59E0B),
              valueColor: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
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
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────── FILTER CHIPS ─────────────────────
  Widget _buildFilterChips() {
    final filters = [
      {'key': 'All', 'label': 'All'},
      {'key': 'Active', 'label': 'Active Accounts'},
      {'key': 'Pending', 'label': 'Pending Apps'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['key'];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter['key']!),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
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
                filter['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ───────────────────── CUSTOMER CARD ─────────────────────
  Widget _buildCustomerCard(Customer customer) {
    final isPending = customer.id == null;
    final name = customer.name ?? 'Unknown Customer';
    final displayId = isPending ? 'Pending App' : (customer.displayId ?? 'N/A');
    final phone = customer.phone ?? 'N/A';

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
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: isPending
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFEFF6FF),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'C',
                    style: TextStyle(
                      color: isPending
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF0052CC),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? const Color(0xFFFFF7ED)
                                  : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPending ? 'Pending' : 'Active',
                              style: TextStyle(
                                color: isPending
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ID: $displayId',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
              ],
            ),
          ),

          // Bottom actions
// TotalCustomerScreen.dart - _buildCustomerCard মেথডে

// Bottom actions
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                // ✅ Call Button - সরাসরি Phone Dialer Open করবে
                Expanded(
                  child: _outlineBtn(
                    Icons.phone_rounded,
                    'Call',
                        () => _makePhoneCall(phone), // ✅ _makePhoneCall ব্যবহার করুন
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _outlineBtn(
                    Icons.chat_bubble_outline_rounded,
                    'SMS',
                        () => _launchAction('sms:$phone'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToCustomerDetails(customer),
                    icon: const Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
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
                const SizedBox(width: 8),

                // Edit Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToEditCustomer(customer),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 12,
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
  void _makePhoneCall(String phoneNumber) async {
    // ডায়ালার খোলা
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        final Uri dialUri = Uri(scheme: 'tel', path: phoneNumber);
        await launchUrl(dialUri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot call: $phoneNumber'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
// ─── Navigation to Edit Customer ───
  void _navigateToEditCustomer(Customer customer) {
    debugPrint('✏️ [TotalCustomerScreen] Edit Customer Clicked');
    debugPrint('🆔 Customer ID: ${customer.id ?? 'N/A'}');
    debugPrint('📋 Customer Name: ${customer.name ?? 'Unknown'}');

    if (customer.id == null || customer.id!.isEmpty) {
      debugPrint('⚠️ Customer ID is null or empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot edit pending applicant. Please complete application first.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final customerId = customer.id!;
      debugPrint('✅ Navigating to EditCustomer with ID: $customerId');

      Navigator.pushNamed(
        context,
        RouteName.editCustomerScreen,
        arguments: customerId,
      ).then((result) {
        debugPrint('✅ Edit navigation completed. Result: $result');
      }).catchError((error) {
        debugPrint('❌ Navigation error: $error');
        _showErrorDialog('Navigation Error', error.toString());
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Navigation Exception: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      _showErrorDialog('Error', 'Could not open edit screen: $e');
    }
  }
  // ─── Navigation Method ───
  void _navigateToCustomerDetails(Customer customer) {
    debugPrint('👤 [TotalCustomerScreen] View Details Clicked');
    debugPrint('🆔 Customer ID: ${customer.id ?? 'N/A'}');
    debugPrint('📋 Customer Name: ${customer.name ?? 'Unknown'}');
    debugPrint('📞 Customer Phone: ${customer.phone ?? 'N/A'}');

    // 🔥 নতুন চেক: customerId আছে কিনা
    if (customer.id == null || customer.id!.isEmpty) {
      debugPrint('⚠️ Customer ID is null or empty - checking application...');

      // 🆕 application থেকে ID নেওয়ার চেষ্টা করুন
      // যদি customerId থাকে, তাহলে সেটা ব্যবহার করুন
      if (customer.displayId != null &&
          customer.displayId != 'Pending applicant') {
        // customerId পাওয়া গেছে
        try {
          final customerId = customer.displayId!;
          Navigator.pushNamed(
            context,
            RouteName.customerDetailsScreen,
            arguments: customerId,
          );
          return;
        } catch (e) {
          debugPrint('Error navigating with displayId: $e');
        }
      }

      // যদি কোন customerId না থাকে, তাহলে পেন্ডিং অ্যাপ্লিকেশন ওপেন করুন
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This is a pending applicant. Please complete the application first.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      // 🆕 পেন্ডিং অ্যাপ্লিকেশন স্ক্রিনে নিয়ে যান
      // Navigator.pushNamed(context, RouteName.pendingApplicationScreen);
      return;
    }

    try {
      final customerId = customer.id!;
      debugPrint('✅ Sending customerId: $customerId');

      Navigator.pushNamed(
            context,
            RouteName.customerDetailsScreen,
            arguments: customerId,
          )
          .then((result) {
            debugPrint('✅ Navigation completed. Result: $result');
          })
          .catchError((error) {
            debugPrint(' Navigation error: $error');
            _showErrorDialog('Navigation Error', error.toString());
          });

      debugPrint('✅ Navigation command sent successfully');
    } catch (e, stackTrace) {
      debugPrint(' Navigation Exception: $e');
      debugPrint('📚 StackTrace: $stackTrace');
      _showErrorDialog('Error', 'Could not open customer details: $e');
    }
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

  Widget _outlineBtn(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        side: BorderSide(color: const Color(0xFF0052CC).withOpacity(0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        foregroundColor: const Color(0xFF0052CC),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0052CC)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0052CC),
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

  void _launchAction(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.group_off_outlined, size: 64, color: Colors.grey.shade300),
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
