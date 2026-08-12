import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constant/App_Colors.dart';
import '../../Auth/ModelView/Auth_Screen_Provider.dart';
import '../viewmodel/profileScreenProvider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => provider.fetchProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // ✅ FIX: সরাসরি profileData ব্যবহার করুন, .data নয়
          final profile = provider.profileData;
          
          if (profile == null) {
            return const Center(child: Text('No profile data found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(profile),
                const SizedBox(height: 20),
                _buildKycStatusBadge(profile),
                const SizedBox(height: 24),
                _buildSectionTitle('Personal Information'),
                const SizedBox(height: 12),
                _buildPersonalInfoCard(profile),
                const SizedBox(height: 32),
                _buildLogoutButton(context),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.bgGrey,
            child: const Icon(Icons.person_rounded, size: 40, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name ?? 'No Name',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  profile.email ?? 'No Email',
                  style: const TextStyle(fontSize: 12, color: AppColors.greyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycStatusBadge(dynamic profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.accentBlue]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            profile.roleSlug?.toUpperCase() ?? 'ACTIVE',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
  }

  Widget _buildPersonalInfoCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Column(
        children: [
          _infoRow(Icons.person_outline, 'Full Name', profile.name ?? 'N/A'),
          const Divider(),
          _infoRow(Icons.email_outlined, 'Email', profile.email ?? 'N/A'),
          const Divider(),
          _infoRow(Icons.badge_outlined, 'User ID', profile.id ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.greyText)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(dynamic profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _infoRow(Icons.calendar_today, 'Joined', profile.createdAt?.split('T')[0] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<AuthScreenProvider>().logout(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
