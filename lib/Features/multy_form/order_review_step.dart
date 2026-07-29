import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/Features/multy_form/viewModel/multyform_provider.dart';
import 'model/dropdown_item_model.dart';

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
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text("Loading data from server..."),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select store details and EMI plans',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // 🔹 1. Shop Dropdown
          _buildDropdownField(
            label: 'Select Shop *',
            value: order.shopId,
            items: _buildDropdownItems(vm.shopList),
            onChanged: (val) => vm.onShopSelected(val),
          ),
          const SizedBox(height: 12),

          // 🔹 2. Agent & Manager Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Agent *',
                  value: order.agentId,
                  items: _buildDropdownItems(vm.agentList),
                  onChanged: (val) => vm.onAgentSelected(val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'Manager *',
                  value: order.managerId,
                  items: _buildDropdownItems(vm.managerList),
                  onChanged: (val) => vm.onManagerSelected(val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 🔹 3. Sales Person
          _buildDropdownField(
            label: 'Sales Person *',
            value: order.salesPersonId,
            items: _buildDropdownItems(vm.salesPersonList),
            onChanged: (val) => vm.onSalesPersonSelected(val),
          ),
          const SizedBox(height: 12),

          // 🔹 4. Product Dropdown
          _buildDropdownField(
            label: 'Select Product *',
            value: order.productId,
            items: _buildDropdownItems(vm.productList),
            onChanged: (val) => vm.onProductSelected(val),
          ),
          const SizedBox(height: 16),

          // 🔹 Product Price Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Product Price (MRP):', style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '৳ ${order.mrp.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 5. Sale Type (EMI / Full Price)
          const Text('Sale Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildRadioTile(
                  title: 'EMI Plan',
                  value: 'EMI',
                  groupValue: order.saleType,
                  onChanged: (val) {
                    order.saleType = val!;
                    vm.notifyListeners();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRadioTile(
                  title: 'Full Price',
                  value: 'Selling Price',
                  groupValue: order.saleType,
                  onChanged: (val) {
                    order.saleType = val!;
                    vm.notifyListeners();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔹 6. EMI Mode Selection & Dynamic Fields
          if (order.saleType == 'EMI') ...[
            const Text('EMI Calculation Option *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),

            // Mode 1: Existing Plan
            _buildEmiOptionRadio(
              title: 'Select Existing EMI Plan',
              subtitle: 'Choose from pre-defined shop plans',
              value: 'EXISTING_PLAN',
              groupValue: order.emiMode,
              onChanged: (val) {
                order.emiMode = val!;
                vm.notifyListeners();
              },
            ),

            // Mode 2: Create New Plan
            _buildEmiOptionRadio(
              title: 'Create New EMI Plan',
              subtitle: 'Define custom plan rates and months',
              value: 'CREATE_NEW_PLAN',
              groupValue: order.emiMode,
              onChanged: (val) {
                order.emiMode = val!;
                vm.notifyListeners();
              },
            ),

            // Mode 3: Remaining Balance
            _buildEmiOptionRadio(
              title: 'EMI on Remaining Balance',
              subtitle: 'Custom duration on upfront payment',
              value: 'REMAINING_BALANCE',
              groupValue: order.emiMode,
              onChanged: (val) {
                order.emiMode = val!;
                vm.notifyListeners();
              },
            ),

            const SizedBox(height: 16),

            // 🟢 SECTION A: Existing Plan Form
            if (order.emiMode == 'EXISTING_PLAN') ...[
              _buildDropdownField(
                label: 'Select EMI Plan *',
                value: order.emiPlanId,
                items: _buildDropdownItems(vm.emiPlanList),
                onChanged: (val) => vm.onEmiPlanSelected(val),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryBox('Down Payment', '৳ ${order.downPayment.toStringAsFixed(0)}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryBox('Monthly EMI', '৳ ${order.monthlyEmi.toStringAsFixed(0)}/mo'),
                  ),
                ],
              ),
            ],

            // 🟢 SECTION B: Create New Plan Form
            if (order.emiMode == 'CREATE_NEW_PLAN') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('New Plan Config', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 10),
                    _buildTextField(
                      label: 'Plan Name',
                      hint: 'e.g. 3 Month Custom Plan',
                      initialValue: order.newPlanName,
                      onChanged: (v) => order.newPlanName = v,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Duration (Months)',
                            hint: '3',
                            keyboardType: TextInputType.number,
                            initialValue: order.newPlanMonths.toString(),
                            onChanged: (v) => order.newPlanMonths = int.tryParse(v) ?? 3,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            label: 'Down Payment (%)',
                            hint: '20',
                            keyboardType: TextInputType.number,
                            initialValue: order.downPaymentCalculationRate,
                            onChanged: (v) => order.downPaymentCalculationRate = v,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // 🟢 SECTION C: Remaining Balance Form
            if (order.emiMode == 'REMAINING_BALANCE') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Remaining Balance Config', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Upfront Payment (৳)',
                            hint: '10000',
                            keyboardType: TextInputType.number,
                            initialValue: order.customUpfrontPayment > 0 ? order.customUpfrontPayment.toString() : '',
                            onChanged: (v) => order.customUpfrontPayment = double.tryParse(v) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            label: 'Duration (Months)',
                            hint: '6',
                            keyboardType: TextInputType.number,
                            initialValue: order.customEmiDurationMonths.toString(),
                            onChanged: (v) => order.customEmiDurationMonths = int.tryParse(v) ?? 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],

          // 🔹 Next Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Next Step', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        child: Text(item.name, overflow: TextOverflow.ellipsis),
      );
    }).toList();
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    bool isValueValid = items.any((element) => element.value == value);
    String? safeValue = isValueValid ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: safeValue,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
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
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFF2563EB),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: const Color(0xFF2563EB),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        dense: true,
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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBox(String title, String amount) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
