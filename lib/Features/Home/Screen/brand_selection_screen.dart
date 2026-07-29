import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/core/routes/Routes_name.dart';
import '../../../core/constant/Api_End_point.dart';
import '../Model/PhoneProductModel.dart';
import '../ViewModel/Brand_Selection_Model.dart';

class BrandSelectionScreen extends StatefulWidget {
  const BrandSelectionScreen({super.key});

  @override
  State<BrandSelectionScreen> createState() => _BrandSelectionScreenState();
}

class _BrandSelectionScreenState extends State<BrandSelectionScreen> {
  // Brand Primary Color (Dark Blue) matching image
  static const Color primaryBlue = Color(0xFF0044B4);
  static const Color accentBlue = Color(0xFF003882);
  static const Color bgGrey = Color(0xFFF4F6F9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandSelectionViewModel>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BrandSelectionViewModel>();

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text(
          "SmartPay Catalog",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: accentBlue,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryBlue))
          : vm.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                    ),
                    onPressed: () => vm.fetchProducts(),
                    child: const Text(
                      "Retry",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductDropdown(vm),
                  const SizedBox(height: 12),
                  _buildPurchaseModeSelector(vm),
                  const SizedBox(height: 14),

                  if (vm.selectedProduct != null) ...[
                    _buildProductHeader(vm.selectedProduct!),
                    const SizedBox(height: 14),
                  ],

                  if (vm.selectedPurchaseType == 'EMI') ...[
                    _buildEmiCalculatorCard(vm),
                    const SizedBox(height: 16),
                    _buildChoosePlanSection(vm),
                    const SizedBox(height: 16),
                    _buildEmiSummary(vm),
                    const SizedBox(height: 16),
                    _buildInstallmentScheduleTable(vm),
                    const SizedBox(height: 20),
                  ],

                  _buildActionButtons(vm),
                ],
              ),
            ),
    );
  }

  // ===================== DROPDOWN =====================
  Widget _buildProductDropdown(BrandSelectionViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Data>(
          value: vm.selectedProduct,
          isExpanded: true,
          hint: const Text(
            "Select Product",
            style: TextStyle(color: Colors.grey),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.black87,
          ),
          items: vm.productList.map((p) {
            return DropdownMenuItem(
              value: p,
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.phone_iphone,
                      color: primaryBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${p.name} (${p.brand?.name ?? ''})",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '৳${p.sellingPrice ?? "0"}',
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (p) => p != null ? vm.selectProduct(p) : null,
        ),
      ),
    );
  }

  // ===================== TOGGLE =====================
  Widget _buildPurchaseModeSelector(BrandSelectionViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: ['EMI', 'MRP'].map((type) {
          final isSelected = vm.selectedPurchaseType == type;
          final isEmi = type == 'EMI';
          return Expanded(
            child: GestureDetector(
              onTap: () => vm.setPurchaseType(type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEmi
                          ? Icons.calendar_month_outlined
                          : Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF475569),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEmi ? 'EMI / Kisti Plan' : 'Full Cash',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ===================== PRODUCT HEADER =====================
  Widget _buildProductHeader(Data product) {
    final imageUrl = product.imageUrl != null
        ? (product.imageUrl!.startsWith('http')
              ? product.imageUrl!
              : ApiEndPoint.assetUrl(product.imageUrl!))
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.phone_android,
                        size: 40,
                        color: primaryBlue,
                      ),
                    ),
                  )
                : const Icon(Icons.phone_android, size: 40, color: primaryBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? 'Phone',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (product.brand?.name ?? '').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '৳${product.sellingPrice ?? "0"}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: primaryBlue,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 13,
                            color: Color(0xFF16A34A),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '100% Original',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== EMI CALCULATOR =====================
  Widget _buildEmiCalculatorCard(BrandSelectionViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calculate_outlined, color: primaryBlue, size: 20),
              SizedBox(width: 6),
              Text(
                "EMI Calculator",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _calcRow(
            Icons.shopping_bag_outlined,
            "Product Price",
            "৳${vm.resultSellingPrice.toStringAsFixed(0)}",
          ),
          const Divider(height: 18, thickness: 0.5, color: Color(0xFFE2E8F0)),
          _calcRow(
            Icons.payments_outlined,
            "Down Payment",
            "৳${vm.resultDownPayment.toStringAsFixed(0)}",
            showArrow: true,
            onTap: () => _showDownPaymentDialog(vm),
          ),
          const Divider(height: 18, thickness: 0.5, color: Color(0xFFE2E8F0)),
          _calcRow(
            Icons.percent,
            "Charge Rate (p.a.)",
            "${vm.interestRate.toStringAsFixed(0)}%",
            showArrow: true,
            onTap: () => _showInterestDialog(vm),
          ),
          const Divider(height: 18, thickness: 0.5, color: Color(0xFFE2E8F0)),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: Colors.black87,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "EMI Tenure",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                children: vm.availableTenures.map((months) {
                  final isSelected = vm.selectedTenureMonths == months;
                  return GestureDetector(
                    onTap: () => vm.selectTenure(months),
                    child: Container(
                      width: 36,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryBlue
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? primaryBlue
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "$months",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcRow(
    IconData icon,
    String label,
    String value, {
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black87),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          if (showArrow) ...[
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right, size: 18, color: primaryBlue),
          ],
        ],
      ),
    );
  }

  // ===================== CHOOSE PLAN =====================
  Widget _buildChoosePlanSection(BrandSelectionViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Choose a Plan",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: vm.availableTenures.map((months) {
              final isSelected = vm.selectedTenureMonths == months;
              final price = vm.resultSellingPrice;
              final charge = (price * vm.interestRate) / 100;
              final financed = price + charge - vm.downPayment;
              final monthly = months > 0
                  ? (financed / months).roundToDouble()
                  : 0;

              return GestureDetector(
                onTap: () => vm.selectTenure(months),
                child: Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? primaryBlue : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "$months Mon",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "৳${monthly.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: primaryBlue,
                        ),
                      ),
                      const Text(
                        "/mon",
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? primaryBlue : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? primaryBlue
                                : const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ===================== SUMMARY =====================
  Widget _buildEmiSummary(BrandSelectionViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: primaryBlue, size: 20),
              SizedBox(width: 6),
              Text(
                "EMI Summary",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryItem(
                        Icons.calendar_today_outlined,
                        "Monthly EMI",
                        "৳${vm.resultMonthlyEmi.toStringAsFixed(0)}",
                        primaryBlue,
                      ),
                    ),
                    Expanded(
                      child: _summaryItem(
                        Icons.show_chart,
                        "Total Charge",
                        "৳${vm.resultTotalInterest.toStringAsFixed(0)}",
                        const Color(0xFF16A34A),
                      ),
                    ),
                    Expanded(
                      child: _summaryItem(
                        Icons.savings_outlined,
                        "Total Payable",
                        "৳${vm.resultTotalPayable.toStringAsFixed(0)}",
                        primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 45,
                width: 1,
                color: const Color(0xFFE2E8F0),
                margin: const EdgeInsets.symmetric(horizontal: 6),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _featureCheck("No hidden charges"),
                    SizedBox(height: 3),
                    _featureCheck("Quick approval"),
                    SizedBox(height: 3),
                    _featureCheck("Easy process"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _featureCheck(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 12,
          color: Color(0xFF16A34A),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _summaryItem(
    IconData icon,
    String title,
    String value,
    Color valueColor,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: primaryBlue),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ===================== SCHEDULE TABLE =====================
  Widget _buildInstallmentScheduleTable(BrandSelectionViewModel vm) {
    if (vm.installmentSchedule.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                Icon(Icons.description_outlined, color: primaryBlue, size: 18),
                SizedBox(width: 6),
                Text(
                  "Payment Schedule",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: accentBlue,
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    "Month",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Installment",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Amount",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...vm.installmentSchedule.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == vm.installmentSchedule.length - 1;
            final amount = (item['amount'] as num).toDouble();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "${item['month']}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      isLast ? "Final Inst." : "Monthly EMI",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "৳${amount.toStringAsFixed(0)}",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          // Dotted Indicator Row (as seen in image)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    "...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "...",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "...",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          // Total Footer Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    "Total Payable",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "৳${vm.resultTotalPayable.toStringAsFixed(0)}",
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== ACTION BUTTONS =====================
  Widget _buildActionButtons(BrandSelectionViewModel vm) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, RouteName.checkoutParentScreen);
            },
            icon: const Icon(
              Icons.assignment_turned_in_outlined,
              color: Colors.white,
              size: 18,
            ),
            label: Text(
              vm.selectedPurchaseType == 'EMI'
                  ? 'Apply Now'
                  : 'Buy Now with Full Cash',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (vm.selectedPurchaseType == 'EMI') ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: primaryBlue, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, RouteName.checkoutParentScreen),
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: primaryBlue,
                size: 18,
              ),
              label: const Text(
                "Continue Purchase",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ===================== DIALOGS =====================
  void _showDownPaymentDialog(BrandSelectionViewModel vm) {
    final controller = TextEditingController(
      text: vm.downPayment.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Down Payment"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: "৳ ",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 0;
              vm.updateDownPayment(value);
              Navigator.pop(ctx);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showInterestDialog(BrandSelectionViewModel vm) {
    final controller = TextEditingController(
      text: vm.interestRate.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Charge Rate (%)"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            suffixText: "%",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            onPressed: () {
              final value = double.tryParse(controller.text) ?? 12;
              vm.updateInterestRate(value);
              Navigator.pop(ctx);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
