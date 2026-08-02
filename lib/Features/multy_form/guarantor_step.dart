import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/multy_form/viewModel/multyform_provider.dart';
import '../../../../core/constant/App_Colors.dart';
import 'model/full_checkout_model.dart';

class GuarantorStep extends StatefulWidget {
  final VoidCallback onNext;

  const GuarantorStep({super.key, required this.onNext});

  @override
  State<GuarantorStep> createState() => _GuarantorStepState();
}

class _GuarantorStepState extends State<GuarantorStep> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _typeOptions = ['FAMILY', 'NON_FAMILY', 'OTHER'];

  final List<String> _relationshipOptions = [
    'Spouse', 'Brother', 'Sister', 'Father', 'Mother', 'Son', 'Daughter', 'Friend', 'Colleague', 'Others'
  ];

  final List<String> _docTypeOptions = ['NID', 'Passport', 'Driving License'];

  // 🔹 Image Source Selection Sheet
  Future<void> _showImageSourceActionSheet(BuildContext context, Function(ImageSource) onSourceSelected) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select Image Source', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                onSourceSelected(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                onSourceSelected(ImageSource.camera);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(Function(File) onPicked) async {
    await _showImageSourceActionSheet(context, (source) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 85);
      if (image != null) {
        onPicked(File(image.path));
      }
    });
  }

  void _saveAndNext(CheckoutViewModel vm) {
    if (_formKey.currentState!.validate()) {
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CheckoutViewModel>(context);
    final guarantors = vm.checkoutData.guarantors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guarantor Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 2),
            const Text(
              'Required for EMI sales, optional for full price',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: guarantors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildGuarantorCard(vm, guarantors[index], index);
              },
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: () => vm.addGuarantor(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppColors.primaryBlue, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Add Guarantor',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _saveAndNext(vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
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

  Widget _buildGuarantorCard(CheckoutViewModel vm, GuarantorInfo item, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Guarantor ${index + 1}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              if (vm.checkoutData.guarantors.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => vm.removeGuarantor(index),
                ),
            ],
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 16),

          _buildDropdown(
            label: 'Type',
            value: _typeOptions.contains(item.type) ? item.type : _typeOptions.first,
            items: _typeOptions,
            onChanged: (val) {
              if (val != null) {
                item.type = val;
                vm.notify();
              }
            },
          ),
          const SizedBox(height: 12),

          _buildTextField(
            label: 'Name',
            hint: 'Enter guarantor name',
            initialValue: item.name,
            onChanged: (val) {
              item.name = val.trim();
              vm.notify();
            },
            validator: (v) => (vm.checkoutData.saleType == 'EMI' && (v == null || v.isEmpty)) ? 'Required' : null,
          ),
          const SizedBox(height: 12),

          _buildTextField(
            label: 'Phone Number',
            hint: 'Enter guarantor phone number',
            keyboardType: TextInputType.phone,
            initialValue: item.phone,
            onChanged: (val) {
              item.phone = val.trim();
              vm.notify();
            },
            validator: (v) => (vm.checkoutData.saleType == 'EMI' && (v == null || v.isEmpty)) ? 'Required' : null,
          ),
          const SizedBox(height: 12),

          _buildDropdown(
            label: 'Relationship',
            value: _relationshipOptions.contains(item.relationship) ? item.relationship : _relationshipOptions.first,
            items: _relationshipOptions,
            onChanged: (val) {
              if (val != null) {
                item.relationship = val;
                vm.notify();
              }
            },
          ),
          const SizedBox(height: 12),

          _buildTextField(
            label: 'NID or Passport Number',
            hint: 'Enter NID number',
            initialValue: item.nidPassportNumber,
            onChanged: (val) {
              item.nidPassportNumber = val.trim();
              vm.notify();
            },
            validator: (v) => (vm.checkoutData.saleType == 'EMI' && (v == null || v.isEmpty)) ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          const Text(
            'KYC Documents',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: 'NID',
            isExpanded: true,
            items: _docTypeOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) {},
            decoration: _inputDecoration(),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildDocUploadBox(
                  title: 'Front Side',
                  file: item.nidFront,
                  onTap: () => _pickImage((file) => vm.setGuarantorNidFront(index, file)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDocUploadBox(
                  title: 'Back Side',
                  file: item.nidBack,
                  onTap: () => _pickImage((file) => vm.setGuarantorNidBack(index, file)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocUploadBox({required String title, required File? file, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: file != null ? AppColors.primaryBlue : const Color(0xFFCBD5E1)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: file != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(file, fit: BoxFit.cover),
              )
                  : const Icon(Icons.badge_outlined, color: AppColors.primaryBlue, size: 18),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              file != null ? Icons.check_circle : Icons.check_circle_outline,
              color: file != null ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String initialValue,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(fontSize: 13),
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
