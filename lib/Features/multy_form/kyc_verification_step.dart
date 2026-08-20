import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/multy_form/viewModel/multyform_provider.dart';
import '../../../../core/constant/App_Colors.dart';

class KycVerificationStep extends StatefulWidget {
  final VoidCallback onNext;
  const KycVerificationStep({super.key, required this.onNext});

  @override
  State<KycVerificationStep> createState() => _KycVerificationStepState();
}

class _KycVerificationStepState extends State<KycVerificationStep> {
  final _formKey = GlobalKey<FormState>();
  final _nidController = TextEditingController();

  final Map<String, String> _incomeProofOptions = {
    'Salary Slip': 'INCOME_PROOF_SALARY_CERTIFICATE',
    'Bank Statement': 'INCOME_PROOF_BANK_STATEMENT',
    'Trade License': 'INCOME_PROOF_TRADE_LICENSE',
    'ID Card': 'INCOME_PROOF_ID_CARD',
    'Others': 'INCOME_PROOF_OTHERS',
  };
  @override
  void initState() {
    super.initState();
    final vm = Provider.of<CheckoutViewModel>(context, listen: false);
    _nidController.text = vm.checkoutData.nidPassportNumber;
  }

  Future<void> _showImageSourceActionSheet(
    BuildContext context,
    Function(File) onPicked,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primaryBlue,
              ),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (image != null) onPicked(File(image.path));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryBlue,
              ),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  imageQuality: 85,
                );
                if (image != null) onPicked(File(image.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CheckoutViewModel>(context);
    final data = vm.checkoutData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KYC Verification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text(
              'Document Type',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: data.customerIdType,
              items: [
                'NID',
                'Passport',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                if (val != null) vm.setCustomerIdType(val);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              '${data.customerIdType} Number',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nidController,
              validator: (v) => v!.isEmpty ? 'Required' : null,
              decoration: InputDecoration(
                hintText: 'Enter ${data.customerIdType} number',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Upload Documents',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (data.customerIdType == 'NID') ...[
              _buildUploadCard(
                title: 'NID Front Side',
                file: data.nidFront,
                onTap: () => _showImageSourceActionSheet(
                  context,
                  (file) => vm.setNidFront(file),
                ),
              ),
              const SizedBox(height: 12),
              _buildUploadCard(
                title: 'NID Back Side',
                file: data.nidBack,
                onTap: () => _showImageSourceActionSheet(
                  context,
                  (file) => vm.setNidBack(file),
                ),
              ),
            ] else ...[
              _buildUploadCard(
                title: 'Passport Copy',
                file: data.nidFront,
                onTap: () => _showImageSourceActionSheet(
                  context,
                  (file) => vm.setNidFront(file),
                ),
              ),
            ],

            const SizedBox(height: 24),
            // 🔥 Proof of Income Section (Added Back)
            const Text(
              'Proof of Income Type',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value:
                  _incomeProofOptions.values.contains(
                    data.incomeProofDocumentType,
                  )
                  ? data.incomeProofDocumentType
                  : _incomeProofOptions.values.first,
              isExpanded: true,
              items: _incomeProofOptions.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.value,
                      child: Text(e.key, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) vm.setIncomeProofType(val);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: () => _showImageSourceActionSheet(
                context,
                (file) => vm.setIncomeProof(file),
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      data.incomeProof != null
                          ? Icons.check_circle
                          : Icons.file_upload_outlined,
                      color: data.incomeProof != null
                          ? Colors.green
                          : AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.incomeProof != null
                          ? 'Income Proof Attached'
                          : 'Upload Income Proof',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    vm.setNidPassportNumber(_nidController.text.trim());
                    widget.onNext();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text(
                  'Next Step',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? AppColors.primaryBlue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              color: file != null ? Colors.green : Colors.blue,
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (file != null) const Icon(Icons.done, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
