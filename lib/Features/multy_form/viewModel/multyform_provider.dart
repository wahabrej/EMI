// lib/viewmodels/CheckoutViewModel.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:smart_pay_app/core/constant/Token_storage.dart';
import '../../../core/constant/Api_End_point.dart';
import '../model/dropdown_item_model.dart';
import '../model/full_checkout_model.dart';

class CheckoutViewModel extends ChangeNotifier {
  int _current_step = 0;
  int get currentStep => _current_step;

  bool _isLoading = false;
  bool _isFetchingDropdowns = false;

  bool get isLoading => _isLoading;
  bool get isFetchingDropdowns => _isFetchingDropdowns;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String userToken = "";
  final AppStorage _tokenStorage = AppStorage();

  final FullCheckoutModel checkoutData = FullCheckoutModel();
  File? customerImageFile;

  File? customerVideoFile; // 🔥 এই লাইনটি যোগ করুন

  // ─── setCustomerVideo মেথড ───
  void setCustomerVideo(File file) {
    customerVideoFile = file; // 🔥 সঠিকভাবে অ্যাসাইন করুন
    checkoutData.customerVideo = file;
    notifyListeners();
  }

  List<DropdownItemModel> shopList = [];
  List<DropdownItemModel> agentList = [];
  List<DropdownItemModel> managerList = [];
  List<DropdownItemModel> salesPersonList = [];
  List<DropdownItemModel> productList = [];
  List<DropdownItemModel> emiPlanList = [];

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $userToken',
    'Content-Type': 'application/json',
  };

  CheckoutViewModel({String? token}) {
    _initTokenAndLoadShops(passedToken: token);
  }

  // ─── Screen লোড হওয়ার সময় ডেটা সেট করুন ───
  void initializePlanData() {
    debugPrint("═══════════════════════════════════════");
    debugPrint("📌 [initializePlanData] Called");
    debugPrint("   emiMode: ${checkoutData.emiMode}");
    debugPrint("   emiPlanId: ${checkoutData.emiPlanId}");
    debugPrint("   emiPlanList.length: ${emiPlanList.length}");
    debugPrint("   monthlyEmi: ${checkoutData.monthlyEmi}");
    debugPrint("   downPayment: ${checkoutData.downPayment}");
    debugPrint("═══════════════════════════════════════");

    // ✅ ১ম: CREATE_NEW_PLAN (ডিফল্ট)
    if (checkoutData.emiMode == 'CREATE_NEW_PLAN') {
      debugPrint("📌 [initializePlanData] Calculating CREATE_NEW_PLAN data");
      recalculateEmi();
      return;
    }

    // ✅ ২য়: EXISTING_PLAN
    if (checkoutData.emiMode == 'EXISTING_PLAN') {
      if (checkoutData.emiPlanId != null &&
          checkoutData.emiPlanId!.isNotEmpty) {
        if (checkoutData.monthlyEmi == 0 && checkoutData.downPayment == 0) {
          debugPrint(
            "📌 [initializePlanData] Fetching data for plan: ${checkoutData.emiPlanId}",
          );
          onEmiPlanSelected(checkoutData.emiPlanId);
        } else {
          debugPrint("📌 [initializePlanData] Data already exists");
          debugPrint("   Down Payment: ${checkoutData.downPayment}");
          debugPrint("   Monthly EMI: ${checkoutData.monthlyEmi}");
          notifyListeners();
        }
      } else if (emiPlanList.isNotEmpty) {
        final firstPlan = emiPlanList.first;
        checkoutData.emiPlanId = firstPlan.id;
        debugPrint(
          "📌 [initializePlanData] Auto-selected first plan: ${firstPlan.name}",
        );
        onEmiPlanSelected(firstPlan.id);
      } else {
        debugPrint("⚠️ [initializePlanData] No EMI plan available");
      }
      return;
    }

    // ✅ ৩য়: REMAINING_BALANCE
    if (checkoutData.emiMode == 'REMAINING_BALANCE') {
      debugPrint("📌 [initializePlanData] Calculating REMAINING_BALANCE data");
      recalculateEmi();
      return;
    }

    debugPrint(
      "⚠️ [initializePlanData] Unknown emiMode: ${checkoutData.emiMode}",
    );
  }

  Future<void> _initTokenAndLoadShops({String? passedToken}) async {
    if (passedToken != null && passedToken.isNotEmpty) {
      userToken = passedToken;
    } else {
      userToken = await _tokenStorage.getToken() ?? "";
    }
    await fetchShops();
  }

  void notify() {
    recalculateEmi();
    notifyListeners();
  }

  // ─────────────── Dynamic Step Logic ───────────────
  List<int> get activeStepIndices {
    if (checkoutData.saleType == 'Selling Price') {
      return [0, 1, 4, 5];
    } else {
      return [0, 1, 2, 3, 4, 5];
    }
  }

  int get totalSteps => activeStepIndices.length;
  int get currentDisplayStep => activeStepIndices.indexOf(_current_step);

  void nextStep() {
    final steps = activeStepIndices;
    int currentIndex = steps.indexOf(_current_step);
    if (currentIndex < steps.length - 1) {
      _current_step = steps[currentIndex + 1];
      notifyListeners();
    }
  }

  void previousStep() {
    final steps = activeStepIndices;
    int currentIndex = steps.indexOf(_current_step);
    if (currentIndex > 0) {
      _current_step = steps[currentIndex - 1];
      notifyListeners();
    }
  }

  // ─────────────── Catalog Integration ───────────────
// lib/viewmodels/CheckoutViewModel.dart

  void setProductFromCatalog({
    required String id,
    required String name,
    required double price,
    required String saleType,
    String? brandName,
    int? tenure,
    double? downPayment,
    double? interestRate,
    List<Map<String, dynamic>>? downPaymentComponents,
    double? cashbackRate,
  }) {
    debugPrint("═══════════════════════════════════════");
    debugPrint(" [CheckoutVM] Syncing Product: $name");
    debugPrint("   ID: $id");
    debugPrint("   Price: $price");
    debugPrint("   SaleType: $saleType");
    debugPrint("   Tenure: $tenure");  // ✅ Brand Selection থেকে আসা Tenure
    debugPrint("   DownPayment: $downPayment");
    debugPrint("═══════════════════════════════════════");

    checkoutData.productId = id;
    checkoutData.productModel = name;
    checkoutData.brandName = brandName;
    checkoutData.mrp = price;
    checkoutData.saleType = saleType;

    if (saleType == 'EMI') {
      checkoutData.emiMode = 'CREATE_NEW_PLAN'; // ডিফল্ট

      // ✅ Tenure সেট করুন
      if (tenure != null) {
        checkoutData.emiTenureMonths = tenure; // ✅ Brand Selection থেকে আসা Tenure
        checkoutData.newPlanMonths = tenure;
      }

      if (downPayment != null) {
        checkoutData.downPayment = downPayment;
        checkoutData.downPaymentCalculationType = 'AMOUNT';
        checkoutData.downPaymentAmount = downPayment.toStringAsFixed(0);
      }

      if (interestRate != null) {
        checkoutData.appEmiChargeRate = interestRate.toStringAsFixed(0);
      }

      if (downPaymentComponents != null) {
        checkoutData.downPaymentComponents = downPaymentComponents;
      }

      if (cashbackRate != null) {
        checkoutData.selectedCashbackRate = cashbackRate;
      }
    }

    // ✅ Product টি list এ যোগ করুন
    final exists = productList.any((p) => p.id == id);
    if (!exists) {
      productList.add(
        DropdownItemModel(
          id: id,
          name: name,
          price: price,
          rawJson: {'id': id, 'name': name, 'mrp': price},
        ),
      );
    }

    debugPrint("🔄 Loading EMI plans for product: $id");
    _loadEmiPlansForProduct(id); // ✅ এখানে Filter করা হবে
  }

  // ─── EMI প্ল্যান লোড করুন ───
// lib/viewmodels/CheckoutViewModel.dart

// ─── EMI প্ল্যান লোড করার সময় Tenure অনুযায়ী Filter করুন ───
  Future<void> _loadEmiPlansForProduct(String productId) async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("🔄 [_loadEmiPlansForProduct] Loading EMI plans for product: $productId");

    final url = "${ApiEndPoint.emiPlans}?productId=$productId&isActive=true";
    debugPrint("🌐 API URL: $url");

    try {
      final res = await http.get(Uri.parse(url), headers: _headers);
      final data = jsonDecode(res.body);

      debugPrint("📊 Status Code: ${res.statusCode}");

      if (res.statusCode == 200 && data['success'] == true) {
        final rawList = data['data'] as List;
        debugPrint("📦 Raw data length: ${rawList.length}");

        // ✅ সব EMI Plans লোড করুন
        final allPlans = rawList
            .map((e) => DropdownItemModel.fromJson(e))
            .toList();

        debugPrint("✅ Loaded ${allPlans.length} EMI plans");

        // ✅ 🔥 Brand Selection থেকে আসা Tenure অনুযায়ী Filter করুন
        final selectedTenure = checkoutData.emiTenureMonths; // Brand Selection থেকে আসা Tenure
        debugPrint("📌 Selected Tenure: $selectedTenure months");

        // ✅ শুধু মিলে যাওয়া Tenure এর Plans রাখুন
        emiPlanList = allPlans.where((plan) {
          // plan.rawJson থেকে months বের করুন
          final planMonths = plan.rawJson['months'] as int? ??
              int.tryParse(plan.rawJson['months']?.toString() ?? '0') ?? 0;
          return planMonths == selectedTenure;
        }).toList();

        debugPrint("✅ Filtered ${emiPlanList.length} plans for tenure: $selectedTenure months");

        for (var plan in emiPlanList) {
          debugPrint("   📌 Plan: ${plan.name} (ID: ${plan.id}) - ${plan.rawJson['months']} months");
        }

        if (emiPlanList.isNotEmpty) {
          final firstPlan = emiPlanList.first;
          checkoutData.emiPlanId = firstPlan.id;
          debugPrint("📌 Auto-selected first plan: ${firstPlan.name}");
          await onEmiPlanSelected(firstPlan.id);
          debugPrint("✅ Data fetched for selected plan");
        } else {
          debugPrint("⚠️ No EMI plans available for tenure: $selectedTenure months");
        }

        notifyListeners();
      } else {
        debugPrint("❌ Failed to fetch EMI plans: ${data['error'] ?? 'Unknown error'}");
      }
    } catch (e) {
      debugPrint("❌ Error loading EMI plans: $e");
    }

    initializePlanData();
    debugPrint("═══════════════════════════════════════");
  }
  // ─────────────── Recalculate EMI ───────────────
  void recalculateEmi() {
    debugPrint("═══════════════════════════════════════");
    debugPrint("🔄 [RECALCULATE EMI] CALLED");
    debugPrint("   saleType: ${checkoutData.saleType}");
    debugPrint("   emiMode: ${checkoutData.emiMode}");
    debugPrint("   mrp: ${checkoutData.mrp}");
    debugPrint("   emiPlanId: ${checkoutData.emiPlanId}");
    debugPrint("   monthlyEmi (before): ${checkoutData.monthlyEmi}");
    debugPrint("   downPayment (before): ${checkoutData.downPayment}");
    debugPrint("═══════════════════════════════════════");

    if (checkoutData.saleType != 'EMI') {
      checkoutData.monthlyEmi = 0;
      notifyListeners();
      return;
    }

    double mrp = checkoutData.mrp;

    // ─── EXISTING PLAN ───
    if (checkoutData.emiMode == 'EXISTING_PLAN') {
      if (checkoutData.monthlyEmi > 0 || checkoutData.downPayment > 0) {
        debugPrint("📌 [EXISTING_PLAN] Using existing data");
        debugPrint("   Down Payment: ${checkoutData.downPayment}");
        debugPrint("   Monthly EMI: ${checkoutData.monthlyEmi}");
        notifyListeners();
        return;
      }

      if (checkoutData.emiPlanId != null &&
          checkoutData.emiPlanId!.isNotEmpty) {
        debugPrint(
          "📌 [EXISTING_PLAN] Fetching data for plan: ${checkoutData.emiPlanId}",
        );
        onEmiPlanSelected(checkoutData.emiPlanId);
        return;
      }

      if (emiPlanList.isNotEmpty) {
        final firstPlan = emiPlanList.first;
        checkoutData.emiPlanId = firstPlan.id;
        debugPrint("📌 [EXISTING_PLAN] Auto-selected plan: ${firstPlan.name}");
        onEmiPlanSelected(firstPlan.id);
        return;
      }

      debugPrint("⚠️ [EXISTING_PLAN] No EMI plan selected");
      notifyListeners();
      return;
    }

    // ─── CREATE NEW PLAN ───
    if (checkoutData.emiMode == 'CREATE_NEW_PLAN') {
      int months = checkoutData.newPlanMonths;
      double dp = 0;

      if (checkoutData.downPaymentCalculationType == 'RATE') {
        double dpRate =
            double.tryParse(checkoutData.downPaymentCalculationRate) ?? 0;
        dp = (mrp * dpRate) / 100;
      } else {
        dp =
            double.tryParse(checkoutData.downPaymentAmount ?? '0') ??
            checkoutData.downPayment;
      }
      checkoutData.downPayment = dp;

      double baseEmiCharge =
          (mrp * (double.tryParse(checkoutData.appEmiChargeRate) ?? 0.0)) / 100;

      double additionalCharges = 0.0;
      for (var comp in checkoutData.downPaymentComponents) {
        final rate = double.tryParse(comp['rate']?.toString() ?? '0') ?? 0.0;
        if (comp['type'] == 'RATE') {
          additionalCharges += (mrp * rate) / 100;
        } else if (comp['type'] == 'AMOUNT') {
          additionalCharges += rate;
        }
      }

      double emiChargeForApps = baseEmiCharge + additionalCharges;
      double financedAmount = mrp + emiChargeForApps - dp;

      checkoutData.monthlyEmi = months > 0 ? (financedAmount / months) : 0;
      checkoutData.emiTenureMonths = months;
      checkoutData.appEmiCharge = emiChargeForApps;
      checkoutData.financedAmount = financedAmount;
      checkoutData.totalPayable = dp + financedAmount;

      debugPrint("📊 [RECALCULATE EMI - CREATE_NEW_PLAN]");
      debugPrint("   Down Payment: ${checkoutData.downPayment}");
      debugPrint("   Base EMI Charge: $baseEmiCharge");
      debugPrint("   Additional Charges: $additionalCharges");
      debugPrint("   App EMI Charge: $emiChargeForApps");
      debugPrint("   Financed Amount: $financedAmount");
      debugPrint("   Monthly EMI: ${checkoutData.monthlyEmi}");

      notifyListeners();
      return;
    }

    // ─── REMAINING BALANCE ───
    if (checkoutData.emiMode == 'REMAINING_BALANCE') {
      double upfront = checkoutData.customUpfrontPayment;
      int months = checkoutData.customEmiDurationMonths;
      double rate = double.tryParse(checkoutData.customAppEmiChargeRate) ?? 0.0;

      checkoutData.downPayment = upfront;
      checkoutData.emiTenureMonths = months;

      double baseEmiCharge = (mrp * rate) / 100;

      double additionalCharges = 0.0;
      for (var comp in checkoutData.customAdditionalCharges) {
        final rateVal = double.tryParse(comp['rate']?.toString() ?? '0') ?? 0.0;
        if (comp['type'] == 'RATE') {
          additionalCharges += (mrp * rateVal) / 100;
        } else if (comp['type'] == 'AMOUNT') {
          additionalCharges += rateVal;
        }
      }

      double emiChargeForApps = baseEmiCharge + additionalCharges;
      double financedAmount = mrp + emiChargeForApps - upfront;

      checkoutData.monthlyEmi = months > 0 ? (financedAmount / months) : 0;
      checkoutData.appEmiCharge = emiChargeForApps;
      checkoutData.financedAmount = financedAmount;
      checkoutData.totalPayable = upfront + financedAmount;

      debugPrint("📊 [RECALCULATE EMI - REMAINING_BALANCE]");
      debugPrint("   Upfront Payment: $upfront");
      debugPrint("   Base EMI Charge: $baseEmiCharge");
      debugPrint("   Additional Charges: $additionalCharges");
      debugPrint("   App EMI Charge: $emiChargeForApps");
      debugPrint("   Financed Amount: $financedAmount");
      debugPrint("   Monthly EMI: ${checkoutData.monthlyEmi}");

      notifyListeners();
      return;
    }

    notifyListeners();
  }

  // ─────────────── API & Dropdown Handlers ───────────────
  Future<void> fetchShops() async {
    _isFetchingDropdowns = true;
    notifyListeners();

    debugPrint("═══════════════════════════════════════");
    debugPrint("🏪 [fetchShops] STARTED");
    debugPrint("   📌 Token: ${userToken.isNotEmpty ? '✅ Found' : '❌ NOT FOUND'}");
    debugPrint("   📌 API URL: ${ApiEndPoint.shops}");
    debugPrint("═══════════════════════════════════════");

    try {
      final response = await http.get(
        Uri.parse(ApiEndPoint.shops),
        headers: _headers,
      );

      debugPrint("📊 [fetchShops] Status Code: ${response.statusCode}");
      debugPrint("📊 [fetchShops] Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List rawList = data['data'] ?? [];
        debugPrint("📦 [fetchShops] Raw List Length: ${rawList.length}");

        shopList = rawList
            .map((e) => DropdownItemModel.fromJson(e))
            .toList();

        debugPrint("✅ [fetchShops] Loaded ${shopList.length} shops");
        for (var shop in shopList) {
          debugPrint("   🏪 Shop: ${shop.name} (ID: ${shop.id})");
        }

        // ✅ 🔥 এখানে Auto-select যোগ করুন
        if (shopList.isNotEmpty) {
          final firstShop = shopList.first;
          debugPrint("📌 [fetchShops] Auto-selecting first shop: ${firstShop.name}");
          checkoutData.shopId = firstShop.id;
          checkoutData.shopName = firstShop.name;  // ✅ সরাসরি নাম সেট করুন
          await onShopSelected(firstShop.id);
          notifyListeners();  // ✅ UI আপডেট করুন
        } else {
          debugPrint("⚠️ [fetchShops] No shops found!");
        }
      } else {
        debugPrint("❌ [fetchShops] Failed! Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ [fetchShops] Exception: $e");
    }

    _isFetchingDropdowns = false;
    notifyListeners();
    debugPrint("═══════════════════════════════════════");
  }

  Future<void> onShopSelected(String? shopId) async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("🏪 [onShopSelected] Called with: $shopId");

    checkoutData.shopId = shopId;

    // ✅ Shop Name সেট করুন
    if (shopId != null) {
      final shop = shopList.firstWhere(
            (e) => e.id == shopId,
        orElse: () => DropdownItemModel(id: '', name: '', rawJson: {}),
      );
      checkoutData.shopName = shop.name.isNotEmpty ? shop.name : null;
      debugPrint("   📌 Shop Name: ${checkoutData.shopName}");
    }

    agentList.clear();
    managerList.clear();
    salesPersonList.clear();
    notifyListeners();

    if (shopId == null) return;

    try {
      final res = await http.get(
        Uri.parse("${ApiEndPoint.agents}?shopId=$shopId"),
        headers: _headers,
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        agentList = (data['data'] as List)
            .map((e) => DropdownItemModel.fromJson(e))
            .toList();

        // ✅ Agent Auto-select
        if (agentList.isNotEmpty) {
          final firstAgent = agentList.first;
          await onAgentSelected(firstAgent.id);
        }
      }
    } catch (e) {}
    notifyListeners();
  }

  Future<void> onAgentSelected(String? agentId) async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("👤 [onAgentSelected] Called with: $agentId");

    checkoutData.agentId = agentId;

    // ✅ Agent Name সেট করুন
    if (agentId != null) {
      final agent = agentList.firstWhere(
            (e) => e.id == agentId,
        orElse: () => DropdownItemModel(id: '', name: '', rawJson: {}),
      );
      checkoutData.agentName = agent.name.isNotEmpty ? agent.name : null;
      debugPrint("   📌 Agent Name: ${checkoutData.agentName}");
    }

    managerList.clear();
    salesPersonList.clear();
    notifyListeners();

    if (agentId == null) return;

    try {
      final res = await http.get(
        Uri.parse("${ApiEndPoint.managers}?agentId=$agentId"),
        headers: _headers,
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        managerList = (data['data'] as List)
            .map((e) => DropdownItemModel.fromJson(e))
            .toList();

        // ✅ Manager Auto-select
        if (managerList.isNotEmpty) {
          final firstManager = managerList.first;
          await onManagerSelected(firstManager.id);
        }
      }
    } catch (e) {}
    notifyListeners();
  }

  Future<void> onManagerSelected(String? managerId) async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("👤 [onManagerSelected] Called with: $managerId");

    checkoutData.managerId = managerId;

    // ✅ Manager Name সেট করুন
    if (managerId != null) {
      final manager = managerList.firstWhere(
            (e) => e.id == managerId,
        orElse: () => DropdownItemModel(id: '', name: '', rawJson: {}),
      );
      checkoutData.managerName = manager.name.isNotEmpty ? manager.name : null;
      debugPrint("   📌 Manager Name: ${checkoutData.managerName}");
    }

    salesPersonList.clear();
    notifyListeners();

    if (managerId == null) return;

    try {
      final res = await http.get(
        Uri.parse("${ApiEndPoint.salesPersons}?managerId=$managerId"),
        headers: _headers,
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        salesPersonList = (data['data'] as List)
            .map((e) => DropdownItemModel.fromJson(e))
            .toList();

        // ✅ Sales Person Auto-select
        if (salesPersonList.isNotEmpty) {
          final firstSalesPerson = salesPersonList.first;
          await onSalesPersonSelected(firstSalesPerson.id);
        }
      }
    } catch (e) {}
    notifyListeners();
  }

  Future<void> onSalesPersonSelected(String? salesPersonId) async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("👤 [onSalesPersonSelected] Called with: $salesPersonId");

    checkoutData.salesPersonId = salesPersonId;

    // ✅ Sales Person Name সেট করুন
    if (salesPersonId != null) {
      final salesPerson = salesPersonList.firstWhere(
            (e) => e.id == salesPersonId,
        orElse: () => DropdownItemModel(id: '', name: '', rawJson: {}),
      );
      checkoutData.salesPersonName = salesPerson.name.isNotEmpty ? salesPerson.name : null;
      debugPrint("   📌 Sales Person Name: ${checkoutData.salesPersonName}");
    }

    productList.clear();
    notifyListeners();

    if (salesPersonId == null) return;

    try {
      final res = await http.get(
        Uri.parse("${ApiEndPoint.products}?salesPersonId=$salesPersonId"),
        headers: _headers,
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        productList = (data['data'] as List)
            .map((e) => DropdownItemModel.fromJson(e))
            .toList();
      }
    } catch (e) {}
    notifyListeners();
  }
  // lib/viewmodels/CheckoutViewModel.dart

  // ─── ইতিমধ্যে সিলেক্টেড প্রোডাক্টের জন্য EMI প্ল্যান লোড করুন ───
  // lib/viewmodels/CheckoutViewModel.dart

  Future<void> loadEmiPlansForExistingProduct(String productId) async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("📌 [loadEmiPlansForExistingProduct] Called for product: $productId");

    if (productId.isEmpty) {
      debugPrint("⚠️ productId is empty");
      return;
    }

    // যদি ইতিমধ্যে emiPlanList এ ডেটা থাকে, তাহলে চেক করুন
    if (emiPlanList.isNotEmpty) {
      debugPrint("✅ emiPlanList already has ${emiPlanList.length} plans");
      initializePlanData();
      return;
    }

    final url = "${ApiEndPoint.emiPlans}?productId=$productId&isActive=true";
    debugPrint("🌐 Fetching EMI Plans from: $url");

    try {
      final res = await http.get(Uri.parse(url), headers: _headers);
      final data = jsonDecode(res.body);

      debugPrint("📊 Status Code: ${res.statusCode}");

      if (res.statusCode == 200 && data['success'] == true) {
        final rawList = data['data'] as List;
        debugPrint("📦 Raw data length: ${rawList.length}");

        // ✅ সব Plans লোড করুন
        final allPlans = rawList
            .map((e) => DropdownItemModel.fromJson(e))
            .toList();

        // ✅ Tenure অনুযায়ী Filter করুন
        final selectedTenure = checkoutData.emiTenureMonths;
        debugPrint("📌 Filtering plans for tenure: $selectedTenure months");

        emiPlanList = allPlans.where((plan) {
          final planMonths = plan.rawJson['months'] as int? ??
              int.tryParse(plan.rawJson['months']?.toString() ?? '0') ?? 0;
          return planMonths == selectedTenure;
        }).toList();

        debugPrint(" Loaded ${emiPlanList.length} EMI plans for $selectedTenure months");

        for (var plan in emiPlanList) {
          debugPrint("    Plan: ${plan.name} (${plan.rawJson['months']} months)");
        }

        // EXISTING_PLAN এর জন্য auto-select
        if (emiPlanList.isNotEmpty && checkoutData.emiMode == 'EXISTING_PLAN') {
          final firstPlan = emiPlanList.first;
          checkoutData.emiPlanId = firstPlan.id;
          debugPrint(" Auto-selected first plan: ${firstPlan.name}");
          await onEmiPlanSelected(firstPlan.id);
        } else if (emiPlanList.isNotEmpty && checkoutData.emiMode == 'CREATE_NEW_PLAN') {
          notifyListeners();
        }

        notifyListeners();
      } else {
        debugPrint(" Failed to fetch EMI plans: ${data['error'] ?? 'Unknown error'}");
      }
    } catch (e) {
      debugPrint(" loadEmiPlansForExistingProduct Exception: $e");
    }

    initializePlanData();
    debugPrint("═══════════════════════════════════════");
  }
  Future<void> onProductSelected(String? productId) async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("📌 [onProductSelected] Called with productId: $productId");

    checkoutData.productId = productId;
    emiPlanList.clear();

    if (productId != null) {
      final selected = productList.firstWhere(
        (p) => p.id == productId,
        orElse: () => DropdownItemModel(id: '', name: 'Not Found', rawJson: {}),
      );
      checkoutData.mrp = selected.price ?? 0.0;
      checkoutData.productModel = selected.name;

      debugPrint(
        "📦 Selected Product: ${selected.name}, MRP: ${checkoutData.mrp}",
      );

      final url = "${ApiEndPoint.emiPlans}?productId=$productId&isActive=true";
      debugPrint("🌐 Fetching EMI Plans from: $url");

      try {
        final res = await http.get(Uri.parse(url), headers: _headers);
        final data = jsonDecode(res.body);

        debugPrint("📊 Status Code: ${res.statusCode}");

        if (res.statusCode == 200 && data['success'] == true) {
          final rawList = data['data'] as List;
          debugPrint("📦 Raw data length: ${rawList.length}");

          emiPlanList = rawList
              .map((e) => DropdownItemModel.fromJson(e))
              .toList();
          debugPrint("✅ Loaded ${emiPlanList.length} EMI plans");

          for (var plan in emiPlanList) {
            debugPrint("   📌 Plan: ${plan.name} (ID: ${plan.id})");
          }

          if (emiPlanList.isNotEmpty &&
              checkoutData.emiMode == 'EXISTING_PLAN') {
            final firstPlan = emiPlanList.first;
            checkoutData.emiPlanId = firstPlan.id;
            debugPrint("✅ Auto-selected first plan: ${firstPlan.name}");
            await onEmiPlanSelected(firstPlan.id);
          }
        } else {
          debugPrint(
            "❌ Failed to fetch EMI plans: ${data['error'] ?? 'Unknown error'}",
          );
        }
      } catch (e) {
        debugPrint("❌ onProductSelected Exception: $e");
      }
    } else {
      debugPrint("⚠️ productId is null");
    }

    recalculateEmi();
    notifyListeners();
    debugPrint("═══════════════════════════════════════");
  }

  // ─────────────── EMI Plan Selection ───────────────
  Future<void> onEmiPlanSelected(String? emiPlanId) async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("📌 [onEmiPlanSelected] Called with: $emiPlanId");

    if (emiPlanId == null) {
      debugPrint("❌ emiPlanId is null");
      checkoutData.downPayment = 0;
      checkoutData.monthlyEmi = 0;
      notifyListeners();
      return;
    }

    if (checkoutData.productId == null) {
      debugPrint("❌ productId is null");
      notifyListeners();
      return;
    }

    checkoutData.emiPlanId = emiPlanId;

    final url = ApiEndPoint.emiQuotation(emiPlanId);
    final body = {
      "productId": checkoutData.productId,
      "regularPrice": checkoutData.mrp.toString(),
    };

    debugPrint("🌐 API URL: $url");
    debugPrint("📦 Request Body: $body");

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(res.body);
      debugPrint("📊 Status Code: ${res.statusCode}");
      debugPrint("📊 Full Response: $data");

      if (res.statusCode == 200 && data['success'] == true) {
        final q = data['data'];

        debugPrint("📊 Parsing Data: $q");

        checkoutData.downPayment = _parseDouble(q['downPayment']);
        checkoutData.monthlyEmi = _parseDouble(q['monthlyEmi']);
        checkoutData.emiTenureMonths = _parseInt(q['months']);
        checkoutData.emiCharge = _parseDouble(q['emiCharge']);
        checkoutData.financedAmount = _parseDouble(q['financedAmount']);
        checkoutData.totalPayable = _parseDouble(q['totalPayable']);

        if (checkoutData.downPayment == 0 && q['downPaymentAmount'] != null) {
          checkoutData.downPayment = _parseDouble(q['downPaymentAmount']);
        }

        if (checkoutData.monthlyEmi == 0 &&
            checkoutData.financedAmount > 0 &&
            checkoutData.emiTenureMonths > 0) {
          checkoutData.monthlyEmi =
              checkoutData.financedAmount / checkoutData.emiTenureMonths;
        }

        debugPrint("✅ [onEmiPlanSelected] Success!");
        debugPrint("   Down Payment: ${checkoutData.downPayment}");
        debugPrint("   Monthly EMI: ${checkoutData.monthlyEmi}");
        debugPrint("   Tenure: ${checkoutData.emiTenureMonths}");
        debugPrint("   Financed Amount: ${checkoutData.financedAmount}");
      } else {
        debugPrint(
          "❌ [onEmiPlanSelected] API Error: ${data['error'] ?? 'Unknown error'}",
        );
      }
    } catch (e) {
      debugPrint("❌ [onEmiPlanSelected] Exception: $e");
    }

    notifyListeners();
    debugPrint("═══════════════════════════════════════");
  }

  // ─── হেলপার মেথড ───
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ─────────────── Setters ───────────────
  void resetStep() {
    _current_step = 0;
    notifyListeners();
  }

  void setPermanentAddress(String val) {
    checkoutData.permanentAddress = val;
    notifyListeners();
  }

  void setCustomerIdType(String type) {
    checkoutData.customerIdType = type;
    notifyListeners();
  }

  void setNidPassportNumber(String val) {
    checkoutData.nidPassportNumber = val;
    notifyListeners();
  }

  void setCustomerImage(File file) {
    customerImageFile = file;
    checkoutData.customerPhoto = file;
    notifyListeners();
  }

  void setNidFront(File file) {
    checkoutData.nidFront = file;
    notifyListeners();
  }

  void setNidBack(File file) {
    checkoutData.nidBack = file;
    notifyListeners();
  }

  void setIncomeProof(File file) {
    checkoutData.incomeProof = file;
    notifyListeners();
  }

  void setIncomeProofType(String val) {
    checkoutData.incomeProofDocumentType = val;
    notifyListeners();
  }

  void setGuarantorIdType(int index, String type) {
    if (index < checkoutData.guarantors.length) {
      checkoutData.guarantors[index].idType = type;
      notifyListeners();
    }
  }

  void setGuarantorNidFront(int index, File file) {
    if (index < checkoutData.guarantors.length) {
      checkoutData.guarantors[index].nidFront = file;
      notifyListeners();
    }
  }

  void setGuarantorNidBack(int index, File file) {
    if (index < checkoutData.guarantors.length) {
      checkoutData.guarantors[index].nidBack = file;
      notifyListeners();
    }
  }

  void addGuarantor() {
    checkoutData.guarantors.add(
      GuarantorInfo(type: 'NON_FAMILY', relationship: 'Friend'),
    );
    notifyListeners();
  }

  void removeGuarantor(int index) {
    if (checkoutData.guarantors.length > 1) {
      checkoutData.guarantors.removeAt(index);
      notifyListeners();
    }
  }

  void setPaymentMethod(String method) {
    checkoutData.downPaymentMethod = method;
    notifyListeners();
  }

  void setBankReceipt(File file) {
    checkoutData.bankReceipt = file;
    notifyListeners();
  }

  void setMonthlyPaymentDate(String val) {
    checkoutData.monthlyPaymentDate = val;
    notifyListeners();
  }

  void setProductModelId(String val) {
    checkoutData.productModelId = val;
    notifyListeners();
  }

  void setSourceOfIncome(String val) {
    checkoutData.sourceOfIncome = val;
    notifyListeners();
  }

  void setMonthlyIncome(double val) {
    checkoutData.monthlyIncome = val;
    notifyListeners();
  }

  // ─────────────── Submission Logic ───────────────
  // lib/viewmodels/CheckoutViewModel.dart

  // lib/viewmodels/CheckoutViewModel.dart

// ─────────────── Submission Logic ───────────────

  Future<bool> submitOrder() async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("🚀 [submitOrder] CALLED");
    debugPrint("   📌 saleType: ${checkoutData.saleType}");
    debugPrint("   📌 emiMode: ${checkoutData.emiMode}");
    debugPrint("   📌 productId: ${checkoutData.productId}");
    debugPrint("   📌 emiPlanId: ${checkoutData.emiPlanId}");
    debugPrint("   📌 customerName: ${checkoutData.name}");
    debugPrint("   📌 phone: ${checkoutData.phone}");
    debugPrint("   📌 mrp: ${checkoutData.mrp}");
    debugPrint("   📌 downPayment: ${checkoutData.downPayment}");
    debugPrint("   📌 monthlyEmi: ${checkoutData.monthlyEmi}");
    debugPrint("   📌 shopId: ${checkoutData.shopId}");
    debugPrint("   📌 agentId: ${checkoutData.agentId}");
    debugPrint("   📌 managerId: ${checkoutData.managerId}");
    debugPrint("   📌 salesPersonId: ${checkoutData.salesPersonId}");
    debugPrint("═══════════════════════════════════════");

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ─── Selling Price ───
      if (checkoutData.saleType == 'Selling Price') {
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        debugPrint("📌 [submitOrder] Sale Type: Selling Price");
        debugPrint("📌 [submitOrder] Calling _submitSellingPriceCustomer()...");
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        final result = await _submitSellingPriceCustomer();

        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        debugPrint("📊 [submitOrder] _submitSellingPriceCustomer() result: $result");
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        _isLoading = false;
        notifyListeners();
        return result;
      }

      // ─── Create New EMI Plan ───
      if (checkoutData.emiMode == 'CREATE_NEW_PLAN') {
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        debugPrint("📌 [submitOrder] EMI Mode: CREATE_NEW_PLAN");
        debugPrint("📌 [submitOrder] Calling createNewEmiPlan()...");
        debugPrint("   📌 newPlanName: ${checkoutData.newPlanName}");
        debugPrint("   📌 newPlanMonths: ${checkoutData.newPlanMonths}");
        debugPrint("   📌 downPaymentCalculationRate: ${checkoutData.downPaymentCalculationRate}");
        debugPrint("   📌 appEmiChargeRate: ${checkoutData.appEmiChargeRate}");
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

        final newId = await createNewEmiPlan();

        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        debugPrint("📊 [submitOrder] createNewEmiPlan() result: $newId");

        if (newId == null) {
          debugPrint("❌ [submitOrder] Failed to create new EMI plan");
          debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
          _isLoading = false;
          notifyListeners();
          return false;
        }
        debugPrint("✅ [submitOrder] New EMI Plan created with ID: $newId");
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      }

      // ─── Submit Loan Application ───
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("📌 [submitOrder] Submitting Loan Application");
      debugPrint("📌 [submitOrder] Calling _submitLoanApplication()...");
      debugPrint("   📌 emiPlanId: ${checkoutData.emiPlanId}");
      debugPrint("   📌 emiTenureMonths: ${checkoutData.emiTenureMonths}");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      final result = await _submitLoanApplication();

      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("📊 [submitOrder] _submitLoanApplication() result: $result");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      _isLoading = false;
      notifyListeners();
      return result;

    } catch (e, stackTrace) {
      debugPrint("═══════════════════════════════════════");
      debugPrint("❌ [submitOrder] EXCEPTION CAUGHT");
      debugPrint("   Error: $e");
      debugPrint("   StackTrace: $stackTrace");
      debugPrint("═══════════════════════════════════════");
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> createNewEmiPlan() async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("🔨 [createNewEmiPlan] STARTED");
    debugPrint("   📌 productId: ${checkoutData.productId}");
    debugPrint("   📌 newPlanName: ${checkoutData.newPlanName}");
    debugPrint("   📌 newPlanMonths: ${checkoutData.newPlanMonths}");
    debugPrint("   📌 downPaymentCalculationType: RATE");
    debugPrint("   📌 downPaymentCalculationRate: ${checkoutData.downPaymentCalculationRate}");
    debugPrint("   📌 appEmiChargeType: RATE");
    debugPrint("   📌 appEmiChargeRate: ${checkoutData.appEmiChargeRate}");
    debugPrint("   📌 isActive: true");
    debugPrint("   📌 sortOrder: 0");
    debugPrint("═══════════════════════════════════════");

    final body = {
      "productId": checkoutData.productId,
      "name": checkoutData.newPlanName.isEmpty
          ? "${checkoutData.newPlanMonths} Month Plan"
          : checkoutData.newPlanName,
      "months": checkoutData.newPlanMonths,
      "downPaymentCalculationType": "RATE",
      "downPaymentCalculationRate": checkoutData.downPaymentCalculationRate,
      "appEmiChargeType": "RATE",
      "appEmiChargeRate": checkoutData.appEmiChargeRate,
      "isActive": true,
      "sortOrder": 0,
    };

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("🌐 [createNewEmiPlan] API Request");
    debugPrint("   URL: ${ApiEndPoint.emiPlans}");
    debugPrint("   METHOD: POST");
    debugPrint("   HEADERS: $_headers");
    debugPrint("   REQUEST BODY: ${jsonEncode(body)}");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    try {
      final res = await http.post(
        Uri.parse(ApiEndPoint.emiPlans),
        headers: _headers,
        body: jsonEncode(body),
      );

      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("📥 [createNewEmiPlan] API Response");
      debugPrint("   STATUS CODE: ${res.statusCode}");
      debugPrint("   RESPONSE BODY: ${res.body}");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        String id = data['data']['id'].toString();

        checkoutData.emiPlanId = id;
        checkoutData.emiTenureMonths = checkoutData.newPlanMonths;

        debugPrint("✅ [createNewEmiPlan] SUCCESS");
        debugPrint("   EMI PLAN ID: $id");
        debugPrint("   EMI TENURE: ${checkoutData.emiTenureMonths} MONTHS");
        debugPrint("   ✅ New EMI Plan created successfully!");
        debugPrint("═══════════════════════════════════════");

        return id;
      } else {
        _errorMessage = data['error']?['message'] ?? 'Failed to create plan';

        debugPrint("❌ [createNewEmiPlan] FAILED");
        debugPrint("   ERROR MESSAGE: $_errorMessage");
        debugPrint("   STATUS CODE: ${res.statusCode}");
        debugPrint("   FULL RESPONSE: ${res.body}");
        debugPrint("═══════════════════════════════════════");

        return null;
      }
    } catch (e, stackTrace) {
      debugPrint("═══════════════════════════════════════");
      debugPrint("❌ [createNewEmiPlan] EXCEPTION CAUGHT");
      debugPrint("   Error: $e");
      debugPrint("   StackTrace: $stackTrace");
      debugPrint("═══════════════════════════════════════");
      return null;
    }
  }

  Future<bool> _submitSellingPriceCustomer() async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("📤 [_submitSellingPriceCustomer] STARTED");
    debugPrint("   📌 API URL: ${ApiEndPoint.customers}");
    debugPrint("   📌 METHOD: POST (Multipart)");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiEndPoint.customers),
    );
    request.headers['Authorization'] = 'Bearer $userToken';

    debugPrint("   📌 HEADERS: Authorization: Bearer $userToken");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📋 [Selling Price - Fields] Adding Common Fields...");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    _addCommonFields(request);

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📎 [Selling Price - Files] Attaching Files...");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    await _attachAllFiles(request);

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("🚀 [_submitSellingPriceCustomer] Sending Request...");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📥 [_submitSellingPriceCustomer] Response Received");
    debugPrint("   STATUS CODE: ${response.statusCode}");
    debugPrint("   RESPONSE BODY: $responseBody");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final isSuccess = response.statusCode == 200 || response.statusCode == 201;

    if (isSuccess) {
      debugPrint("✅ [_submitSellingPriceCustomer] SUCCESS!");
      debugPrint("   ✅ Customer created/updated successfully!");
    } else {
      debugPrint("❌ [_submitSellingPriceCustomer] FAILED!");
      debugPrint("   ❌ Status Code: ${response.statusCode}");
      debugPrint("   ❌ Response: $responseBody");
    }

    _isLoading = false;
    notifyListeners();
    debugPrint("═══════════════════════════════════════");
    return isSuccess;
  }

  Future<bool> _submitLoanApplication() async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("📤 [_submitLoanApplication] STARTED");
    debugPrint("   📌 API URL: ${ApiEndPoint.loanApplications}");
    debugPrint("   📌 METHOD: POST (Multipart)");
    debugPrint("   📌 emiPlanId: ${checkoutData.emiPlanId}");
    debugPrint("   📌 planMonths: ${checkoutData.emiTenureMonths}");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiEndPoint.loanApplications),
    );
    request.headers['Authorization'] = 'Bearer $userToken';

    debugPrint("   📌 HEADERS: Authorization: Bearer $userToken");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📋 [Loan Application - Fields] Adding Common Fields...");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    _addCommonFields(request);

    if (checkoutData.emiPlanId != null) {
      request.fields['emiPlanId'] = checkoutData.emiPlanId!;
      debugPrint("   📌 emiPlanId added: ${checkoutData.emiPlanId}");
    }
    request.fields['planMonths'] = checkoutData.emiTenureMonths.toString();
    debugPrint("   📌 planMonths added: ${checkoutData.emiTenureMonths}");

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📎 [Loan Application - Files] Attaching Files...");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    await _attachAllFiles(request);

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("🚀 [_submitLoanApplication] Sending Request...");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📥 [_submitLoanApplication] Response Received");
    debugPrint("   STATUS CODE: ${response.statusCode}");
    debugPrint("   RESPONSE BODY: $responseBody");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    final isSuccess = response.statusCode == 200 || response.statusCode == 201;

    if (isSuccess) {
      debugPrint("✅ [_submitLoanApplication] SUCCESS!");
      debugPrint("   ✅ Loan Application submitted successfully!");
    } else {
      debugPrint("❌ [_submitLoanApplication] FAILED!");
      debugPrint("   ❌ Status Code: ${response.statusCode}");
      debugPrint("   ❌ Response: $responseBody");
    }

    _isLoading = false;
    notifyListeners();
    debugPrint("═══════════════════════════════════════");
    return isSuccess;
  }

  void _addCommonFields(http.MultipartRequest request) {
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📋 [_addCommonFields] STARTED - Adding All Fields");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    // ─── Basic Info ───
    request.fields['issueDate'] = DateTime.now().toIso8601String().split('T')[0];
    request.fields['name'] = checkoutData.name;
    request.fields['phone'] = checkoutData.phone;
    request.fields['password'] = checkoutData.password.isEmpty ? '12345678' : checkoutData.password;
    request.fields['presentAddress'] = checkoutData.presentAddress;
    request.fields['permanentAddress'] = checkoutData.permanentAddress;

    debugPrint("   📌 [Basic Info]");
    debugPrint("      issueDate: ${request.fields['issueDate']}");
    debugPrint("      name: ${request.fields['name']}");
    debugPrint("      phone: ${request.fields['phone']}");
    debugPrint("      password: ${request.fields['password']}");
    debugPrint("      presentAddress: ${request.fields['presentAddress']}");
    debugPrint("      permanentAddress: ${request.fields['permanentAddress']}");

    // ─── ID & Income Info ───
    request.fields['idType'] = checkoutData.customerIdType;
    request.fields['nidPassportNumber'] = checkoutData.nidPassportNumber;
    request.fields['sourceOfIncome'] = checkoutData.sourceOfIncome;
    request.fields['monthlyIncome'] = checkoutData.monthlyIncome.toString();

    debugPrint("   📌 [ID & Income]");
    debugPrint("      idType: ${request.fields['idType']}");
    debugPrint("      nidPassportNumber: ${request.fields['nidPassportNumber']}");
    debugPrint("      sourceOfIncome: ${request.fields['sourceOfIncome']}");
    debugPrint("      monthlyIncome: ${request.fields['monthlyIncome']}");

    // ─── Product Info ───
    request.fields['productId'] = checkoutData.productId ?? '';
    request.fields['productModelId'] = checkoutData.productModelId ?? '';
    request.fields['mrp'] = checkoutData.mrp.toString();

    debugPrint("   📌 [Product Info]");
    debugPrint("      productId: ${request.fields['productId']}");
    debugPrint("      productModelId: ${request.fields['productModelId']}");
    debugPrint("      mrp: ${request.fields['mrp']}");

    // ─── Store Hierarchy ───
    request.fields['shopId'] = checkoutData.shopId ?? '';
    request.fields['agentId'] = checkoutData.agentId ?? '';
    request.fields['managerId'] = checkoutData.managerId ?? '';
    request.fields['salesPersonId'] = checkoutData.salesPersonId ?? '';

    debugPrint("   📌 [Store Hierarchy]");
    debugPrint("      shopId: ${request.fields['shopId']}");
    debugPrint("      agentId: ${request.fields['agentId']}");
    debugPrint("      managerId: ${request.fields['managerId']}");
    debugPrint("      salesPersonId: ${request.fields['salesPersonId']}");

    // ─── Payment Info ───
    request.fields['downPaymentMethod'] = checkoutData.downPaymentMethod;
    request.fields['incomeProofDocumentType'] = checkoutData.incomeProofDocumentType;
    request.fields['downPayment'] = checkoutData.downPayment.toString();
    request.fields['emiCharge'] = checkoutData.emiCharge.toString();
    request.fields['monthlyEmi'] = checkoutData.monthlyEmi.toString();
    request.fields['emiTenureMonths'] = checkoutData.emiTenureMonths.toString();

    debugPrint("   📌 [Payment Info]");
    debugPrint("      downPaymentMethod: ${request.fields['downPaymentMethod']}");
    debugPrint("      incomeProofDocumentType: ${request.fields['incomeProofDocumentType']}");
    debugPrint("      downPayment: ${request.fields['downPayment']}");
    debugPrint("      emiCharge: ${request.fields['emiCharge']}");
    debugPrint("      monthlyEmi: ${request.fields['monthlyEmi']}");
    debugPrint("      emiTenureMonths: ${request.fields['emiTenureMonths']}");

    // ──────────────────────────────────────────────────────────────
    // ✅ 🔥 BANK PAYMENT FIELDS - এখানে যোগ করুন
    // ──────────────────────────────────────────────────────────────
    if (checkoutData.downPaymentMethod == 'BANK') {
      // Bank Account Name
      request.fields['bankAccountName'] = checkoutData.bankAccountName ?? '';
      debugPrint("   📌 bankAccountName: ${request.fields['bankAccountName']}");

      // Bank Account Number
      request.fields['bankAccountNumber'] = checkoutData.bankAccountNumber ?? '';
      debugPrint("   📌 bankAccountNumber: ${request.fields['bankAccountNumber']}");

      // Bank Name
      request.fields['bankName'] = checkoutData.bankName ?? '';
      debugPrint("   📌 bankName: ${request.fields['bankName']}");

      // Bank Receipt Status
      request.fields['bankReceiptStatus'] = checkoutData.bankReceipt != null ? 'UPLOADED' : 'NOT_PROVIDED';
      debugPrint("   📌 bankReceiptStatus: ${request.fields['bankReceiptStatus']}");
    } else {
      request.fields['bankReceiptStatus'] = 'NOT_APPLICABLE';
    }

    // Transaction Reference Number (যেকোনো পেমেন্টের জন্য)
    if (checkoutData.downPaymentReferenceNumber != null &&
        checkoutData.downPaymentReferenceNumber!.isNotEmpty) {
      request.fields['downPaymentReferenceNumber'] = checkoutData.downPaymentReferenceNumber!;
      debugPrint("   📌 downPaymentReferenceNumber: ${request.fields['downPaymentReferenceNumber']}");
    }

    debugPrint("   📌 [Bank Info]");
    debugPrint("      bankReceiptStatus: ${request.fields['bankReceiptStatus']}");
    debugPrint("      downPaymentReferenceNumber: ${request.fields['downPaymentReferenceNumber'] ?? 'N/A'}");

    // ─── Guarantors ───
    final guarantors = checkoutData.guarantors.map((g) => g.toJson()).toList();
    request.fields['guarantors'] = jsonEncode(guarantors);

    debugPrint("   📌 [Guarantors]");
    debugPrint("      total: ${guarantors.length}");
    for (int i = 0; i < guarantors.length; i++) {
      debugPrint("      Guarantor #${i+1}: ${jsonEncode(guarantors[i])}");
    }

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("✅ [_addCommonFields] All fields added successfully");
    debugPrint("   TOTAL FIELDS: ${request.fields.length}");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  }

  Future<void> _attachAllFiles(http.MultipartRequest request) async {
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📎 [_attachAllFiles] STARTED - Attaching All Files");
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    int attachedCount = 0;
    int skippedCount = 0;

    // ─── ইমেজ ফাইল আটাচ করার ফাংশন ───
    Future<void> attachImage(String fieldName, File? file) async {
      if (file == null || !file.existsSync()) {
        debugPrint("   ⚠️ [SKIP] $fieldName: File not found or null");
        skippedCount++;
        return;
      }
      String ext = file.path.split('.').last.toLowerCase();
      String mimeSubtype = (ext == 'png') ? 'png' : 'jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: MediaType('image', mimeSubtype),
        ),
      );
      attachedCount++;
      debugPrint("   🖼️ [IMAGE] $fieldName: ${file.path.split('/').last} (image/$mimeSubtype)");
    }

    // ─── ভিডিও ফাইল আটাচ করার ফাংশন ───
    Future<void> attachVideo(String fieldName, File? file) async {
      if (file == null || !file.existsSync()) {
        debugPrint("   ⚠️ [SKIP] $fieldName: File not found or null");
        skippedCount++;
        return;
      }

      String ext = file.path.split('.').last.toLowerCase();
      String mimeType;

      // ভিডিও ফরম্যাট অনুযায়ী সঠিক MIME টাইপ সেট করুন
      switch (ext) {
        case 'mp4':
          mimeType = 'video/mp4';
          break;
        case 'webm':
          mimeType = 'video/webm';
          break;
        case 'mov':
          mimeType = 'video/quicktime';
          break;
        case 'avi':
          mimeType = 'video/x-msvideo';
          break;
        case 'mkv':
          mimeType = 'video/x-matroska';
          break;
        case 'flv':
          mimeType = 'video/x-flv';
          break;
        case 'wmv':
          mimeType = 'video/x-ms-wmv';
          break;
        case '3gp':
          mimeType = 'video/3gpp';
          break;
        default:
        // ডিফল্ট হিসেবে mp4 সেট করুন
          mimeType = 'video/mp4';
          debugPrint("   ⚠️ [WARNING] Unknown video extension: $ext, using video/mp4");
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
      attachedCount++;
      debugPrint("   🎬 [VIDEO] $fieldName: ${file.path.split('/').last} ($mimeType)");
    }

    // ─── PDF বা অন্যান্য ডকুমেন্ট আটাচ করার ফাংশন (ভবিষ্যতের জন্য) ───
    Future<void> attachDocument(String fieldName, File? file) async {
      if (file == null || !file.existsSync()) {
        debugPrint("   ⚠️ [SKIP] $fieldName: File not found or null");
        skippedCount++;
        return;
      }

      String ext = file.path.split('.').last.toLowerCase();
      String mimeType;

      switch (ext) {
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        case 'doc':
          mimeType = 'application/msword';
          break;
        case 'docx':
          mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
          break;
        case 'xls':
          mimeType = 'application/vnd.ms-excel';
          break;
        case 'xlsx':
          mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
          break;
        default:
          mimeType = 'application/octet-stream';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
      attachedCount++;
      debugPrint("   📄 [DOCUMENT] $fieldName: ${file.path.split('/').last} ($mimeType)");
    }

    // ─── Customer Image ───
    debugPrint("   📌 [Customer Photo]");
    await attachImage('customerImage', customerImageFile);

    // ─── Customer Video (ভিডিও হিসেবে আটাচ করুন) ───
    debugPrint("   📌 [Customer Video]");
    await attachVideo('customerVideo', checkoutData.customerVideo);

    // ─── Customer NID/Passport ───
    debugPrint("   📌 [Customer ID Document]");
    if (checkoutData.customerIdType == 'NID') {
      await attachImage('customerNidFront', checkoutData.nidFront);
      await attachImage('customerNidBack', checkoutData.nidBack);
    } else {
      await attachImage('customerNidFront', checkoutData.nidFront);
    }

    // ─── Income Proof ───
    debugPrint("   📌 [Income Proof]");
    await attachImage('incomeProofDocument', checkoutData.incomeProof);

    // 🔥 Bank Receipt
    debugPrint("   📌 [Bank Receipt]");
    if (checkoutData.downPaymentMethod == 'BANK' && checkoutData.bankReceipt != null) {
      await attachImage('bankReceipt', checkoutData.bankReceipt);
    } else {
      debugPrint("   ⚠️ [SKIP] bankReceipt: Not applicable or file missing");
      skippedCount++;
    }

    // ─── Guarantors ───
    debugPrint("   📌 [Guarantor Documents]");
    for (int i = 0; i < checkoutData.guarantors.length; i++) {
      final g = checkoutData.guarantors[i];
      debugPrint("      📌 Guarantor #${i+1}: ${g.name}");
      if (g.idType == 'NID') {
        await attachImage('guarantor${i}NidFront', g.nidFront);
        await attachImage('guarantor${i}NidBack', g.nidBack);
      } else {
        await attachImage('guarantor${i}NidFront', g.nidFront);
      }
    }

    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    debugPrint("📊 [_attachAllFiles] SUMMARY");
    debugPrint("   ✅ Attached: $attachedCount file(s)");
    debugPrint("   ⚠️ Skipped: $skippedCount file(s)");
    debugPrint("   📌 Total Files: ${request.files.length}");

    // ফাইলের বিস্তারিত তালিকা দেখান
    if (request.files.isNotEmpty) {
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("📋 [FILE DETAILS]");
      for (int i = 0; i < request.files.length; i++) {
        final file = request.files[i];
        debugPrint("   ${i+1}. ${file.field}: ${file.filename} (${file.contentType})");
      }
    }
    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  }
}
