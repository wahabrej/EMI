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
    'Spouse',
    'Brother',
    'Sister',
    'Father',
    'Mother',
    'Son',
    'Daughter',
    'Friend',
    'Colleague',
    'Others',
  ];

  // 🔹 Image Source Selection Sheet (Gallery + Camera)
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
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image != null) onPicked(File(image.path));
    });
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: guarantors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) =>
                  _buildGuarantorCard(vm, guarantors[index], index),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => vm.addGuarantor(),
              icon: const Icon(Icons.add),
              label: const Text('Add Guarantor'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) widget.onNext();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                ),
                child: const Text(
                  'Next Step',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuarantorCard(
      CheckoutViewModel vm,
      GuarantorInfo item,
      int index,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Guarantor ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (vm.checkoutData.guarantors.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => vm.removeGuarantor(index),
                  ),
              ],
            ),

            // ─── Type Dropdown ───
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

            TextFormField(
              initialValue: item.name,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (v) => item.name = v,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: item.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              onChanged: (v) => item.phone = v,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // ─── Relationship Dropdown ───
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

            DropdownButtonFormField<String>(
              value: item.idType,
              decoration: const InputDecoration(labelText: 'ID Document Type'),
              items: [
                'NID',
                'Passport',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) vm.setGuarantorIdType(index, v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: item.nidPassportNumber,
              decoration: InputDecoration(labelText: '${item.idType} Number'),
              onChanged: (v) => item.nidPassportNumber = v,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload ID Documents',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            if (item.idType == 'NID')
              Row(
                children: [
                  Expanded(
                    child: _buildDocBox(
                      'NID Front',
                      item.nidFront,
                          () =>
                          _pickImage((f) => vm.setGuarantorNidFront(index, f)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDocBox(
                      'NID Back',
                      item.nidBack,
                          () => _pickImage((f) => vm.setGuarantorNidBack(index, f)),
                    ),
                  ),
                ],
              )
            else
              _buildDocBox(
                'Passport Copy',
                item.nidFront,
                    () => _pickImage((f) => vm.setGuarantorNidFront(index, f)),
              ),
          ],
        ),
      ),
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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDocBox(String title, File? file, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: file != null ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              color: file != null ? Colors.green : Colors.blue,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }
}