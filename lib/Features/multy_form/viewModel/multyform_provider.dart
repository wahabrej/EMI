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

    // ─── EXISTING PLAN ───
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

    // ─── CREATE NEW PLAN ───
    if (checkoutData.emiMode == 'CREATE_NEW_PLAN') {
      debugPrint("📌 [initializePlanData] Calculating CREATE_NEW_PLAN data");
      recalculateEmi();
      return;
    }

    // ─── REMAINING BALANCE ───
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
    loadEmiPlansForExistingProduct(id);

    debugPrint("═══════════════════════════════════════");
    debugPrint(" [CheckoutVM] Syncing Product: $name");
    debugPrint("   ID: $id");
    debugPrint("   Price: $price");
    debugPrint("   SaleType: $saleType");
    debugPrint("   Tenure: $tenure");
    debugPrint("   DownPayment: $downPayment");
    debugPrint("   InterestRate: $interestRate");
    debugPrint("   CashbackRate: $cashbackRate");
    debugPrint("   DownPaymentComponents: $downPaymentComponents");
    debugPrint("═══════════════════════════════════════");

    checkoutData.productId = id;
    checkoutData.productModel = name;
    checkoutData.brandName = brandName;
    checkoutData.mrp = price;
    checkoutData.saleType = saleType;

    if (saleType == 'EMI') {
      checkoutData.emiMode = 'EXISTING_PLAN';

      if (tenure != null) {
        checkoutData.emiTenureMonths = tenure;
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
        debugPrint(
          "✅ [CheckoutVM] DownPaymentComponents set: ${downPaymentComponents.length} items",
        );
        for (var comp in downPaymentComponents) {
          debugPrint("   ${comp['name']}: ${comp['rate']}% (${comp['type']})");
        }
      }

      if (cashbackRate != null) {
        checkoutData.selectedCashbackRate = cashbackRate;
        debugPrint("✅ [CheckoutVM] CashbackRate set: $cashbackRate%");
      }
    }

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
      debugPrint("✅ [CheckoutVM] Product added to list: $name");
    }

    debugPrint("🔄 [CheckoutVM] Loading EMI plans for product: $id");
    _loadEmiPlansForProduct(id);
  }

  // ─── EMI প্ল্যান লোড করুন ───
  Future<void> _loadEmiPlansForProduct(String productId) async {
    debugPrint("═══════════════════════════════════════");
    debugPrint(
      "🔄 [_loadEmiPlansForProduct] Loading EMI plans for product: $productId",
    );

    final url = "${ApiEndPoint.emiPlans}?productId=$productId&isActive=true";
    debugPrint("🌐 API URL: $url");

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
        debugPrint("✅ [CheckoutVM] Loaded ${emiPlanList.length} EMI plans");

        for (int i = 0; i < emiPlanList.length; i++) {
          debugPrint(
            "   Plan $i: ${emiPlanList[i].name} (ID: ${emiPlanList[i].id})",
          );
        }

        if (emiPlanList.isNotEmpty) {
          final firstPlan = emiPlanList.first;
          checkoutData.emiPlanId = firstPlan.id;
          debugPrint(
            "📌 [CheckoutVM] Auto-selected first plan: ${firstPlan.name} (ID: ${firstPlan.id})",
          );
          await onEmiPlanSelected(firstPlan.id);
          debugPrint("✅ [CheckoutVM] Data fetched for selected plan");
        } else {
          debugPrint("⚠️ [CheckoutVM] No EMI plans available for this product");
        }

        notifyListeners();
      } else {
        debugPrint(
          "❌ [CheckoutVM] Failed to fetch EMI plans: ${data['error'] ?? 'Unknown error'}",
        );
      }
    } catch (e) {
      debugPrint("❌ [CheckoutVM] Error loading EMI plans: $e");
    }

    // 🔥 ডেটা লোড হওয়ার পর Plan ডেটা Initialize করুন
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
    try {
      final response = await http.get(
        Uri.parse(ApiEndPoint.shops),
        headers: _headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        shopList = (data['data'] as List)
            .map((e) => DropdownItemModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("fetchShops Error: $e");
    }
    _isFetchingDropdowns = false;
    notifyListeners();
  }

  Future<void> onShopSelected(String? shopId) async {
    checkoutData.shopId = shopId;
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
      }
    } catch (e) {}
    notifyListeners();
  }

  Future<void> onAgentSelected(String? agentId) async {
    checkoutData.agentId = agentId;
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
      }
    } catch (e) {}
    notifyListeners();
  }

  Future<void> onManagerSelected(String? managerId) async {
    checkoutData.managerId = managerId;
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
      }
    } catch (e) {}
    notifyListeners();
  }

  Future<void> onSalesPersonSelected(String? salesPersonId) async {
    checkoutData.salesPersonId = salesPersonId;
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
  Future<void> loadEmiPlansForExistingProduct(String productId) async {
    debugPrint("═══════════════════════════════════════");
    debugPrint(
      "📌 [loadEmiPlansForExistingProduct] Called for product: $productId",
    );

    if (productId.isEmpty) {
      debugPrint("⚠️ [loadEmiPlansForExistingProduct] productId is empty");
      return;
    }

    // যদি ইতিমধ্যে emiPlanList এ ডেটা থাকে, তাহলে ফেরত যান
    if (emiPlanList.isNotEmpty) {
      debugPrint(
        "✅ [loadEmiPlansForExistingProduct] emiPlanList already has ${emiPlanList.length} plans",
      );
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

        emiPlanList = rawList
            .map((e) => DropdownItemModel.fromJson(e))
            .toList();
        debugPrint("✅ Loaded ${emiPlanList.length} EMI plans");

        for (var plan in emiPlanList) {
          debugPrint("   📌 Plan: ${plan.name} (ID: ${plan.id})");
        }

        // Auto-select first plan for EXISTING_PLAN
        if (emiPlanList.isNotEmpty && checkoutData.emiMode == 'EXISTING_PLAN') {
          final firstPlan = emiPlanList.first;
          checkoutData.emiPlanId = firstPlan.id;
          debugPrint("✅ Auto-selected first plan: ${firstPlan.name}");
          await onEmiPlanSelected(firstPlan.id);
        } else if (emiPlanList.isNotEmpty &&
            checkoutData.emiMode == 'CREATE_NEW_PLAN') {
          // Custom EMI Plan এর জন্য শুধু notify করুন
          notifyListeners();
        }

        notifyListeners();
      } else {
        debugPrint(
          "❌ Failed to fetch EMI plans: ${data['error'] ?? 'Unknown error'}",
        );
      }
    } catch (e) {
      debugPrint("❌ loadEmiPlansForExistingProduct Exception: $e");
    }

    // ডেটা লোড হওয়ার পর Plan ডেটা Initialize করুন
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

  Future<bool> submitOrder() async {
    debugPrint("═══════════════════════════════════════");
    debugPrint("🚀 [submitOrder] CALLED");
    debugPrint("   saleType: ${checkoutData.saleType}");
    debugPrint("   emiMode: ${checkoutData.emiMode}");
    debugPrint("   productId: ${checkoutData.productId}");
    debugPrint("   emiPlanId: ${checkoutData.emiPlanId}");
    debugPrint("   customerName: ${checkoutData.name}");
    debugPrint("   phone: ${checkoutData.phone}");
    debugPrint("═══════════════════════════════════════");

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ─── Selling Price ───
      if (checkoutData.saleType == 'Selling Price') {
        debugPrint(" [submitOrder] Sale Type: Selling Price");
        debugPrint(" Calling _submitSellingPriceCustomer()...");
        final result = await _submitSellingPriceCustomer();
        debugPrint(" _submitSellingPriceCustomer() result: $result");
        _isLoading = false;
        notifyListeners();
        return result;
      }

      // ─── Create New EMI Plan ───
      if (checkoutData.emiMode == 'CREATE_NEW_PLAN') {
        debugPrint(" [submitOrder] EMI Mode: CREATE_NEW_PLAN");
        debugPrint(" Calling createNewEmiPlan()...");
        final newId = await createNewEmiPlan();
        debugPrint(" createNewEmiPlan() result: $newId");
        if (newId == null) {
          debugPrint(" [submitOrder] Failed to create new EMI plan");
          _isLoading = false;
          notifyListeners();
          return false;
        }
        debugPrint(" [submitOrder] New EMI Plan created with ID: $newId");
      }

      // ─── Submit Loan Application ───
      debugPrint(" [submitOrder] Submitting Loan Application");
      debugPrint(" Calling _submitLoanApplication()...");
      final result = await _submitLoanApplication();
      debugPrint(" _submitLoanApplication() result: $result");
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      debugPrint("❌ [submitOrder] EXCEPTION: $e");
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> createNewEmiPlan() async {
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

    debugPrint("========== CREATE EMI PLAN ==========");
    debugPrint("URL: ${ApiEndPoint.emiPlans}");
    debugPrint("HEADERS: $_headers");
    debugPrint("REQUEST BODY: ${jsonEncode(body)}");

    try {
      final res = await http.post(
        Uri.parse(ApiEndPoint.emiPlans),
        headers: _headers,
        body: jsonEncode(body),
      );

      debugPrint("========== EMI PLAN RESPONSE ==========");
      debugPrint("STATUS CODE: ${res.statusCode}");
      debugPrint("RESPONSE BODY: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        String id = data['data']['id'].toString();

        checkoutData.emiPlanId = id;
        checkoutData.emiTenureMonths = checkoutData.newPlanMonths;

        debugPrint("EMI PLAN CREATED SUCCESSFULLY");
        debugPrint("EMI PLAN ID: $id");
        debugPrint("EMI TENURE: ${checkoutData.emiTenureMonths} MONTHS");

        return id;
      } else {
        _errorMessage = data['error']?['message'] ?? 'Failed to create plan';

        debugPrint("EMI PLAN CREATION FAILED");
        debugPrint("ERROR MESSAGE: $_errorMessage");

        return null;
      }
    } catch (e, stackTrace) {
      debugPrint("========== EMI PLAN EXCEPTION ==========");
      debugPrint("ERROR: $e");
      debugPrint("STACK TRACE: $stackTrace");

      return null;
    }
  }

  Future<bool> _submitSellingPriceCustomer() async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiEndPoint.customers),
    );
    request.headers['Authorization'] = 'Bearer $userToken';
    _addCommonFields(request);
    await _attachAllFiles(request);
    final response = await request.send();
    _isLoading = false;
    notifyListeners();
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> _submitLoanApplication() async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiEndPoint.loanApplications),
    );
    request.headers['Authorization'] = 'Bearer $userToken';
    _addCommonFields(request);
    if (checkoutData.emiPlanId != null) {
      request.fields['emiPlanId'] = checkoutData.emiPlanId!;
    }
    request.fields['planMonths'] = checkoutData.emiTenureMonths.toString();
    await _attachAllFiles(request);
    final response = await request.send();
    _isLoading = false;
    notifyListeners();
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // lib/viewmodels/CheckoutViewModel.dart

  void _addCommonFields(http.MultipartRequest request) {
    // ─── Basic Info ───
    request.fields['issueDate'] = DateTime.now().toIso8601String().split(
      'T',
    )[0];
    request.fields['name'] = checkoutData.name;
    request.fields['phone'] = checkoutData.phone;
    request.fields['password'] = checkoutData.password.isEmpty
        ? '12345678'
        : checkoutData.password;
    request.fields['presentAddress'] = checkoutData.presentAddress;
    request.fields['permanentAddress'] = checkoutData.permanentAddress;

    // ─── ID & Income Info ───
    request.fields['idType'] = checkoutData.customerIdType;
    request.fields['nidPassportNumber'] = checkoutData.nidPassportNumber;
    request.fields['sourceOfIncome'] = checkoutData.sourceOfIncome;
    request.fields['monthlyIncome'] = checkoutData.monthlyIncome.toString();

    // ─── Product Info ───
    request.fields['productId'] = checkoutData.productId ?? '';
    request.fields['productModelId'] = checkoutData.productModelId ?? '';
    request.fields['mrp'] = checkoutData.mrp.toString();

    // ─── Store Hierarchy ───
    request.fields['shopId'] = checkoutData.shopId ?? '';
    request.fields['agentId'] = checkoutData.agentId ?? '';
    request.fields['managerId'] = checkoutData.managerId ?? '';
    request.fields['salesPersonId'] = checkoutData.salesPersonId ?? '';

    // ─── Payment Info ───
    request.fields['downPaymentMethod'] = checkoutData.downPaymentMethod;
    request.fields['incomeProofDocumentType'] =
        checkoutData.incomeProofDocumentType;
    request.fields['downPayment'] = checkoutData.downPayment.toString();
    request.fields['emiCharge'] = checkoutData.emiCharge.toString();
    request.fields['monthlyEmi'] = checkoutData.monthlyEmi.toString();
    request.fields['emiTenureMonths'] = checkoutData.emiTenureMonths.toString();

    // 🔥 Bank Receipt - ডিফল্ট মান পাঠান
    if (checkoutData.downPaymentMethod == 'BANK') {
      request.fields['bankReceiptStatus'] = checkoutData.bankReceipt != null
          ? 'UPLOADED'
          : 'NOT_PROVIDED';
    } else {
      request.fields['bankReceiptStatus'] = 'NOT_APPLICABLE';
    }

    if (checkoutData.downPaymentReferenceNumber != null) {
      request.fields['downPaymentReferenceNumber'] =
          checkoutData.downPaymentReferenceNumber!;
    }

    // ─── Guarantors ───
    final guarantors = checkoutData.guarantors.map((g) => g.toJson()).toList();
    request.fields['guarantors'] = jsonEncode(guarantors);
  }

  Future<void> _attachAllFiles(http.MultipartRequest request) async {
    Future<void> attach(String fieldName, File? file) async {
      if (file == null || !file.existsSync()) return;
      String ext = file.path.split('.').last.toLowerCase();
      String mimeSubtype = (ext == 'png') ? 'png' : 'jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: MediaType('image', mimeSubtype),
        ),
      );
    }

    // ─── Customer Image ───
    await attach('customerImage', customerImageFile);

    // ─── Customer Video ───
    await attach('customerVideo', checkoutData.customerVideo);

    // ─── Customer NID/Passport ───
    if (checkoutData.customerIdType == 'NID') {
      await attach('customerNidFront', checkoutData.nidFront);
      await attach('customerNidBack', checkoutData.nidBack);
    } else {
      await attach('customerNidFront', checkoutData.nidFront);
    }

    // ─── Income Proof ───
    await attach('incomeProofDocument', checkoutData.incomeProof);

    // 🔥 Bank Receipt - শুধুমাত্র ফাইল থাকলেই আপলোড করুন
    if (checkoutData.downPaymentMethod == 'BANK' &&
        checkoutData.bankReceipt != null) {
      await attach('bankReceipt', checkoutData.bankReceipt);
    }

    // ─── Guarantors ───
    for (int i = 0; i < checkoutData.guarantors.length; i++) {
      final g = checkoutData.guarantors[i];
      if (g.idType == 'NID') {
        await attach('guarantor${i}NidFront', g.nidFront);
        await attach('guarantor${i}NidBack', g.nidBack);
      } else {
        await attach('guarantor${i}NidFront', g.nidFront);
      }
    }
  }
}
