import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constant/App_Colors.dart';
import '../../../../Features/Auth/ModelView/Auth_Screen_Provider.dart';
import '../viewModel/customer_profile_view_model.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProfileViewModel>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CustomerProfileViewModel>();
    final profile = vm.profileData; // এখন এটা Data?

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.accentBlue,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : vm.errorMessage != null
          ? Center(child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── Profile Header ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.infoBlue,
                    backgroundImage: () {
                      final url = profile?.customerImageUrl;
                      if (url == null || url.isEmpty) return null;

                      if (url.startsWith('http')) {
                        return NetworkImage(url);
                      }
                      return NetworkImage('https://api.smartpay.click$url');
                    }(),
                    child: (profile?.customerImageUrl == null || profile!.customerImageUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 40, color: AppColors.primaryBlue)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name ?? 'Loading...',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          profile?.phone ?? '',
                          style: const TextStyle(color: AppColors.greyText, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${profile?.displayId ?? ''}',
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Personal Details ────────────────────────────
            _buildSectionTitle('Personal Details'),
            const SizedBox(height: 10),
            _buildMenuCard([
              _buildInfoTile(Icons.home_outlined, 'Present Address', profile?.presentAddress ?? 'N/A'),
              _buildInfoTile(Icons.location_on_outlined, 'Permanent Address', profile?.permanentAddress ?? 'N/A'),
              _buildInfoTile(Icons.work_outline, 'Income Source', profile?.sourceOfIncome ?? 'N/A'),
              _buildInfoTile(Icons.attach_money, 'Monthly Income', '৳${profile?.monthlyIncome ?? '0'}'),
              _buildInfoTile(Icons.badge_outlined, 'NID / Passport', profile?.maskedNidPassportNumber ?? 'N/A'),
            ]),
            const SizedBox(height: 24),

            // ── Support & Legal ─────────────────────────────────
            _buildSectionTitle('Support & Legal'),
            const SizedBox(height: 10),
            _buildMenuCard([
              _buildMenuItem(Icons.description_outlined, 'Terms & Conditions', onTap: () {}),
              _buildMenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {}),
            ]),
            const SizedBox(height: 24),

            // ── Logout ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.errorRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout, color: AppColors.errorRed, size: 20),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.greyText),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.greyText)),
      subtitle: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AuthScreenProvider>().logout(context);
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}