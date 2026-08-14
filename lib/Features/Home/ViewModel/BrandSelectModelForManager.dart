import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/EmiPlan.dart';

class BrandSelectModelForManager extends ChangeNotifier {
  // ─── Loading States ───
  bool isLoading = false;
  bool isFetchingEmiPlans = false;
  String? errorMessage;

  // ─── Product Data ───
  PhoneProductModel? phoneProductResponse;
  List<Data> productList = [];
  Data? selectedProduct;

  // ─── EMI Data ───
  List<EmiPlan> emiPlanList = [];
  EmiPlan? selectedEmiPlan;
  List<int> availableTenures = [];

  // ─── User Selection ───
  String selectedPurchaseType = 'EMI';
  int selectedTenureMonths = 6;
  double downPayment = 0.0;
  double interestRate = 0.0;
  double cashbackRate = 0.0;

  // ─── Calculation Results ───
  double resultSellingPrice = 0.0;
  double resultDownPayment = 0.0;
  double resultBaseEmiCharge = 0.0;
  double resultAppEmiCharge = 0.0;
  double resultCashback = 0.0;
  double resultFinancedAmount = 0.0;
  double resultMonthlyEmi = 0.0;
  double resultFinalInstallment = 0.0;
  double resultTotalPayable = 0.0;
  double resultTotalInterest = 0.0;

  List<Map<String, dynamic>> installmentSchedule = [];

  final AppStorage _appStorage = AppStorage();
  String? _currentUserId;

  // ─── Constructor ───
  BrandSelectModelForManager() {
    _loadCurrentUserId();
  }

  // ─── User ID Load ───
  Future<void> _loadCurrentUserId() async {
    try {
      _currentUserId = await _appStorage.getUserId();
      debugPrint(" [BrandSelectionVM] Current User ID loaded: $_currentUserId");
    } catch (e) {
      debugPrint(" [BrandSelectionVM] Error loading user ID: $e");
    }
  }

  // ─── Get Headers ───
  Future<Map<String, String>> _getHeaders() async {
    final token = await _appStorage.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ─── ✅ NEW: Fetch Assigned Products for Manager ───
  Future<void> fetchAssignedProducts({
    String? brandId,
    String? search,
    String? status,
  }) async {
    _setLoading(true);
    errorMessage = null;

    debugPrint("═══════════════════════════════════════════════════");
    debugPrint(" [BrandSelectionVM] fetchAssignedProducts() CALLED");
    debugPrint(" BrandId: $brandId");
    debugPrint(" Search: $search");
    debugPrint(" Status: $status");
    debugPrint("═══════════════════════════════════════════════════");

    try {
      // ✅ Build URL with query parameters
      final uri = Uri.parse(ApiEndPoint.assignedProducts);
      final queryParams = <String, String>{};

      if (brandId != null && brandId.isNotEmpty) {
        queryParams['brandId'] = brandId;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final url = uri.replace(queryParameters: queryParams);
      debugPrint(" 📡 API URL: $url");

      final headers = await _getHeaders();
      debugPrint(" 📋 Headers: ${headers.keys.join(', ')}");

      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint(" 📊 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        debugPrint(" ✅ API call SUCCESSFUL!");
        debugPrint(" 📄 Response: ${response.body}");

        final Map<String, dynamic> json = jsonDecode(response.body);

        // ✅ Check response structure
        // Assuming response format: { "data": [ { "id": "...", "name": "...", ... } ] }
        final List<dynamic> rawData = json['data'] ?? [];
        debugPrint(" 📦 Total Products: ${rawData.length}");

        // ✅ Convert to your Data model
        phoneProductResponse = PhoneProductModel.fromJson(json);
        productList = phoneProductResponse?.data ?? [];

        if (productList.isNotEmpty) {
          debugPrint(" ✅ ${productList.length} products loaded successfully.");
          await selectProduct(productList.first);
        } else {
          errorMessage = "No assigned products available for this Manager.";
          debugPrint(" ⚠️ $errorMessage");
        }
      } else if (response.statusCode == 403) {
        errorMessage = "Access denied. Only Managers and Agents can access this endpoint.";
        debugPrint(" ❌ $errorMessage");
      } else if (response.statusCode == 401) {
        errorMessage = "Session expired. Please login again.";
        debugPrint(" ❌ $errorMessage");
      } else {
        debugPrint(" ❌ API call FAILED!");
        debugPrint("    Status Code: ${response.statusCode}");
        debugPrint("    Response: ${response.body}");
        errorMessage = "Failed to load products. Status Code: ${response.statusCode}";
      }
    } catch (e, stackTrace) {
      debugPrint(" ❌ EXCEPTION: $e");
      debugPrint("    StackTrace: $stackTrace");
      errorMessage = "Network Error: ${e.toString()}";
    } finally {
      _setLoading(false);
      debugPrint("═══════════════════════════════════════════════════");
    }
  }

  // ─── ✅ OLD fetchProducts (Keep for backward compatibility) ───
  Future<void> fetchProducts({String? salesPersonId, String? brandId, String? search}) async {
    // ⚠️ This is the old endpoint - now we use fetchAssignedProducts
    await fetchAssignedProducts(brandId: brandId, search: search);
  }

  // ─── ✅ NEW: Fetch products for current user ───
  Future<void> fetchProductsForCurrentUser() async {
    debugPrint(" [BrandSelectionVM] Fetching assigned products for Manager");
    await fetchAssignedProducts();
  }

  // ─── Select Product ───
  Future<void> selectProduct(Data product) async {
    selectedProduct = product;
    final price = product.getSellingPrice();

    // Reset state
    emiPlanList.clear();
    availableTenures.clear();
    selectedEmiPlan = null;
    downPayment = 0.0;
    interestRate = 0.0;
    cashbackRate = 0.0;
    resultSellingPrice = price;

    if (product.id != null && product.id!.isNotEmpty) {
      isFetchingEmiPlans = true;
      notifyListeners();

      await _fetchEmiPlans(product.id!);

      // Select default plan
      if (emiPlanList.isNotEmpty) {
        _selectDefaultEmiPlan();
      }
    }

    calculateQuotation();
    notifyListeners();
  }

  // ─── Fetch EMI Plans ───
  Future<void> _fetchEmiPlans(String productId) async {
    final url = "${ApiEndPoint.emiPlans}?productId=$productId&isActive=true";
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(url), headers: headers);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          final List rawList = data['data'] ?? [];
          emiPlanList = rawList.map((e) => EmiPlan.fromJson(e)).toList();

          // Extract unique tenures
          final tenures = emiPlanList.map((e) => e.months).toSet().toList();
          tenures.sort();
          availableTenures = tenures;

          debugPrint("✅ Loaded ${emiPlanList.length} EMI plans");
          debugPrint("📌 Available Tenures: $availableTenures");
        }
      }
    } catch (e) {
      debugPrint("❌ fetchEmiPlans Error: $e");
    } finally {
      isFetchingEmiPlans = false;
    }
  }

  // ─── Select Default EMI Plan ───
  void _selectDefaultEmiPlan() {
    final defaultMonths = availableTenures.isNotEmpty ? availableTenures.first : 6;
    selectedTenureMonths = defaultMonths;

    final matchedPlan = emiPlanList.firstWhere(
          (e) => e.months == defaultMonths,
      orElse: () => emiPlanList.first,
    );

    _applyEmiPlan(matchedPlan);
  }

  // ─── Select Tenure ───
  void selectTenure(int months) {
    selectedTenureMonths = months;

    final matchedPlan = emiPlanList.firstWhere(
          (e) => e.months == months,
      orElse: () => emiPlanList.first,
    );

    _applyEmiPlan(matchedPlan);
    calculateQuotation();
  }

  // ─── Apply EMI Plan ───
  void _applyEmiPlan(EmiPlan plan) {
    selectedEmiPlan = plan;
    downPayment = plan.getDownPaymentAmount();
    interestRate = plan.getAppEmiChargeRate();
    cashbackRate = plan.getCashbackRate();

    debugPrint(" Applied Plan: ${plan.name}");
    debugPrint("    Down Payment: $downPayment (${plan.displayDownPaymentPercent}%)");
    debugPrint("    EMI Charge: $interestRate%");
    debugPrint("    Cashback: $cashbackRate%");
  }

  // ─── Update Down Payment (Manual) ───
  void updateDownPayment(double value) {
    downPayment = value;
    calculateQuotation();
  }

  // ─── Update Interest Rate (Manual) ───
  void updateInterestRate(double value) {
    interestRate = value;
    calculateQuotation();
  }

  // ─── Calculate Quotation ───
  void calculateQuotation() {
    if (selectedProduct == null) return;

    final sellingPrice = selectedProduct!.getSellingPrice();

    resultSellingPrice = sellingPrice;
    resultDownPayment = downPayment;

    // ─── ১. App EMI Charge বের করা ───
    double baseEmiCharge = (sellingPrice * interestRate) / 100;

    double additionalCharges = 0.0;
    final components = getDownPaymentComponents();

    for (var comp in components) {
      if (comp.type == 'RATE') {
        final rate = double.tryParse(comp.rate) ?? 0.0;
        additionalCharges += (sellingPrice * rate) / 100;
      } else if (comp.type == 'AMOUNT') {
        final amount = double.tryParse(comp.rate) ?? 0.0;
        additionalCharges += amount;
      }
    }

    double emiChargeForApps = baseEmiCharge + additionalCharges;
    double cashback = (sellingPrice * cashbackRate) / 100;
    double regularPayEmiCharge = emiChargeForApps - cashback;

    double financedAmount = sellingPrice + emiChargeForApps - resultDownPayment;
    final months = selectedTenureMonths;
    double monthlyEmi = months > 0 ? financedAmount / months : 0;
    double finalInstallment = financedAmount - (monthlyEmi * (months - 1));
    double totalPayable = resultDownPayment + financedAmount;
    double totalInterest = emiChargeForApps - cashback;

    resultBaseEmiCharge = _round(baseEmiCharge);
    resultAppEmiCharge = _round(emiChargeForApps);
    resultCashback = _round(cashback);
    resultFinancedAmount = _round(financedAmount);
    resultMonthlyEmi = _round(monthlyEmi);
    resultFinalInstallment = _round(finalInstallment);
    resultTotalPayable = _round(totalPayable);
    resultTotalInterest = _round(totalInterest);

    _generateInstallmentSchedule(months);

    debugPrint("═══════════════════════════════════════");
    debugPrint("📊 [CALCULATION RESULT]");
    debugPrint("   Selling Price: $sellingPrice");
    debugPrint("   Down Payment: $resultDownPayment");
    debugPrint("   Base EMI Charge: $resultBaseEmiCharge");
    debugPrint("   App EMI Charge: $resultAppEmiCharge");
    debugPrint("   Cashback: $resultCashback");
    debugPrint("   Financed Amount: $resultFinancedAmount");
    debugPrint("   Monthly EMI: $resultMonthlyEmi");
    debugPrint("   Total Payable: $resultTotalPayable");
    debugPrint("═══════════════════════════════════════");

    notifyListeners();
  }

  // ─── Generate Installment Schedule ───
  void _generateInstallmentSchedule(int months) {
    installmentSchedule.clear();
    for (int i = 1; i <= months; i++) {
      final amount = (i == months) ? resultFinalInstallment : resultMonthlyEmi;
      installmentSchedule.add({
        'month': i,
        'amount': amount,
        'isFinal': i == months,
      });
    }
  }

  double _round(double val) => double.parse(val.toStringAsFixed(2));

  // ─── Set Purchase Type ───
  void setPurchaseType(String type) {
    selectedPurchaseType = type;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // ─── Getters ───
  List<DownPaymentComponent> getDownPaymentComponents() {
    return selectedEmiPlan?.getDownPaymentComponents() ?? [];
  }

  String getDisplayDownPaymentPercent() {
    return selectedEmiPlan?.displayDownPaymentPercent ?? '0';
  }

  List<Map<String, dynamic>> getDownPaymentComponentsMap() {
    final components = getDownPaymentComponents();
    return components.map((comp) {
      return {
        'name': comp.name,
        'rate': comp.rate,
        'type': comp.type,
      };
    }).toList();
  }

  // ─── Reset ───
  void reset() {
    selectedProduct = null;
    emiPlanList.clear();
    availableTenures.clear();
    selectedEmiPlan = null;
    downPayment = 0.0;
    interestRate = 0.0;
    cashbackRate = 0.0;
    resultSellingPrice = 0.0;
    resultDownPayment = 0.0;
    resultFinancedAmount = 0.0;
    resultMonthlyEmi = 0.0;
    installmentSchedule.clear();
    notifyListeners();
  }
}