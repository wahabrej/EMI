import 'package:flutter/material.dart';
import '../../../../core/constant/App_Colors.dart';

class CustomerDocumentsScreen extends StatelessWidget {
  const CustomerDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.black, size: 20),
        ),
        title: const Text(
          'My Documents',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDocumentTile('Customer Photo', 'Verified', Icons.person_outline),
          _buildDocumentTile('NID Front Side', 'Verified', Icons.badge_outlined),
          _buildDocumentTile('NID Back Side', 'Verified', Icons.badge_outlined),
          _buildDocumentTile('Income Proof', 'Pending', Icons.description_outlined),
          _buildDocumentTile('Loan Agreement', 'Digital Copy', Icons.assignment_outlined),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(String title, String status, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.infoBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(color: status == 'Verified' ? AppColors.successGreen : AppColors.greyText, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue),
        ],
      ),
    );
  }
}