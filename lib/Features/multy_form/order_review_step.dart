import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/multy_form/viewModel/multyform_provider.dart';
import '../../../../core/constant/App_Colors.dart';
import 'model/dropdown_item_model.dart';
import 'package:intl/intl.dart';

class OrderReviewStep extends StatelessWidget {
  final VoidCallback onNext;

  const OrderReviewStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CheckoutViewModel>(context);
    final order = vm.checkoutData;

    if (vm.isFetchingDropdowns) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryBlue),
            const SizedBox(height: 12),
            const Text("Loading data from server...", style: TextStyle(color: AppColors.greyText)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order & Plan Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Verify store details and selected plan pricing',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),

          // 🔹 1. Store Assignment Section
          _buildSectionTitle("Store Assignment"),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Select Shop *',
            value: order.shopId,
            items: _buildDropdownItems(vm.shopList),
            onChanged: (val) => vm.onShopSelected(val),
            icon: Icons.storefront_rounded,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Agent *',
                  value: order.agentId,
                  items: _buildDropdownItems(vm.agentList),
                  onChanged: (val) => vm.onAgentSelected(val),
                  icon: Icons.person_search_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'Manager *',
                  value: order.managerId,
                  items: _buildDropdownItems(vm.managerList),
                  onChanged: (val) => vm.onManagerSelected(val),
                  icon: Icons.manage_accounts_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildDropdownField(
            label: 'Sales Person *',
            value: order.salesPersonId,
            items: _buildDropdownItems(vm.salesPersonList),
            onChanged: (val) => vm.onSalesPersonSelected(val),
            icon: Icons.badge_outlined,
          ),
          
          const SizedBox(height: 32),
          _buildSectionTitle("Product Selection"),
          const SizedBox(height: 16),

          // 🔹 2. Product Selection
          _buildDropdownField(
            label: 'Select Product *',
            value: order.productId,
            items: _buildDropdownItems(vm.productList),
            onChanged: (val) => vm.onProductSelected(val),
            icon: Icons.phone_iphone_rounded,
          ),
          const SizedBox(height: 20),

          // 🔹 📦 Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Column(
              children: [
                _buildSummaryRow(Icons.sell_outlined, 'Price (MRP):', '৳${NumberFormat('#,##,###').format(order.mrp)}', isBold: true),
                if (order.saleType == 'EMI') ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5, color: Color(0xFFF1F5F9)),
                  ),
                  _buildSummaryRow(Icons.calendar_today_outlined, 'Tenure:', '${order.emiTenureMonths} Months'),
                  const SizedBox(height: 12),
                  _buildSummaryRow(Icons.payments_outlined, 'Downpayment:', '৳${NumberFormat('#,##,###').format(order.downPayment)}'),
                  const SizedBox(height: 12),
                  _buildSummaryRow(Icons.percent_rounded, 'Charge Rate:', '${order.appEmiChargeRate}%'),
                  const Divider(height: 24, thickness: 0.5, color: Color(0xFFF1F5F9)),
                  _buildSummaryRow(Icons.account_balance_wallet_outlined, 'Monthly EMI:', '৳${NumberFormat('#,##,###').format(order.monthlyEmi)}', isBold: true, isBlue: true),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 🔹 3. Payment Flow Selection
          _buildSectionTitle("Payment Flow"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRadioTile(
                  title: 'EMI Plan',
                  value: 'EMI',
                  groupValue: order.saleType,
                  onChanged: (val) {
                    order.saleType = val!;
                    vm.notify();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioTile(
                  title: 'MRP',
                  value: 'Selling Price',
                  groupValue: order.saleType,
                  onChanged: (val) {
                    order.saleType = val!;
                    vm.notify();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 🔹 4. EMI Configuration
          if (order.saleType == 'EMI') ...[
            _buildEmiCalculationOptions(vm, order),
          ],

          const SizedBox(height: 40),

          // 🔹 Next Step Action
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Next Step', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 1.2),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, {bool isBold = false, bool isBlue = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isBlue ? AppColors.primaryBlue.withOpacity(0.1) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isBlue ? AppColors.primaryBlue : const Color(0xFF64748B), size: 18),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B), fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold || isBlue ? FontWeight.w900 : FontWeight.w700,
            fontSize: isBold || isBlue ? 18 : 15,
            color: isBlue ? AppColors.primaryBlue : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildEmiCalculationOptions(CheckoutViewModel vm, var order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("EMI Configuration"),
        const SizedBox(height: 16),
        _buildEmiOptionRadio(
          title: 'Existing EMI Plan',
          subtitle: 'Use pre-defined shop duration & rates',
          value: 'EXISTING_PLAN',
          groupValue: order.emiMode,
          onChanged: (val) {
            order.emiMode = val!;
            vm.notify();
          },
        ),
        _buildEmiOptionRadio(
          title: 'Custom EMI Plan',
          subtitle: 'Create a new plan for this customer',
          value: 'CREATE_NEW_PLAN',
          groupValue: order.emiMode,
          onChanged: (val) {
            order.emiMode = val!;
            vm.notify();
          },
        ),
        _buildEmiOptionRadio(
          title: 'Remaining Balance EMI',
          subtitle: 'Calculate based on custom upfront',
          value: 'REMAINING_BALANCE',
          groupValue: order.emiMode,
          onChanged: (val) {
            order.emiMode = val!;
            vm.notify();
          },
        ),
        const SizedBox(height: 20),

        if (order.emiMode == 'EXISTING_PLAN') ...[
          _buildDropdownField(
            label: 'Choose EMI Plan *',
            value: order.emiPlanId,
            items: _buildDropdownItems(vm.emiPlanList),
            onChanged: (val) => vm.onEmiPlanSelected(val),
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSummaryBox('Down Payment', '৳${NumberFormat('#,###').format(order.downPayment)}')),
              const SizedBox(width: 12),
              Expanded(child: _buildSummaryBox('Monthly EMI', '৳${NumberFormat('#,###').format(order.monthlyEmi)}')),
            ],
          ),
        ],

        if (order.emiMode == 'CREATE_NEW_PLAN') ...[
           _buildCustomPlanFields(vm, order),
        ],

        if (order.emiMode == 'REMAINING_BALANCE') ...[
           _buildRemainingBalanceFields(vm, order),
        ],
      ],
    );
  }

  Widget _buildCustomPlanFields(CheckoutViewModel vm, var order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _buildTextField(
            label: 'Plan Name',
            hint: 'e.g. Special 3 Month Plan',
            initialValue: order.newPlanName,
            onChanged: (v) {
              order.newPlanName = v;
              vm.notify();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Months',
                  hint: '3',
                  keyboardType: TextInputType.number,
                  initialValue: order.newPlanMonths.toString(),
                  onChanged: (v) {
                    order.newPlanMonths = int.tryParse(v) ?? 3;
                    vm.notify();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  label: order.downPaymentCalculationType == 'RATE' ? 'DP Rate %' : 'DP Amount ৳',
                  hint: '20',
                  keyboardType: TextInputType.number,
                  initialValue: order.downPaymentCalculationType == 'RATE' ? order.downPaymentCalculationRate : order.downPaymentAmount,
                  onChanged: (v) {
                    if (order.downPaymentCalculationType == 'RATE') {
                      order.downPaymentCalculationRate = v;
                    } else {
                      order.downPaymentAmount = v;
                    }
                    vm.notify();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Charge Rate (%)',
            hint: '5',
            keyboardType: TextInputType.number,
            initialValue: order.appEmiChargeRate,
            onChanged: (v) {
              order.appEmiChargeRate = v;
              vm.notify();
            },
          ),
          const Divider(height: 32, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calculated EMI:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              Text('৳${NumberFormat('#,###').format(order.monthlyEmi)}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryBlue, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingBalanceFields(CheckoutViewModel vm, var order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTextField(
              label: 'Upfront (৳)',
              hint: '10000',
              keyboardType: TextInputType.number,
              initialValue: order.customUpfrontPayment > 0 ? order.customUpfrontPayment.toString() : '',
              onChanged: (v) {
                order.customUpfrontPayment = double.tryParse(v) ?? 0;
                vm.notify();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextField(
              label: 'Duration',
              hint: '6 Mos',
              keyboardType: TextInputType.number,
              initialValue: order.customEmiDurationMonths.toString(),
              onChanged: (v) {
                order.customEmiDurationMonths = int.tryParse(v) ?? 6;
                vm.notify();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── Helper UI Widgets ──────────────

  List<DropdownMenuItem<String>> _buildDropdownItems(List<DropdownItemModel> items) {
    return items.map((item) {
      return DropdownMenuItem<String>(
        value: item.id,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            item.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    bool isValueValid = items.any((element) => element.value == value);
    String? safeValue = isValueValid ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: safeValue,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          menuMaxHeight: 280,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Colors.white,
          elevation: 8,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primaryBlue,
            size: 24,
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(icon, size: 20, color: AppColors.primaryBlue),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRadioTile({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withOpacity(0.05) : Colors.white,
          border: Border.all(color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, size: 18, color: isSelected ? AppColors.primaryBlue : const Color(0xFFCBD5E1)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? AppColors.primaryBlue : AppColors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmiOptionRadio({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8FAFC),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0), width: isSelected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primaryBlue,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primaryBlue : const Color(0xFF0F172A))),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? initialValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.normal),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBox(String title, String amount) {
    return Container(
      padding: const EdgeInsets.all(14),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(amount, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
