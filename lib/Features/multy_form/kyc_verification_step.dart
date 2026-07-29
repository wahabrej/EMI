import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/multy_form/viewModel/multyform_provider.dart';

class KycVerificationStep extends StatefulWidget {
  final VoidCallback onNext;

  const KycVerificationStep({super.key, required this.onNext});

  @override
  State<KycVerificationStep> createState() => _KycVerificationStepState();
}

class _KycVerificationStepState extends State<KycVerificationStep> {
  final _formKey = GlobalKey<FormState>();
  final _nidController = TextEditingController();

  // Mapping display names to API values
  final Map<String, String> _incomeProofOptions = {
    'Salary Slip': 'INCOME_PROOF_SALARY_SLIP',
    'Bank Statement': 'INCOME_PROOF_BANK_STATEMENT',
    'Trade License': 'INCOME_PROOF_TRADE_LICENSE',
    'Utility Bill': 'INCOME_PROOF_UTILITY_BILL',
  };

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<CheckoutViewModel>(context, listen: false);
    _nidController.text = vm.checkoutData.nidPassportNumber;
  }

  @override
  void dispose() {
    _nidController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, Function(File) onPicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 85);

    if (image != null) {
      onPicked(File(image.path));
    }
  }

  void _saveAndNext(CheckoutViewModel vm) {
    if (_formKey.currentState!.validate()) {
      vm.setNidPassportNumber(_nidController.text.trim());
      widget.onNext();
    }
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 2),
            const Text(
              'Required for EMI sales, optional for full price',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),

            // ID Number Field
            const Text(
              'Customer NID / Passport Number',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nidController,
              keyboardType: TextInputType.text,
              validator: (v) {
                if (data.saleType == 'EMI' && (v == null || v.trim().isEmpty)) {
                  return 'Enter ID number';
                }
                return null;
              },
              decoration: _inputDecoration(hint: 'Enter NID or Passport number'),
            ),
            const SizedBox(height: 20),

            const Text(
              'Upload ID Documents',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            _buildUploadCard(
              title: 'ID Front Side',
              subtitle: data.nidFront != null ? 'Front side uploaded' : 'Tap to upload front side',
              file: data.nidFront,
              onTap: () => _pickImage(ImageSource.gallery, (file) => vm.setNidFront(file)),
            ),
            const SizedBox(height: 12),

            _buildUploadCard(
              title: 'ID Back Side',
              subtitle: data.nidBack != null ? 'Back side uploaded' : 'Tap to upload back side',
              file: data.nidBack,
              onTap: () => _pickImage(ImageSource.gallery, (file) => vm.setNidBack(file)),
            ),
            const SizedBox(height: 24),

            const Text(
              'Additional Documents',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            // Income Proof Type Dropdown
            const Text(
              'Proof of Income Type',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _incomeProofOptions.values.contains(data.incomeProofDocumentType) 
                  ? data.incomeProofDocumentType 
                  : _incomeProofOptions.values.first,
              isExpanded: true,
              items: _incomeProofOptions.entries.map((e) {
                return DropdownMenuItem(
                  value: e.value,
                  child: Text(e.key, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) vm.setIncomeProofType(val);
              },
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 12),

            // Income Proof Upload
            InkWell(
              onTap: () => _pickImage(ImageSource.gallery, (file) => vm.setIncomeProof(file)),
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
                      data.incomeProof != null ? Icons.check_circle : Icons.file_upload_outlined,
                      color: data.incomeProof != null ? Colors.green : const Color(0xFF2563EB),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.incomeProof != null ? 'Income Proof Attached' : 'Upload Income Proof',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Next Step Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _saveAndNext(vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Next Step',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: file != null ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: file != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(file, fit: BoxFit.cover),
              )
                  : const Icon(Icons.badge_outlined, color: Color(0xFF2563EB), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: file != null ? Colors.green : const Color(0xFF64748B))),
                ],
              ),
            ),
            Icon(
              file != null ? Icons.check_circle : Icons.check_circle_outline,
              color: file != null ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB))),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
