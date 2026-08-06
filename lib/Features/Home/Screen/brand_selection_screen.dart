import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_pay_app/core/routes/Routes_name.dart';
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/App_Colors.dart';
import '../../multy_form/viewModel/multyform_provider.dart';
import '../Model/EmiPlan.dart';
import '../Model/PhoneProductModel.dart';
import '../ViewModel/Brand_Selection_Model.dart';

class BrandSelectionScreen extends StatefulWidget {
  const BrandSelectionScreen({super.key});

  @override
  State<BrandSelectionScreen> createState() => _BrandSelectionScreenState();
}

class _BrandSelectionScreenState extends State<BrandSelectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandSelectionViewModel>().fetchProductsForCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BrandSelectionViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Device Catalog",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: AppColors.accentBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: vm.isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      )
          : vm.errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.greyText),
            const SizedBox(height: 16),
            Text(
              vm.errorMessage!,
              style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              onPressed: () => vm.fetchProductsForCurrentUser(), // Retry
              child: const Text(
                "Retry",
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Searchable Product Selector
            _buildProductDropdown(vm),
            const SizedBox(height: 20),

            // 2. Purchase Mode Selector (EMI vs Full Cash)
            _buildPurchaseModeSelector(vm),
            const SizedBox(height: 24),

            // 3. Product Header Info
            if (vm.selectedProduct != null) ...[
              _buildProductHeader(vm.selectedProduct!),
              const SizedBox(height: 24),
            ],

            // 4. EMI Section
            if (vm.selectedPurchaseType == 'EMI') ...[
              if (vm.isFetchingEmiPlans)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryBlue),
                        SizedBox(height: 12),
                        Text(
                          'Loading EMI Plans...',
                          style: TextStyle(fontSize: 14, color: AppColors.greyText),
                        ),
                      ],
                    ),
                  ),
                )
              else if (vm.emiPlanList.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderGrey),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, size: 40, color: AppColors.greyText),
                        SizedBox(height: 8),
                        Text(
                          'No EMI Plans Available',
                          style: TextStyle(fontSize: 14, color: AppColors.greyText),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                  _buildEmiCalculatorCard(vm),
                  const SizedBox(height: 24),
                  _buildChoosePlanSection(vm),
                  const SizedBox(height: 24),
                  _buildEmiSummary(vm),
                  const SizedBox(height: 24),
                  _buildInstallmentScheduleTable(vm),
                  const SizedBox(height: 32),
                ],
            ],

            // 5. Submit Action Button
            _buildActionButtons(vm),
          ],
        ),
      ),
    );
  }

  // ===================== SEARCHABLE PRODUCT SELECTOR =====================
  Widget _buildProductDropdown(BrandSelectionViewModel vm) {
    return GestureDetector(
      onTap: () => _showSearchableProductBottomSheet(vm),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withAlpha(15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue.withAlpha(40), AppColors.infoBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vm.selectedProduct != null
                        ? vm.selectedProduct!.name!
                        : "Find Phone Model...",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: vm.selectedProduct != null ? AppColors.black : Colors.grey.shade400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vm.selectedProduct != null
                        ? (vm.selectedProduct!.brand?.name ?? "Tap to change")
                        : "Search by model or brand",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.greyText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.unfold_more_rounded,
              color: AppColors.iconGrey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchableProductBottomSheet(BrandSelectionViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchProductBottomSheet(vm: vm),
    );
  }

  // ===================== PURCHASE MODE SELECTOR =====================
  Widget _buildPurchaseModeSelector(BrandSelectionViewModel vm) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: ['EMI', 'MRP'].map((type) {
          final isSelected = vm.selectedPurchaseType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => vm.setPurchaseType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type == 'EMI' ? Icons.calendar_today_rounded : Icons.payments_rounded,
                      size: 18,
                      color: isSelected ? AppColors.primaryBlue : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type == 'EMI' ? 'EMI' : 'MRP',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 14,
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
        ? (product.imageUrl!.startsWith('http') ? product.imageUrl! : ApiEndPoint.assetUrl(product.imageUrl!))
        : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: AppColors.bgGrey,
              borderRadius: BorderRadius.circular(15),
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.phone_android,
                  size: 40,
                  color: AppColors.primaryBlue,
                ),
              ),
            )
                : const Icon(
              Icons.phone_android,
              size: 40,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? 'Phone',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (product.brand?.name ?? '').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '৳${product.sellingPrice ?? "0"}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const Icon(Icons.verified_user_rounded, color: AppColors.successGreen, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== EMI CALCULATOR CARD =====================
  Widget _buildEmiCalculatorCard(BrandSelectionViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: AppColors.primaryBlue, size: 22),
              SizedBox(width: 8),
              Text(
                "EMI CALCULATOR",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentBlue,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _calcRow(
            Icons.shopping_bag_outlined,
            "Selling Price",
            "৳${vm.resultSellingPrice.toStringAsFixed(0)}",
          ),
          const Divider(height: 24, thickness: 0.8),
          _calcRow(
            Icons.payment_rounded,
            "Down Payment",
            "৳${vm.resultDownPayment.toStringAsFixed(0)}",
            showArrow: true,
            onTap: () => _showDownPaymentDialog(vm),
          ),
          const Divider(height: 24, thickness: 0.8),
          _calcRow(
            Icons.percent_rounded,
            "Charges Rate",
            "${vm.interestRate.toStringAsFixed(0)}%",
            showArrow: true,
            onTap: () => _showInterestDialog(vm),
          ),
          const Divider(height: 24, thickness: 0.8),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.black),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Tenure",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Wrap(
                spacing: 6,
                children: vm.availableTenures.map((months) {
                  final isSelected = vm.selectedTenureMonths == months;
                  return GestureDetector(
                    onTap: () => vm.selectTenure(months),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : AppColors.infoBlue,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primaryBlue.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ] : null,
                      ),
                      child: Center(
                        child: Text(
                          "$months",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? AppColors.white : AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (vm.getDownPaymentComponents().isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            const Text(
              "Additional Charges:",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: vm.getDownPaymentComponents().map((comp) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${comp.name}: ${comp.rate}%",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.iconGrey,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.iconGrey),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryBlue,
            ),
          ),
          if (showArrow) ...[
            const SizedBox(width: 8),
            const Icon(Icons.edit_note_rounded, size: 22, color: AppColors.primaryBlue),
          ],
        ],
      ),
    );
  }

  // ===================== CHOOSE PLAN SECTION =====================
  Widget _buildChoosePlanSection(BrandSelectionViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECTED PLAN",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.accentBlue,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.accentBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withAlpha(60),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "${vm.selectedTenureMonths} Months Installment Plan",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "৳${vm.resultMonthlyEmi.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const Text(
                "fixed amount per month",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (vm.selectedEmiPlan != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vm.selectedEmiPlan!.name,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ===================== EMI SUMMARY =====================
  Widget _buildEmiSummary(BrandSelectionViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.infoBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBlue.withAlpha(30)),
      ),
      child: Column(
        children: [
          _sumRow("Monthly Installment", "৳${vm.resultMonthlyEmi.toStringAsFixed(0)}", isBold: true),
          const SizedBox(height: 12),
          _sumRow("Financing Amount", "৳${vm.resultFinancedAmount.toStringAsFixed(0)}"),
          const SizedBox(height: 10),
          _sumRow("Charges", "৳${(vm.resultAppEmiCharge).toStringAsFixed(0)}"),
          const SizedBox(height: 10),
          _sumRow("Cashback Earned", "- ৳${vm.resultCashback.toStringAsFixed(0)}", color: AppColors.successGreen),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1.5, color: Colors.white),
          ),
          _sumRow("Grand Total Payable", "৳${vm.resultTotalPayable.toStringAsFixed(0)}", isBold: true, color: AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _sumRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.iconGrey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: FontWeight.w900,
            color: color ?? AppColors.black,
          ),
        ),
      ],
    );
  }

  // ===================== INSTALLMENT SCHEDULE =====================
  Widget _buildInstallmentScheduleTable(BrandSelectionViewModel vm) {
    if (vm.installmentSchedule.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "REPAYMENT SCHEDULE",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.accentBlue,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderGrey),
          ),
          child: Column(
            children: vm.installmentSchedule.map((item) {
              final index = vm.installmentSchedule.indexOf(item);
              final isLast = index == vm.installmentSchedule.length - 1;
              final isFinal = item['isFinal'] ?? false;

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: isFinal ? AppColors.infoBlue : Colors.transparent,
                  borderRadius: isLast ? const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ) : BorderRadius.zero,
                  border: isLast ? null : const Border(
                    bottom: BorderSide(color: AppColors.borderGrey, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: isFinal ? AppColors.primaryBlue : AppColors.infoBlue,
                          child: Text(
                            "${item['month']}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isFinal ? Colors.white : AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isFinal ? "Final Installment" : "Monthly Installment",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isFinal ? FontWeight.w800 : FontWeight.w600,
                            color: isFinal ? AppColors.primaryBlue : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "৳${item['amount'].toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isFinal ? FontWeight.w900 : FontWeight.w800,
                        color: isFinal ? AppColors.primaryBlue : AppColors.black,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ===================== ACTION BUTTONS =====================
  Widget _buildActionButtons(BrandSelectionViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: () {
          final checkoutVM = context.read<CheckoutViewModel>();
          if (vm.selectedProduct != null) {
            checkoutVM.setProductFromCatalog(
              id: vm.selectedProduct!.id!,
              name: vm.selectedProduct!.name!,
              price: vm.resultSellingPrice,
              saleType: vm.selectedPurchaseType == 'EMI' ? 'EMI' : 'Selling Price',
              brandName: vm.selectedProduct!.brand?.name,
              tenure: vm.selectedTenureMonths,
              downPayment: vm.resultDownPayment,
              interestRate: vm.interestRate,
            );
          }
          Navigator.pushNamed(context, RouteName.checkoutParentScreen);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Buy",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  // ===================== DIALOGS =====================
  void _showDownPaymentDialog(BrandSelectionViewModel vm) {
    final controller = TextEditingController(text: vm.resultDownPayment.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Down Payment", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(prefixText: "৳ ", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              vm.updateDownPayment(double.tryParse(controller.text) ?? vm.resultDownPayment);
              Navigator.pop(context);
            },
            child: const Text("Apply", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showInterestDialog(BrandSelectionViewModel vm) {
    final controller = TextEditingController(text: vm.interestRate.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Charges Rate (%)", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(suffixText: " %", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              vm.updateInterestRate(double.tryParse(controller.text) ?? vm.interestRate);
              Navigator.pop(context);
            },
            child: const Text("Apply", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ===================== SEARCH BOTTOM SHEET =====================
class _SearchProductBottomSheet extends StatefulWidget {
  final BrandSelectionViewModel vm;
  const _SearchProductBottomSheet({required this.vm});

  @override
  State<_SearchProductBottomSheet> createState() => _SearchProductBottomSheetState();
}

class _SearchProductBottomSheetState extends State<_SearchProductBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<Data> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _filteredList = widget.vm.productList;
  }

  void _filter(String query) {
    setState(() {
      _filteredList = widget.vm.productList.where((p) {
        final name = p.name?.toLowerCase() ?? "";
        final brand = p.brand?.name?.toLowerCase() ?? "";
        return name.contains(query.toLowerCase()) || brand.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 12),
            child: Row(
              children: [
                const Text(
                  "Select Device",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.accentBlue),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              autofocus: true,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: "Search by phone name or brand...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w500),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue, size: 22),
                filled: true,
                fillColor: AppColors.bgGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  const Text(
                    "No models found",
                    style: TextStyle(color: AppColors.greyText, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: _filteredList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = _filteredList[index];
                final isSelected = widget.vm.selectedProduct?.id == product.id;
                final hasEmiPlans = widget.vm.emiPlanList.any((e) => e.productId == product.id);

                return InkWell(
                  onTap: () {
                    widget.vm.selectProduct(product);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.infoBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.bgGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.phone_iphone_rounded,
                            color: AppColors.primaryBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name ?? "N/A",
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: isSelected ? AppColors.primaryBlue : AppColors.black,
                                ),
                              ),
                              Text(
                                product.brand?.name ?? "Other Brand",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.greyText,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "৳${product.sellingPrice ?? '0'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryBlue,
                                fontSize: 16,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryBlue,
                                size: 16,
                              )
                            else if (!hasEmiPlans)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "No EMI",
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}