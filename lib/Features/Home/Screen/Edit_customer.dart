// lib/features/customer/screens/edit_customer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
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

  // ✅ Nullable Controller
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

  String? _selectedIdType;
  String? _selectedStatus;
  DateTime _selectedMonthlyPaymentDate = DateTime.now();
  DateTime _selectedIssueDate = DateTime.now();

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
    super.dispose();
  }

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
  }

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

                  // ─── Monthly Payment Date (Editable) ✅ ───
                  _buildDateField(
                    title: 'Monthly Payment Date',
                    controller: _monthlyPaymentDateController!,
                    onTap: () => _selectMonthlyPaymentDate(context),
                  ),
                  const SizedBox(height: 16),

                  // ─── Issue Date (Read Only) ───
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
                  if (customer.guarantors != null &&
                      customer.guarantors!.isNotEmpty) ...[
                    _buildSectionTitle('Guarantors'),
                    const SizedBox(height: 12),
                    ...customer.guarantors!.map((g) => _buildGuarantorCard(g)),
                    const SizedBox(height: 16),
                  ],

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

  // ─── Date Field (Editable) ───
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

  // lib/features/customer/screens/edit_customer.dart

  // ─── Document Section ───
  // ─── Document Section ───
  Widget _buildDocumentSection(dynamic customer) {
    final List<Map<String, String>> docs = [];

    // ✅ customer যদি EditData হয়, তাহলে সরাসরি ফিল্ড চেক করুন
    if (customer == null) {
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

    debugPrint('📄 [EditCustomer] Building Document Section');

    // ─── Customer Documents ───
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

    // ─── Documents from documents array ───
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

    debugPrint('📄 [EditCustomer] Total Documents Found: ${docs.length}');
    for (var doc in docs) {
      debugPrint('📄 [EditCustomer] - ${doc['label']}: ${doc['url']}');
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

  // ─── Document Label Helper ───
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

  // ─── Document Thumbnail ───
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
    debugPrint('🎬 [VideoPlayer] Opening video: $videoUrl');

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
                  color: (loan.status == 'ACTIVE' || loan.status == 'ACTIVE')
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loan.status ?? 'N/A',
                  style: TextStyle(
                    color: (loan.status == 'ACTIVE' || loan.status == 'ACTIVE')
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

  // ─── Guarantor Card ───
  // lib/features/customer/screens/edit_customer.dart

  // ─── Guarantor Card ───
  Widget _buildGuarantorCard(dynamic g) {
    // ✅ Guarantor এর ডকুমেন্ট সংগ্রহ করুন
    final List<Map<String, String>> docs = [];

    // NID Front
    if (g.nidFront != null && g.nidFront!.isNotEmpty) {
      docs.add({'label': 'NID FRONT', 'url': g.nidFront!});
    }

    // NID Back
    if (g.nidBack != null && g.nidBack!.isNotEmpty) {
      docs.add({'label': 'NID BACK', 'url': g.nidBack!});
    }

    // Guarantor এর Documents array থেকে
    if (g.documents != null && g.documents!.isNotEmpty) {
      for (var doc in g.documents!) {
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

    debugPrint('📄 [Guarantor] Total Documents Found: ${docs.length}');
    for (var doc in docs) {
      debugPrint('📄 [Guarantor] - ${doc['label']}: ${doc['url']}');
    }

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
          // ─── Guarantor Header ───
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                child: Text(
                  g.name?[0]?.toUpperCase() ?? 'G',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.name ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${g.relationship ?? 'N/A'} • ${g.phone ?? 'N/A'}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: g.type == 'FAMILY'
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  g.type ?? 'N/A',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: g.type == 'FAMILY' ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${g.idType ?? g.documentType ?? 'NID'}: ${g.nidPassportNumber ?? 'N/A'}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),

          // ✅ ─── Guarantor Documents (Horizontal Scroll) ───
          if (docs.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 12),
            const Text(
              'Documents',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final isVideo =
                      doc['label'] == 'VIDEO' || doc['label'] == 'Video';
                  return _buildSmallDocThumbnailWithLabel(
                    label: doc['label']!,
                    url: doc['url']!,
                    isVideo: isVideo,
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Small Document Thumbnail with Label ───
  Widget _buildSmallDocThumbnailWithLabel({
    required String label,
    required String url,
    bool isVideo = false,
  }) {
    if (url.isEmpty) return const SizedBox.shrink();

    final fullUrl = ApiEndPoint.assetUrl(url);

    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 80,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (isVideo) {
                _showVideoPlayer(context, fullUrl, label);
              } else {
                _showFullScreenImage(context, fullUrl, label);
              }
            },
            child: Container(
              height: 65,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: isVideo
                    ? null
                    : DecorationImage(
                        image: NetworkImage(fullUrl),
                        fit: BoxFit.cover,
                      ),
              ),
              child: isVideo
                  ? Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
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

  Widget _buildSmallDocThumbnail(String label, String url) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 60,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      child: Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─── Save Customer ───
// lib/features/customer/screens/edit_customer.dart

// ─── Save Customer ───
// lib/features/customer/screens/edit_customer.dart

// ─── Save Customer ───
  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      // ✅ সব ডেটা পাঠান (শুধু Date পরিবর্তন হবে)
      final updatedData = {
        'name': _nameController?.text.trim() ?? '',
        'phone': _phoneController?.text.trim() ?? '',
        'email': _emailController?.text.trim() ?? '',
        'idType': _selectedIdType ?? 'NID',
        'nidPassportNumber': _nidController?.text.trim() ?? '',
        'sourceOfIncome': _incomeSourceController?.text.trim() ?? '',
        'monthlyIncome': double.tryParse(_monthlyIncomeController?.text ?? '0') ?? 0,
        'presentAddress': _presentAddressController?.text.trim() ?? '',
        'permanentAddress': _permanentAddressController?.text.trim() ?? '',
        'status': _selectedStatus ?? 'ACTIVE',
        'monthlyPaymentDate': DateFormat('yyyy-MM-dd').format(_selectedMonthlyPaymentDate),
      };

      final viewModel = context.read<CustomerEditViewModel>();

      viewModel.updateCustomer(
        customerId: widget.customerId,
        updatedData: updatedData,
      ).then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Monthly payment date updated successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(viewModel.errorMessage ?? 'Failed to update date'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      });
    }
  }
}
