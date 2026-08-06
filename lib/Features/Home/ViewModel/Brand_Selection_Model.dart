import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/EmiPlan.dart';
import '../Model/PhoneProductModel.dart';

class BrandSelectionViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isFetchingEmiPlans = false;
  String? errorMessage;

  PhoneProductModel? phoneProductResponse;
  List<Data> productList = [];
  Data? selectedProduct;

  List<EmiPlan> emiPlanList = [];
  EmiPlan? selectedEmiPlan;

  List<int> availableTenures = [];

  // ─── User Selection ───
  String selectedPurchaseType = 'EMI';
  int selectedTenureMonths = 6;
  double downPayment = 0;
  double interestRate = 0.0;
  double cashbackRate = 0.0;

  // ─── Calculation Results ───
  double resultSellingPrice = 0.0;        //
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
  BrandSelectionViewModel() {
    _loadCurrentUserId();
  }

  // ─── User ID Load from SharedPreferences ───
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

  // ───  Main Method: Auto-fetch with Current User ID ───
  Future<void> fetchProductsForCurrentUser() async {
    // User ID Load করা না থাকলে Load করুন
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      await _loadCurrentUserId();

      if (_currentUserId == null || _currentUserId!.isEmpty) {
        errorMessage = "User not logged in. Please login again.";
        debugPrint("[BrandSelectionVM] $errorMessage");
        _setLoading(false);
        notifyListeners();
        return;
      }
    }

    debugPrint(" [BrandSelectionVM] Fetching products for User ID: $_currentUserId");
    await fetchProducts(salesPersonId: _currentUserId);
  }

  // ─── Generic fetchProducts ───
  Future<void> fetchProducts({String? salesPersonId, String? brandId, String? search}) async {
    _setLoading(true);
    errorMessage = null;

    //
    final String effectiveSalesPersonId = salesPersonId ?? _currentUserId ?? '';

    debugPrint("═══════════════════════════════════════════════════");
    debugPrint("🔍 [BrandSelectionVM] fetchProducts() CALLED");
    debugPrint(" Sales Person ID (Effective): $effectiveSalesPersonId");
    debugPrint(" Brand ID: $brandId");
    debugPrint(" Search: $search");
    debugPrint("═══════════════════════════════════════════════════");

    if (effectiveSalesPersonId.isEmpty) {
      errorMessage = "Sales Person ID is required.";
      debugPrint(" [BrandSelectionVM] $errorMessage");
      _setLoading(false);
      notifyListeners();
      return;
    }

    try {
      final String apiUrl = "${ApiEndPoint.products}?salesPersonId=$effectiveSalesPersonId";
      debugPrint(" [BrandSelectionVM] Final API URL: $apiUrl");

      final headers = await _getHeaders();
      debugPrint(" [BrandSelectionVM] Headers: ${headers.keys.join(', ')}");
      if (headers['Authorization'] != null) {
        final token = headers['Authorization']!;
        debugPrint(" [BrandSelectionVM] Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}...");
      }

      debugPrint("⏳ [BrandSelectionVM] Calling API...");
      final stopwatch = Stopwatch()..start();

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      stopwatch.stop();
      debugPrint(" [BrandSelectionVM] Response Time: ${stopwatch.elapsedMilliseconds}ms");
      debugPrint(" [BrandSelectionVM] Status Code: ${response.statusCode}");

      // ─── Response Handle ───
      if (response.statusCode == 200) {
        debugPrint(" [BrandSelectionVM] API call SUCCESSFUL!");

        final Map<String, dynamic> json = jsonDecode(response.body);

        final List<dynamic> rawData = json['data'] ?? [];
        debugPrint(" [BrandSelectionVM] Total Products in Response: ${rawData.length}");

        if (rawData.isNotEmpty) {
          debugPrint(" [BrandSelectionVM] Product List:");
          for (int i = 0; i < rawData.length; i++) {
            final p = rawData[i];
            final brandName = p['brand']?['name'] ?? 'N/A';
            debugPrint("   ${i+1}. ${p['name']} (ID: ${p['id']}) | Price: ${p['sellingPrice']} | Brand: $brandName");
          }
        } else {
          debugPrint("⚠ [BrandSelectionVM] No products found for Sales Person: $effectiveSalesPersonId");
        }

        phoneProductResponse = PhoneProductModel.fromJson(json);
        productList = phoneProductResponse?.data ?? [];

        if (productList.isNotEmpty) {
          debugPrint(" [BrandSelectionVM] ${productList.length} products loaded successfully.");
          await selectProduct(productList.first);
        } else {
          errorMessage = "No products available for this Sales Person.";
          debugPrint(" [BrandSelectionVM] $errorMessage");
        }

      } else {
        debugPrint(" [BrandSelectionVM] API call FAILED!");
        debugPrint("   Status Code: ${response.statusCode}");
        debugPrint("   Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}");
        errorMessage = "Failed to load products. Status Code: ${response.statusCode}";
      }

    } catch (e, stackTrace) {
      debugPrint(" [BrandSelectionVM] EXCEPTION CAUGHT!");
      debugPrint("   Error: $e");
      debugPrint("   StackTrace: $stackTrace");
      errorMessage = "Network Error: ${e.toString()}";
    } finally {
      _setLoading(false);
      debugPrint(" [BrandSelectionVM] fetchProducts() COMPLETED");
      debugPrint("═══════════════════════════════════════════════════");
    }
  }

  // ─── Select Product ───
  Future<void> selectProduct(Data product) async {
    selectedProduct = product;
    final price = double.tryParse(product.sellingPrice ?? '0') ?? 0.0;

    //  resultSellingPrice
    resultSellingPrice = price;

    downPayment = (price * 0.25).roundToDouble();

    emiPlanList.clear();
    availableTenures.clear();
    selectedEmiPlan = null;

    if (product.id != null && product.id!.isNotEmpty) {
      isFetchingEmiPlans = true;
      notifyListeners();

      final url = "${ApiEndPoint.emiPlans}?productId=${product.id}&isActive=true";
      try {
        final headers = await _getHeaders();
        final res = await http.get(Uri.parse(url), headers: headers);
        final data = jsonDecode(res.body);

        if (res.statusCode == 200 && data['success'] == true) {
          final List rawList = data['data'] ?? [];
          emiPlanList = rawList.map((e) => EmiPlan.fromJson(e)).toList();

          final tenures = emiPlanList.map((e) => e.months).toSet().toList();
          tenures.sort();
          availableTenures = tenures;

          if (emiPlanList.isNotEmpty) {
            selectedEmiPlan = emiPlanList.firstWhere(
                  (e) => e.months == availableTenures.first,
              orElse: () => emiPlanList.first,
            );
            selectedTenureMonths = selectedEmiPlan?.months ?? 6;

            if (selectedEmiPlan?.appEmiChargeRate != null) {
              interestRate = double.tryParse(selectedEmiPlan!.appEmiChargeRate) ?? 0.0;
            }

            if (selectedEmiPlan?.cashbackRate != null) {
              cashbackRate = double.tryParse(selectedEmiPlan!.cashbackRate) ?? 0.0;
            }
          }
        }
      } catch (e) {
        debugPrint(" [BrandSelectionVM] fetchEmiPlans Error: $e");
      } finally {
        isFetchingEmiPlans = false;
      }
    }

    calculateQuotation();
    notifyListeners();
  }

  // ─── Select Tenure ───
  void selectTenure(int months) {
    selectedTenureMonths = months;

    final matchedPlan = emiPlanList.firstWhere(
          (e) => e.months == months,
      orElse: () => emiPlanList.first,
    );

    selectedEmiPlan = matchedPlan;

    if (matchedPlan.appEmiChargeRate != null) {
      interestRate = double.tryParse(matchedPlan.appEmiChargeRate) ?? 0.0;
    }

    if (matchedPlan.cashbackRate != null) {
      cashbackRate = double.tryParse(matchedPlan.cashbackRate) ?? 0.0;
    }

    calculateQuotation();
  }

  // ─── Update Down Payment ───
  void updateDownPayment(double value) {
    downPayment = value;
    calculateQuotation();
  }

  // ─── Update Interest Rate ───
  void updateInterestRate(double value) {
    interestRate = value;
    calculateQuotation();
  }

  // ─── Calculate Quotation ───
  void calculateQuotation() {
    if (selectedProduct == null) return;

    final sellingPrice = double.tryParse(selectedProduct!.sellingPrice ?? '0') ?? 0.0;

    //  resultSellingPrice
    resultSellingPrice = sellingPrice;
    resultDownPayment = downPayment;
    resultBaseEmiCharge = (sellingPrice * interestRate) / 100;
    resultAppEmiCharge = resultBaseEmiCharge;
    resultCashback = (sellingPrice * cashbackRate) / 100;
    resultFinancedAmount = sellingPrice + resultAppEmiCharge - resultDownPayment;

    final months = selectedTenureMonths;
    resultMonthlyEmi = months > 0 ? resultFinancedAmount / months : 0;
    resultMonthlyEmi = _round(resultMonthlyEmi);

    resultFinalInstallment = resultFinancedAmount - (resultMonthlyEmi * (months - 1));
    resultFinalInstallment = _round(resultFinalInstallment);

    resultTotalPayable = resultDownPayment + resultFinancedAmount;
    resultTotalInterest = resultAppEmiCharge - resultCashback;

    _generateInstallmentSchedule(months);
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

  double _round(double val) => double.parse(val.toStringAsFixed(0));

  // ─── Set Purchase Type ───
  void setPurchaseType(String type) {
    selectedPurchaseType = type;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // ─── Get Down Payment Components ───
  List<DownPaymentComponent> getDownPaymentComponents() {
    return selectedEmiPlan?.downPaymentComponents ?? [];
  }

  // ─── Get Display Down Payment Percent ───
  String getDisplayDownPaymentPercent() {
    return selectedEmiPlan?.displayDownPaymentPercent ?? '0';
  }
}