import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/multy_form/viewModel/multyform_provider.dart';

class CustomerInfoStep extends StatefulWidget {
  final VoidCallback onNext;

  const CustomerInfoStep({super.key, required this.onNext});

  @override
  State<CustomerInfoStep> createState() => _CustomerInfoStepState();
}

class _CustomerInfoStepState extends State<CustomerInfoStep> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _presentAddressController = TextEditingController();
  final _permanentAddressController = TextEditingController();

  bool _obscurePassword = true;

  final List<String> _incomeSources = [
    'Private Service',
    'Business',
    'Student',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    final vm = Provider.of<CheckoutViewModel>(context, listen: false);
    _nameController.text = vm.checkoutData.name;
    _phoneController.text = vm.checkoutData.phone;
    _passwordController.text = vm.checkoutData.password;
    _monthlyIncomeController.text = vm.checkoutData.monthlyIncome == 0.0
        ? ''
        : vm.checkoutData.monthlyIncome.toStringAsFixed(0);
    _presentAddressController.text = vm.checkoutData.presentAddress;
    _permanentAddressController.text = vm.checkoutData.permanentAddress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _monthlyIncomeController.dispose();
    _presentAddressController.dispose();
    _permanentAddressController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceActionSheet(BuildContext context, Function(ImageSource) onSourceSelected) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select Photo Source', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                onSourceSelected(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
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

  Future<void> _showVideoSourceActionSheet(BuildContext context, Function(ImageSource) onSourceSelected) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Select Video Source', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: Colors.blue),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                onSourceSelected(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.blue),
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

  Future<void> _pickImage(CheckoutViewModel vm) async {
    await _showImageSourceActionSheet(context, (source) async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        vm.setCustomerImage(File(image.path));
      }
    });
  }

  Future<void> _pickVideo(CheckoutViewModel vm) async {
    await _showVideoSourceActionSheet(context, (source) async {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: source,
      );

      if (video != null) {
        vm.setCustomerVideo(File(video.path));
      }
    });
  }

  void _saveAndNext(CheckoutViewModel vm) {
    if (_formKey.currentState!.validate()) {
      vm.checkoutData.name = _nameController.text.trim();
      vm.checkoutData.phone = _phoneController.text.trim();
      vm.checkoutData.password = _passwordController.text.trim();
      vm.checkoutData.monthlyIncome = double.tryParse(_monthlyIncomeController.text.trim()) ?? 0.0;
      vm.checkoutData.presentAddress = _presentAddressController.text.trim();
      vm.checkoutData.permanentAddress = _permanentAddressController.text.trim();
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CheckoutViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _nameController,
              label: 'Customer Name *',
              hint: 'Enter customer name',
              validator: (v) => v!.trim().isEmpty ? 'Enter customer name' : null,
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _phoneController,
              label: 'Customer Phone Number *',
              hint: 'Enter customer phone number',
              keyboardType: TextInputType.phone,
              validator: (v) => v!.trim().isEmpty ? 'Enter phone number' : null,
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _passwordController,
              label: 'Customer Login Password *',
              hint: 'Enter login password',
              obscureText: _obscurePassword,
              validator: (v) => v!.trim().isEmpty ? 'Enter login password' : null,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            const SizedBox(height: 16),

            // ─── Customer Image Upload ───
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Customer Image',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Upload a clear customer photo for the profile',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _pickImage(vm),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: vm.customerImageFile != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          vm.customerImageFile!,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Column(
                        children: const [
                          Icon(Icons.person_add_alt_1_outlined, color: Color(0xFF2563EB)),
                          SizedBox(height: 4),
                          Text(
                            'Upload image',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── Customer Video Upload ───
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Customer Video',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Upload a short video for verification',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _pickVideo(vm),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: vm.customerVideoFile != null
                          ? Row(
                        children: [
                          const Icon(Icons.video_file, color: Colors.blue, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'Video Attached',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      )
                          : Column(
                        children: const [
                          Icon(Icons.video_call_outlined, color: Color(0xFF2563EB)),
                          SizedBox(height: 4),
                          Text(
                            'Upload video',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Source of Income *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _incomeSources.contains(vm.checkoutData.sourceOfIncome)
                            ? vm.checkoutData.sourceOfIncome
                            : null,
                        hint: const Text('Select source', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                        isExpanded: true,
                        items: _incomeSources.map((source) {
                          return DropdownMenuItem(
                            value: source,
                            child: Text(source, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          vm.checkoutData.sourceOfIncome = val ?? 'Business';
                          vm.notifyListeners();
                        },
                        validator: (v) => v == null ? 'Select source' : null,
                        decoration: _inputDecoration(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _monthlyIncomeController,
                    label: 'Monthly Income *',
                    hint: 'Enter income',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.trim().isEmpty ? 'Enter monthly income' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _presentAddressController,
              label: 'Present Address *',
              hint: 'Enter present address',
              maxLines: 2,
              validator: (v) => v!.trim().isEmpty ? 'Enter present address' : null,
            ),
            const SizedBox(height: 12),

            _buildTextField(
              controller: _permanentAddressController,
              label: 'Permanent Address *',
              hint: 'Enter permanent address',
              maxLines: 2,
              validator: (v) => v!.trim().isEmpty ? 'Enter permanent address' : null,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _saveAndNext(vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 0,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          validator: validator,
          decoration: _inputDecoration(hint: hint, suffixIcon: suffixIcon),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB))),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}