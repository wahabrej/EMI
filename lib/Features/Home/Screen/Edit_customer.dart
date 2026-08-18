// lib/features/customer/screens/edit_customer.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constant/App_Colors.dart';
import '../../../core/constant/Api_End_point.dart';
import '../ViewModel/CustomerEditViewModel.dart';

class EditCustomerScreen extends StatefulWidget {
  final String customerId;

  const EditCustomerScreen({super.key, required this.customerId});

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers ───
  TextEditingController? _nameController;
  TextEditingController? _phoneController;
  TextEditingController? _emailController;
  TextEditingController? _nidController;
  TextEditingController? _incomeSourceController;
  TextEditingController? _monthlyIncomeController;
  TextEditingController? _presentAddressController;
  TextEditingController? _permanentAddressController;
  TextEditingController? _monthlyPaymentDateController;
  TextEditingController? _issueDateController;
  TextEditingController? _shopNameController;
  TextEditingController? _agentNameController;
  TextEditingController? _managerNameController;
  TextEditingController? _salesPersonNameController;
  TextEditingController? _productNameController;
  TextEditingController? _mrpController;
  TextEditingController? _downPaymentController;
  TextEditingController? _emiChargeController;
  TextEditingController? _emiTenureController;
  TextEditingController? _monthlyEmiController;
  TextEditingController? _bankAccountNameController;
  TextEditingController? _bankAccountNumberController;
  TextEditingController? _bankNameController;
  TextEditingController? _referenceNumberController;

  // ─── Guarantor Data ───
  List<TextEditingController> _guarantorNameControllers = [];
  List<TextEditingController> _guarantorPhoneControllers = [];
  List<TextEditingController> _guarantorRelationshipControllers = [];
  List<TextEditingController> _guarantorNidControllers = [];
  List<String> _guarantorIdTypes = [];
  List<String> _guarantorTypes = [];
  List<String> _guarantorIds = [];
  List<File?> _guarantorNidFrontFiles = [];
  List<File?> _guarantorNidBackFiles = [];
  List<String> _guarantorNidFrontUrls = [];
  List<String> _guarantorNidBackUrls = [];

  String? _selectedIdType;
  String? _selectedStatus;
  DateTime _selectedMonthlyPaymentDate = DateTime.now();
  DateTime _selectedIssueDate = DateTime.now();

  // ─── Add Guarantor Dialog ───
  final TextEditingController _newGuarantorNameController =
      TextEditingController();
  final TextEditingController _newGuarantorPhoneController =
      TextEditingController();
  final TextEditingController _newGuarantorRelationshipController =
      TextEditingController();
  final TextEditingController _newGuarantorNidController =
      TextEditingController();
  String _newGuarantorIdType = 'NID';
  String _newGuarantorType = 'FAMILY';
  File? _newGuarantorNidFront;
  File? _newGuarantorNidBack;

  // ─── Edit Guarantor Dialog ───
  int? _editingGuarantorIndex;
  final TextEditingController _editGuarantorNameController =
      TextEditingController();
  final TextEditingController _editGuarantorPhoneController =
      TextEditingController();
  final TextEditingController _editGuarantorRelationshipController =
      TextEditingController();
  final TextEditingController _editGuarantorNidController =
      TextEditingController();
  String _editGuarantorIdType = 'NID';
  String _editGuarantorType = 'FAMILY';
  File? _editGuarantorNidFront;
  File? _editGuarantorNidBack;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerEditViewModel>().fetchCustomerDetail(
        widget.customerId,
      );
    });
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _phoneController?.dispose();
    _emailController?.dispose();
    _nidController?.dispose();
    _incomeSourceController?.dispose();
    _monthlyIncomeController?.dispose();
    _presentAddressController?.dispose();
    _permanentAddressController?.dispose();
    _monthlyPaymentDateController?.dispose();
    _issueDateController?.dispose();
    _shopNameController?.dispose();
    _agentNameController?.dispose();
    _managerNameController?.dispose();
    _salesPersonNameController?.dispose();
    _productNameController?.dispose();
    _mrpController?.dispose();
    _downPaymentController?.dispose();
    _emiChargeController?.dispose();
    _emiTenureController?.dispose();
    _monthlyEmiController?.dispose();
    _bankAccountNameController?.dispose();
    _bankAccountNumberController?.dispose();
    _bankNameController?.dispose();
    _referenceNumberController?.dispose();

    for (var c in _guarantorNameControllers) c.dispose();
    for (var c in _guarantorPhoneControllers) c.dispose();
    for (var c in _guarantorRelationshipControllers) c.dispose();
    for (var c in _guarantorNidControllers) c.dispose();

    _newGuarantorNameController.dispose();
    _newGuarantorPhoneController.dispose();
    _newGuarantorRelationshipController.dispose();
    _newGuarantorNidController.dispose();

    _editGuarantorNameController.dispose();
    _editGuarantorPhoneController.dispose();
    _editGuarantorRelationshipController.dispose();
    _editGuarantorNidController.dispose();

    super.dispose();
  }

  // ─── Initialize Controllers ───
  void _initControllers(dynamic customer) {
    _nameController = TextEditingController(text: customer.name ?? '');
    _phoneController = TextEditingController(text: customer.phone ?? '');
    _emailController = TextEditingController(text: customer.email ?? '');
    _nidController = TextEditingController(
      text: customer.nidPassportNumber ?? '',
    );
    _incomeSourceController = TextEditingController(
      text: customer.sourceOfIncome ?? '',
    );
    _monthlyIncomeController = TextEditingController(
      text: customer.monthlyIncome?.toString() ?? '',
    );
    _presentAddressController = TextEditingController(
      text: customer.presentAddress ?? '',
    );
    _permanentAddressController = TextEditingController(
      text: customer.permanentAddress ?? '',
    );

    _monthlyPaymentDateController = TextEditingController(
      text: customer.monthlyPaymentDate != null
          ? DateFormat(
              'dd MMM yyyy',
            ).format(DateTime.parse(customer.monthlyPaymentDate!))
          : DateFormat('dd MMM yyyy').format(DateTime.now()),
    );

    _issueDateController = TextEditingController(
      text: customer.issueDate != null
          ? DateFormat(
              'dd MMM yyyy',
            ).format(DateTime.parse(customer.issueDate!))
          : DateFormat('dd MMM yyyy').format(DateTime.now()),
    );

    _shopNameController = TextEditingController(
      text: customer.shop?.name ?? 'N/A',
    );
    _agentNameController = TextEditingController(
      text: customer.agent?.name ?? 'N/A',
    );
    _managerNameController = TextEditingController(
      text: customer.manager?.name ?? 'N/A',
    );
    _salesPersonNameController = TextEditingController(
      text: customer.salesPerson?.name ?? 'N/A',
    );
    _productNameController = TextEditingController(
      text: customer.product?.name ?? 'N/A',
    );
    _mrpController = TextEditingController(text: customer.mrp ?? '0');
    _downPaymentController = TextEditingController(
      text: customer.downPayment ?? '0',
    );
    _emiChargeController = TextEditingController(
      text: customer.emiCharge ?? '0',
    );
    _emiTenureController = TextEditingController(
      text: customer.emiTenureMonths?.toString() ?? '0',
    );
    _monthlyEmiController = TextEditingController(
      text: customer.monthlyEmi ?? '0',
    );
    _bankAccountNameController = TextEditingController(
      text: customer.bankAccountName ?? 'N/A',
    );
    _bankAccountNumberController = TextEditingController(
      text: customer.bankAccountNumber ?? 'N/A',
    );
    _bankNameController = TextEditingController(
      text: customer.bankName ?? 'N/A',
    );
    _referenceNumberController = TextEditingController(
      text: customer.downPaymentReferenceNumber ?? 'N/A',
    );

    _selectedIdType = customer.idType ?? 'NID';
    _selectedStatus = customer.status ?? 'ACTIVE';

    if (customer.monthlyPaymentDate != null) {
      _selectedMonthlyPaymentDate = DateTime.parse(
        customer.monthlyPaymentDate!,
      );
    }
    if (customer.issueDate != null) {
      _selectedIssueDate = DateTime.parse(customer.issueDate!);
    }

    _initGuarantorControllers(customer.guarantors ?? []);
  }

  // ─── Initialize Guarantor Controllers ───
  void _initGuarantorControllers(List<dynamic> guarantors) {
    for (var c in _guarantorNameControllers) c.dispose();
    for (var c in _guarantorPhoneControllers) c.dispose();
    for (var c in _guarantorRelationshipControllers) c.dispose();
    for (var c in _guarantorNidControllers) c.dispose();

    _guarantorNameControllers.clear();
    _guarantorPhoneControllers.clear();
    _guarantorRelationshipControllers.clear();
    _guarantorNidControllers.clear();
    _guarantorIdTypes.clear();
    _guarantorTypes.clear();
    _guarantorIds.clear();
    _guarantorNidFrontFiles.clear();
    _guarantorNidBackFiles.clear();
    _guarantorNidFrontUrls.clear();
    _guarantorNidBackUrls.clear();

    for (var g in guarantors) {
      _guarantorIds.add(g.id ?? '');
      _guarantorNameControllers.add(TextEditingController(text: g.name ?? ''));
      _guarantorPhoneControllers.add(
        TextEditingController(text: g.phone ?? ''),
      );
      _guarantorRelationshipControllers.add(
        TextEditingController(text: g.relationship ?? ''),
      );
      _guarantorNidControllers.add(
        TextEditingController(text: g.nidPassportNumber ?? ''),
      );
      _guarantorIdTypes.add(g.idType ?? 'NID');
      _guarantorTypes.add(g.type ?? 'FAMILY');
      _guarantorNidFrontUrls.add(g.nidFront ?? '');
      _guarantorNidBackUrls.add(g.nidBack ?? '');
      _guarantorNidFrontFiles.add(null);
      _guarantorNidBackFiles.add(null);
    }
  }

  // ─── Date Picker ───
  Future<void> _selectMonthlyPaymentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonthlyPaymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedMonthlyPaymentDate) {
      setState(() {
        _selectedMonthlyPaymentDate = picked;
        _monthlyPaymentDateController?.text = DateFormat(
          'dd MMM yyyy',
        ).format(picked);
      });
    }
  }

  // ─── Image Picker ───
  Future<void> _showImageSourceActionSheet(
    BuildContext context,
    Function(ImageSource) onSourceSelected,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Image Source',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primaryBlue,
              ),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                onSourceSelected(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.primaryBlue,
              ),
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

  // ─── Show Add Guarantor Dialog ───
  void _showAddGuarantorDialog() {
    _newGuarantorNameController.clear();
    _newGuarantorPhoneController.clear();
    _newGuarantorRelationshipController.clear();
    _newGuarantorNidController.clear();
    _newGuarantorIdType = 'NID';
    _newGuarantorType = 'FAMILY';
    _newGuarantorNidFront = null;
    _newGuarantorNidBack = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Add Guarantor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newGuarantorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Enter guarantor name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newGuarantorPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone *',
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newGuarantorRelationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship *',
                    hintText: 'e.g. Brother, Friend, Spouse',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _newGuarantorType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'FAMILY', child: Text('Family')),
                    DropdownMenuItem(
                      value: 'NON_FAMILY',
                      child: Text('Non-Family'),
                    ),
                  ],
                  onChanged: (val) =>
                      setDialogState(() => _newGuarantorType = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _newGuarantorIdType,
                  decoration: const InputDecoration(
                    labelText: 'ID Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'NID', child: Text('NID')),
                    DropdownMenuItem(
                      value: 'Passport',
                      child: Text('Passport'),
                    ),
                  ],
                  onChanged: (val) =>
                      setDialogState(() => _newGuarantorIdType = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newGuarantorNidController,
                  decoration: const InputDecoration(
                    labelText: 'NID/Passport Number *',
                    hintText: 'Enter ID number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload ID Documents',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_newGuarantorIdType == 'NID') ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildDialogDocBox(
                          'NID Front',
                          _newGuarantorNidFront,
                          () => _pickImage((f) {
                            setDialogState(() => _newGuarantorNidFront = f);
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDialogDocBox(
                          'NID Back',
                          _newGuarantorNidBack,
                          () => _pickImage((f) {
                            setDialogState(() => _newGuarantorNidBack = f);
                          }),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _buildDialogDocBox(
                    'Passport Copy',
                    _newGuarantorNidFront,
                    () => _pickImage((f) {
                      setDialogState(() => _newGuarantorNidFront = f);
                    }),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_newGuarantorNameController.text.trim().isEmpty ||
                    _newGuarantorPhoneController.text.trim().isEmpty ||
                    _newGuarantorRelationshipController.text.trim().isEmpty ||
                    _newGuarantorNidController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                setState(() {
                  _guarantorIds.add('');
                  _guarantorNameControllers.add(
                    TextEditingController(
                      text: _newGuarantorNameController.text.trim(),
                    ),
                  );
                  _guarantorPhoneControllers.add(
                    TextEditingController(
                      text: _newGuarantorPhoneController.text.trim(),
                    ),
                  );
                  _guarantorRelationshipControllers.add(
                    TextEditingController(
                      text: _newGuarantorRelationshipController.text.trim(),
                    ),
                  );
                  _guarantorNidControllers.add(
                    TextEditingController(
                      text: _newGuarantorNidController.text.trim(),
                    ),
                  );
                  _guarantorIdTypes.add(_newGuarantorIdType);
                  _guarantorTypes.add(_newGuarantorType);
                  _guarantorNidFrontFiles.add(_newGuarantorNidFront);
                  _guarantorNidBackFiles.add(_newGuarantorNidBack);
                  _guarantorNidFrontUrls.add('');
                  _guarantorNidBackUrls.add('');
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dialog Document Box ───
  Widget _buildDialogDocBox(String title, File? file, VoidCallback onTap) {
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

  // ─── Show Edit Guarantor Dialog ───
  void _showEditGuarantorDialog(int index) {
    _editingGuarantorIndex = index;
    _editGuarantorNameController.text = _guarantorNameControllers[index].text;
    _editGuarantorPhoneController.text = _guarantorPhoneControllers[index].text;
    _editGuarantorRelationshipController.text =
        _guarantorRelationshipControllers[index].text;
    _editGuarantorNidController.text = _guarantorNidControllers[index].text;
    _editGuarantorIdType = _guarantorIdTypes[index];
    _editGuarantorType = _guarantorTypes[index];
    _editGuarantorNidFront = _guarantorNidFrontFiles[index];
    _editGuarantorNidBack = _guarantorNidBackFiles[index];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Edit Guarantor',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _editGuarantorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Enter guarantor name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editGuarantorPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone *',
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editGuarantorRelationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship *',
                    hintText: 'e.g. Brother, Friend, Spouse',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _editGuarantorType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'FAMILY', child: Text('Family')),
                    DropdownMenuItem(
                      value: 'NON_FAMILY',
                      child: Text('Non-Family'),
                    ),
                  ],
                  onChanged: (val) =>
                      setDialogState(() => _editGuarantorType = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _editGuarantorIdType,
                  decoration: const InputDecoration(
                    labelText: 'ID Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'NID', child: Text('NID')),
                    DropdownMenuItem(
                      value: 'Passport',
                      child: Text('Passport'),
                    ),
                  ],
                  onChanged: (val) {
                    setDialogState(() {
                      _editGuarantorIdType = val!;
                      if (val == 'Passport') {
                        _editGuarantorNidBack = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editGuarantorNidController,
                  decoration: const InputDecoration(
                    labelText: 'NID/Passport Number *',
                    hintText: 'Enter ID number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Upload ID Documents',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (_editGuarantorIdType == 'NID') ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildEditDialogDocBox(
                          'NID Front',
                          _editGuarantorNidFront,
                          _guarantorNidFrontUrls[_editingGuarantorIndex!],
                          () => _pickImage((f) {
                            setDialogState(() => _editGuarantorNidFront = f);
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildEditDialogDocBox(
                          'NID Back',
                          _editGuarantorNidBack,
                          _guarantorNidBackUrls[_editingGuarantorIndex!],
                          () => _pickImage((f) {
                            setDialogState(() => _editGuarantorNidBack = f);
                          }),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _buildEditDialogDocBox(
                    'Passport Copy',
                    _editGuarantorNidFront,
                    _guarantorNidFrontUrls[_editingGuarantorIndex!],
                    () => _pickImage((f) {
                      setDialogState(() => _editGuarantorNidFront = f);
                    }),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_editGuarantorNameController.text.trim().isEmpty ||
                    _editGuarantorPhoneController.text.trim().isEmpty ||
                    _editGuarantorRelationshipController.text.trim().isEmpty ||
                    _editGuarantorNidController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                setState(() {
                  final idx = _editingGuarantorIndex!;
                  _guarantorNameControllers[idx].text =
                      _editGuarantorNameController.text.trim();
                  _guarantorPhoneControllers[idx].text =
                      _editGuarantorPhoneController.text.trim();
                  _guarantorRelationshipControllers[idx].text =
                      _editGuarantorRelationshipController.text.trim();
                  _guarantorNidControllers[idx].text =
                      _editGuarantorNidController.text.trim();
                  _guarantorIdTypes[idx] = _editGuarantorIdType;
                  _guarantorTypes[idx] = _editGuarantorType;
                  _guarantorNidFrontFiles[idx] = _editGuarantorNidFront;
                  _guarantorNidBackFiles[idx] = _editGuarantorNidBack;
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Edit Dialog Document Box ───
  Widget _buildEditDialogDocBox(
    String title,
    File? file,
    String existingUrl,
    VoidCallback onTap,
  ) {
    final hasFile = file != null || existingUrl.isNotEmpty;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: hasFile ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.upload_file,
              color: hasFile ? Colors.green : Colors.blue,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: hasFile ? Colors.green.shade700 : null,
                ),
              ),
            ),
            if (hasFile) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check, color: Colors.green, size: 14),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Remove Guarantor ───
  void _removeGuarantor(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Guarantor'),
        content: const Text('Are you sure you want to remove this guarantor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _guarantorNameControllers[index].dispose();
                _guarantorPhoneControllers[index].dispose();
                _guarantorRelationshipControllers[index].dispose();
                _guarantorNidControllers[index].dispose();

                _guarantorNameControllers.removeAt(index);
                _guarantorPhoneControllers.removeAt(index);
                _guarantorRelationshipControllers.removeAt(index);
                _guarantorNidControllers.removeAt(index);
                _guarantorIdTypes.removeAt(index);
                _guarantorTypes.removeAt(index);
                _guarantorIds.removeAt(index);
                _guarantorNidFrontFiles.removeAt(index);
                _guarantorNidBackFiles.removeAt(index);
                _guarantorNidFrontUrls.removeAt(index);
                _guarantorNidBackUrls.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Build Document Upload Box ───
  Widget _buildDocUploadBox(
    String title,
    File? file,
    String existingUrl,
    VoidCallback onTap,
  ) {
    final hasFile = file != null || existingUrl.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasFile ? AppColors.primaryBlue : Colors.grey.shade300,
            width: hasFile ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: hasFile ? Colors.blue.shade50 : null,
        ),
        child: Row(
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.upload_file,
              color: hasFile ? AppColors.primaryBlue : Colors.blue,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: hasFile ? FontWeight.bold : FontWeight.normal,
                  color: hasFile ? AppColors.primaryBlue : Colors.black87,
                ),
              ),
            ),
            if (hasFile) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check, color: AppColors.primaryBlue, size: 14),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Build Guarantor Editable Card ───
  Widget _buildGuarantorEditableCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Guarantor #${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (_guarantorIds[index].isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'Saved',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showEditGuarantorDialog(index),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    tooltip: 'Edit Guarantor',
                  ),
                  IconButton(
                    onPressed: () => _removeGuarantor(index),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    tooltip: 'Remove Guarantor',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name
          TextFormField(
            controller: _guarantorNameControllers[index],
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter guarantor name',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
          ),
          const SizedBox(height: 10),

          // Phone
          TextFormField(
            controller: _guarantorPhoneControllers[index],
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone *',
              hintText: 'Enter phone number',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            validator: (v) => v?.isEmpty ?? true ? 'Phone is required' : null,
          ),
          const SizedBox(height: 10),

          // Relationship
          TextFormField(
            controller: _guarantorRelationshipControllers[index],
            decoration: const InputDecoration(
              labelText: 'Relationship *',
              hintText: 'e.g. Brother, Friend, Spouse',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            validator: (v) =>
                v?.isEmpty ?? true ? 'Relationship is required' : null,
          ),
          const SizedBox(height: 10),

          // Type & ID Type Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _guarantorTypes[index],
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'FAMILY', child: Text('Family')),
                      DropdownMenuItem(
                        value: 'NON_FAMILY',
                        child: Text('Non-Family'),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _guarantorTypes[index] = val!),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _guarantorIdTypes[index],
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'NID', child: Text('NID')),
                      DropdownMenuItem(
                        value: 'Passport',
                        child: Text('Passport'),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _guarantorIdTypes[index] = val!;
                        if (val == 'Passport') {
                          _guarantorNidBackFiles[index] = null;
                          _guarantorNidBackUrls[index] = '';
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // NID/Passport Number
          TextFormField(
            controller: _guarantorNidControllers[index],
            decoration: const InputDecoration(
              labelText: 'NID/Passport Number *',
              hintText: 'Enter ID number',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            validator: (v) =>
                v?.isEmpty ?? true ? 'ID Number is required' : null,
          ),
          const SizedBox(height: 12),

          // Document Upload Section
          const Text(
            'Upload ID Documents',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),

          if (_guarantorIdTypes[index] == 'NID') ...[
            Row(
              children: [
                Expanded(
                  child: _buildDocUploadBox(
                    'NID Front',
                    _guarantorNidFrontFiles[index],
                    _guarantorNidFrontUrls[index],
                    () => _pickImage((f) {
                      setState(() {
                        _guarantorNidFrontFiles[index] = f;
                        _guarantorNidFrontUrls[index] = '';
                      });
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDocUploadBox(
                    'NID Back',
                    _guarantorNidBackFiles[index],
                    _guarantorNidBackUrls[index],
                    () => _pickImage((f) {
                      setState(() {
                        _guarantorNidBackFiles[index] = f;
                        _guarantorNidBackUrls[index] = '';
                      });
                    }),
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildDocUploadBox(
              'Passport Copy',
              _guarantorNidFrontFiles[index],
              _guarantorNidFrontUrls[index],
              () => _pickImage((f) {
                setState(() {
                  _guarantorNidFrontFiles[index] = f;
                  _guarantorNidFrontUrls[index] = '';
                });
              }),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Status Badge ───
  Widget _buildStatusBadge(String status) {
    Color color = status == 'ACTIVE' ? AppColors.successGreen : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 10),
          const SizedBox(width: 8),
          Text(
            'Status: $status',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Read Only Date Field ───
  Widget _buildReadOnlyDateField({
    required String title,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 8),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.grey,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Date Field ───
  Widget _buildDateField({
    required String title,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isNotEmpty
                        ? controller.text
                        : 'Select Date',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: controller.text.isNotEmpty
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Read Only Card ───
  Widget _buildReadOnlyCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Read Only Field ───
  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String prefix = '',
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade500, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$prefix${controller.text}$suffix',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Read Only Dropdown ───
  Widget _buildReadOnlyDropdownField({
    required String label,
    required String? value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.arrow_drop_down_circle_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Section Title ───
  Widget _buildSectionTitle(String title) {
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

  // ─── Document Section ───
  Widget _buildDocumentSection(dynamic customer) {
    final List<Map<String, String>> docs = [];

    if (customer.customerImageUrl != null &&
        customer.customerImageUrl!.isNotEmpty) {
      docs.add({'label': 'PHOTO', 'url': customer.customerImageUrl!});
    }
    if (customer.customerVideoUrl != null &&
        customer.customerVideoUrl!.isNotEmpty) {
      docs.add({'label': 'VIDEO', 'url': customer.customerVideoUrl!});
    }
    if (customer.nidFront != null && customer.nidFront!.isNotEmpty) {
      docs.add({'label': 'NID FRONT', 'url': customer.nidFront!});
    }
    if (customer.nidBack != null && customer.nidBack!.isNotEmpty) {
      docs.add({'label': 'NID BACK', 'url': customer.nidBack!});
    }
    if (customer.incomeProof != null && customer.incomeProof!.isNotEmpty) {
      docs.add({'label': 'INCOME PROOF', 'url': customer.incomeProof!});
    }
    if (customer.bankReceiptUrl != null &&
        customer.bankReceiptUrl!.isNotEmpty) {
      docs.add({'label': 'BANK RECEIPT', 'url': customer.bankReceiptUrl!});
    }
    if (customer.profileImage != null && customer.profileImage!.isNotEmpty) {
      docs.add({'label': 'PROFILE', 'url': customer.profileImage!});
    }

    if (customer.documents != null && customer.documents!.isNotEmpty) {
      for (var doc in customer.documents!) {
        String url = doc.url ?? '';
        String docType = doc.documentType ?? 'DOCUMENT';
        if (url.isNotEmpty) {
          String label = _getDocumentLabel(docType);
          bool exists = docs.any((d) => d['url'] == url);
          if (!exists) {
            docs.add({'label': label, 'url': url});
          }
        }
      }
    }

    if (docs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.cloud_off_rounded, size: 48, color: Color(0xFF94A3B8)),
              SizedBox(height: 8),
              Text(
                'No documents uploaded',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final doc = docs[index];
          final isVideo = doc['label'] == 'VIDEO' || doc['label'] == 'Video';
          return _buildDocThumbnail(
            label: doc['label']!,
            url: doc['url']!,
            isVideo: isVideo,
          );
        },
      ),
    );
  }

  String _getDocumentLabel(String docType) {
    final type = docType.toUpperCase();
    if (type.contains('PHOTO') || type.contains('CUSTOMER_PHOTO'))
      return 'PHOTO';
    if (type.contains('VIDEO') || type.contains('CUSTOMER_VIDEO'))
      return 'VIDEO';
    if (type.contains('NID_FRONT')) return 'NID FRONT';
    if (type.contains('NID_BACK')) return 'NID BACK';
    if (type.contains('INCOME')) return 'INCOME PROOF';
    if (type.contains('BANK')) return 'BANK RECEIPT';
    if (type.contains('GUARANTOR')) return 'GUARANTOR DOC';
    return docType.replaceAll('_', ' ').toUpperCase();
  }

  Widget _buildDocThumbnail({
    required String label,
    required String url,
    bool isVideo = false,
  }) {
    if (url.isEmpty) return const SizedBox.shrink();

    final fullUrl = ApiEndPoint.assetUrl(url);

    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              onTap: () {
                if (isVideo) {
                  _showVideoPlayer(context, fullUrl, label);
                } else {
                  _showFullScreenImage(context, fullUrl, label);
                }
              },
              child: Container(
                height: 90,
                width: 110,
                color: Colors.grey[200],
                child: isVideo
                    ? Container(
                        color: Colors.black,
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '▶ Video',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Image.network(
                        fullUrl,
                        height: 90,
                        width: 110,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 90,
                            width: 110,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          height: 90,
                          width: 110,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No Image',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ─── Video Player ───
  void _showVideoPlayer(BuildContext context, String videoUrl, String title) {
    final controller = VideoPlayerController.network(videoUrl);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FutureBuilder(
              future: controller.initialize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Loading video...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Failed to load video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                controller.play();
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (controller.value.isPlaying) {
                                    controller.pause();
                                  } else {
                                    controller.play();
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                controller.dispose();
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Positioned(
                          bottom: 45,
                          left: 16,
                          right: 16,
                          child: VideoProgressIndicator(
                            controller,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: Colors.blue,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ─── Full Screen Image ───
  void _showFullScreenImage(
    BuildContext context,
    String imageUrl,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.9)),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (_, __, ___) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Active Loan Card ───
  Widget _buildActiveLoanCard(dynamic loan, NumberFormat currency) {
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
                loan.productName ?? 'N/A',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (loan.status == 'ACTIVE')
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loan.status ?? 'N/A',
                  style: TextStyle(
                    color: (loan.status == 'ACTIVE')
                        ? Colors.green
                        : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLoanStat(
                'Total',
                '৳${currency.format(loan.totalAmount ?? 0)}',
              ),
              _buildLoanStat(
                'Paid',
                '৳${currency.format(loan.paidAmount ?? 0)}',
                color: Colors.green,
              ),
              _buildLoanStat(
                'Remaining',
                '৳${currency.format(loan.remainingAmount ?? 0)}',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoanStat(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  void _saveCustomer() {
    // ─── Step 1: Validate Form ───
    if (!_formKey.currentState!.validate()) {
      debugPrint(' [EditCustomer] Form validation failed');
      return;
    }

    // ─── Step 2: Get Customer Data ───
    final viewModel = context.read<CustomerEditViewModel>();
    final customer = viewModel.customerData;

    if (customer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer data not found!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ─── Step 3: Build Update Data ───
    final Map<String, dynamic> updatedData = {};

    // ─── 3.1: Required Fields ───
    updatedData['name'] = customer.name ?? '';
    updatedData['phone'] = customer.phone ?? '';
    updatedData['monthlyPaymentDate'] = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedMonthlyPaymentDate);

    // ─── 3.2: 🔥 HIERARCHY FIELDS ───
    updatedData['shopId'] = customer.shopId ?? '';
    updatedData['agentId'] = customer.agentId ?? '';
    updatedData['managerId'] = customer.managerId ?? '';
    updatedData['salesPersonId'] = customer.salesPersonId ?? '';

    // ─── 3.3: 🔥 PRODUCT FIELDS (REQUIRED) ───
    updatedData['productId'] = customer.productId ?? '';
    updatedData['productModelId'] = customer.productModelId ?? '';
    updatedData['mrp'] = customer.mrp ?? '0';
    updatedData['downPayment'] = customer.downPayment ?? '0';
    updatedData['emiCharge'] = customer.emiCharge ?? '0';
    updatedData['monthlyEmi'] = customer.monthlyEmi ?? '0';
    updatedData['emiTenureMonths'] =
        customer.emiTenureMonths?.toString() ?? '0';

    // ─── 3.4: Optional Fields ───
    if (customer.email != null && customer.email!.isNotEmpty) {
      updatedData['email'] = customer.email;
    }
    if (customer.presentAddress != null &&
        customer.presentAddress!.isNotEmpty) {
      updatedData['presentAddress'] = customer.presentAddress;
    }
    if (customer.permanentAddress != null &&
        customer.permanentAddress!.isNotEmpty) {
      updatedData['permanentAddress'] = customer.permanentAddress;
    }
    if (customer.nidPassportNumber != null &&
        customer.nidPassportNumber!.isNotEmpty) {
      updatedData['nidPassportNumber'] = customer.nidPassportNumber;
    }
    if (customer.idType != null && customer.idType!.isNotEmpty) {
      updatedData['idType'] = customer.idType;
    }
    if (customer.sourceOfIncome != null &&
        customer.sourceOfIncome!.isNotEmpty) {
      updatedData['sourceOfIncome'] = customer.sourceOfIncome;
    }
    if (customer.monthlyIncome != null && customer.monthlyIncome!.isNotEmpty) {
      updatedData['monthlyIncome'] = customer.monthlyIncome;
    }
    if (customer.status != null && customer.status!.isNotEmpty) {
      updatedData['status'] = customer.status;
    }
    if (customer.downPaymentMethod != null &&
        customer.downPaymentMethod!.isNotEmpty) {
      updatedData['downPaymentMethod'] = customer.downPaymentMethod;
    }
    if (customer.bankAccountName != null &&
        customer.bankAccountName!.isNotEmpty) {
      updatedData['bankAccountName'] = customer.bankAccountName;
    }
    if (customer.bankAccountNumber != null &&
        customer.bankAccountNumber!.isNotEmpty) {
      updatedData['bankAccountNumber'] = customer.bankAccountNumber;
    }
    if (customer.bankName != null && customer.bankName!.isNotEmpty) {
      updatedData['bankName'] = customer.bankName;
    }
    if (customer.downPaymentReferenceNumber != null &&
        customer.downPaymentReferenceNumber!.isNotEmpty) {
      updatedData['downPaymentReferenceNumber'] =
          customer.downPaymentReferenceNumber;
    }

    // ─── 3.5: Guarantors Data ───
    final List<Map<String, dynamic>> guarantorsList = [];

    for (int i = 0; i < _guarantorNameControllers.length; i++) {
      final name = _guarantorNameControllers[i].text.trim();
      final phone = _guarantorPhoneControllers[i].text.trim();
      final relationship = _guarantorRelationshipControllers[i].text.trim();
      final nidNumber = _guarantorNidControllers[i].text.trim();

      if (name.isEmpty ||
          phone.isEmpty ||
          relationship.isEmpty ||
          nidNumber.isEmpty) {
        debugPrint(
          '⚠️ [EditCustomer] Guarantor #${i + 1} has empty fields, skipping...',
        );
        continue;
      }

      final guarantorData = {
        'name': name,
        'phone': phone,
        'relationship': relationship,
        'type': _guarantorTypes[i],
        'idType': _guarantorIdTypes[i],
        'nidPassportNumber': nidNumber,
      };

      if (_guarantorIds[i].isNotEmpty) {
        guarantorData['id'] = _guarantorIds[i];
      }

      if (_guarantorNidFrontUrls[i].isNotEmpty) {
        guarantorData['nidFront'] = _guarantorNidFrontUrls[i];
      }
      if (_guarantorNidBackUrls[i].isNotEmpty) {
        guarantorData['nidBack'] = _guarantorNidBackUrls[i];
      }

      guarantorsList.add(guarantorData);
    }

    updatedData['guarantors'] = jsonEncode(guarantorsList);

    // ─── Step 4: Debug Log ───
    debugPrint('════════════════════════════════════════════════════════');
    debugPrint('🚀 [EditCustomer] UPDATE REQUEST');
    debugPrint('📋 Customer ID : ${widget.customerId}');
    debugPrint('📋 Name        : ${updatedData['name']}');
    debugPrint('📋 Phone       : ${updatedData['phone']}');
    debugPrint('📋 Monthly Date: ${updatedData['monthlyPaymentDate']}');
    debugPrint('🏪 Shop ID     : ${updatedData['shopId']}');
    debugPrint('👤 Agent ID    : ${updatedData['agentId']}');
    debugPrint('👤 Manager ID  : ${updatedData['managerId']}');
    debugPrint('👤 Sales ID    : ${updatedData['salesPersonId']}');
    debugPrint('📦 Product ID  : ${updatedData['productId']}');
    debugPrint('📦 ProductModel: ${updatedData['productModelId']}');
    debugPrint('💰 MRP         : ${updatedData['mrp']}');
    debugPrint('💰 Down Payment: ${updatedData['downPayment']}');
    debugPrint('💰 EMI Charge  : ${updatedData['emiCharge']}');
    debugPrint('💰 Monthly EMI : ${updatedData['monthlyEmi']}');
    debugPrint('📅 EMI Tenure  : ${updatedData['emiTenureMonths']}');
    debugPrint('👥 Guarantors  : ${guarantorsList.length}');
    debugPrint('📦 Full Payload: ${jsonEncode(updatedData)}');
    debugPrint('════════════════════════════════════════════════════════');

    // ─── Step 5: Show Loading ───
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Updating Customer...'),
              ],
            ),
          ),
        ),
      ),
    );

    // ─── Step 6: Call API ───
    viewModel
        .updateCustomer(customerId: widget.customerId, updatedData: updatedData)
        .then((success) {
          Navigator.pop(context);

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Customer updated successfully!'),
                backgroundColor: AppColors.successGreen,
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '❌ ${viewModel.errorMessage ?? 'Failed to update'}',
                ),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        })
        .catchError((error) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: $error'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        });
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
          'Edit Customer',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveCustomer,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<CustomerEditViewModel>(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          viewModel.fetchCustomerDetail(widget.customerId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final customer = viewModel.customerData;
          if (customer == null) {
            return const Center(child: Text('No details found'));
          }

          if (_nameController == null) {
            _initControllers(customer);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Customer ID ───
                  _buildReadOnlyCard(
                    icon: Icons.person_outline,
                    label: 'Customer ID: ',
                    value: customer.displayId ?? 'N/A',
                  ),
                  const SizedBox(height: 16),

                  // ─── Status ───
                  _buildStatusBadge(customer.status ?? 'ACTIVE'),
                  const SizedBox(height: 16),

                  // ─── Monthly Payment Date ───
                  _buildDateField(
                    title: 'Monthly Payment Date',
                    controller: _monthlyPaymentDateController!,
                    onTap: () => _selectMonthlyPaymentDate(context),
                  ),
                  const SizedBox(height: 16),

                  // ─── Issue Date ───
                  _buildReadOnlyDateField(
                    title: 'Issue Date',
                    controller: _issueDateController!,
                  ),
                  const SizedBox(height: 16),

                  // ─── Personal Information ───
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _nameController!,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _phoneController!,
                    label: 'Phone',
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _emailController!,
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyDropdownField(
                    label: 'ID Type',
                    value: _selectedIdType,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _nidController!,
                    label: 'NID/Passport Number',
                    icon: Icons.credit_card_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _incomeSourceController!,
                    label: 'Source of Income',
                    icon: Icons.work_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _monthlyIncomeController!,
                    label: 'Monthly Income',
                    icon: Icons.currency_exchange_rounded,
                    prefix: '৳ ',
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _presentAddressController!,
                    label: 'Present Address',
                    icon: Icons.home_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _permanentAddressController!,
                    label: 'Permanent Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // ─── Store Information ───
                  _buildSectionTitle('Store Information'),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _shopNameController!,
                    label: 'Shop',
                    icon: Icons.storefront_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _agentNameController!,
                    label: 'Agent',
                    icon: Icons.person_search_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _managerNameController!,
                    label: 'Manager',
                    icon: Icons.manage_accounts_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _salesPersonNameController!,
                    label: 'Sales Person',
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),

                  // ─── Product Information ───
                  _buildSectionTitle('Product Information'),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _productNameController!,
                    label: 'Product Name',
                    icon: Icons.phone_iphone_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _mrpController!,
                    label: 'MRP Price',
                    icon: Icons.sell_outlined,
                    prefix: '৳ ',
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _downPaymentController!,
                    label: 'Down Payment',
                    icon: Icons.payments_outlined,
                    prefix: '৳ ',
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _emiChargeController!,
                    label: 'EMI Charge',
                    icon: Icons.percent_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _emiTenureController!,
                    label: 'EMI Tenure',
                    icon: Icons.calendar_month_outlined,
                    suffix: ' Months',
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _monthlyEmiController!,
                    label: 'Monthly EMI',
                    icon: Icons.account_balance_wallet_outlined,
                    prefix: '৳ ',
                  ),
                  const SizedBox(height: 16),

                  // ─── Bank Details ───
                  _buildSectionTitle('Bank Details'),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _bankAccountNameController!,
                    label: 'Bank Account Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _bankAccountNumberController!,
                    label: 'Bank Account Number',
                    icon: Icons.numbers_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _bankNameController!,
                    label: 'Bank Name',
                    icon: Icons.account_balance_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildReadOnlyField(
                    controller: _referenceNumberController!,
                    label: 'Reference Number',
                    icon: Icons.receipt_outlined,
                  ),
                  const SizedBox(height: 16),

                  // ─── Documents ───
                  _buildSectionTitle('Documents'),
                  const SizedBox(height: 12),
                  _buildDocumentSection(customer),
                  const SizedBox(height: 16),

                  // ─── Active Loans ───
                  if (customer.activeLoans != null &&
                      customer.activeLoans!.isNotEmpty) ...[
                    _buildSectionTitle('Active Loans'),
                    const SizedBox(height: 12),
                    ...customer.activeLoans!.map(
                      (loan) => _buildActiveLoanCard(loan, currency),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ─── Guarantors ───
                  _buildSectionTitle('Guarantors'),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: _showAddGuarantorDialog,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Guarantor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_guarantorNameControllers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Text(
                          'No guarantors added',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_guarantorNameControllers.length, (index) {
                      return _buildGuarantorEditableCard(index);
                    }),

                  const SizedBox(height: 20),

                  // ─── Save Button ───
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: viewModel.isLoading ? null : _saveCustomer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: viewModel.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
