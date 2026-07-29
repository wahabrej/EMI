import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/PhoneProductModel.dart';

class BrandSelectionViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  PhoneProductModel? phoneProductResponse;
  List<Data> productList = [];
  Data? selectedProduct;

  // ===== Frontend Controlled =====
  String selectedPurchaseType = 'EMI'; // 'EMI' or 'MRP'
  int selectedTenureMonths = 6;

  // Editable values (Frontend)
  double downPayment = 10000;          // default
  double interestRate = 12.0;          // 12%
  double cashbackRate = 0.0;           // optional

  // ===== Calculation Results =====
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

  // Available tenures (Frontend fixed)
  final List<int> availableTenures = [3, 6, 9, 12];

  final AppStorage _tokenStorage = AppStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenStorage.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ===================== API =====================
  Future<void> fetchProducts({String? salesPersonId, String? brandId, String? search}) async {
    _setLoading(true);
    errorMessage = null;

    try {
      final queryParams = <String, String>{};
      if (salesPersonId != null && salesPersonId.isNotEmpty) queryParams['salesPersonId'] = salesPersonId;
      if (brandId != null && brandId.isNotEmpty) queryParams['brandId'] = brandId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse(ApiEndPoint.products).replace(queryParameters: queryParams);
      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        phoneProductResponse = PhoneProductModel.fromJson(json);
        productList = phoneProductResponse?.data ?? [];

        if (productList.isNotEmpty) {
          selectProduct(productList.first);
        } else {
          errorMessage = "No products available.";
        }
      } else {
        errorMessage = "Failed to load products. Status Code: ${response.statusCode}";
      }
    } catch (e) {
      errorMessage = "Network Error: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // ===================== Selection =====================
  void selectProduct(Data product) {
    selectedProduct = product;
    final price = double.tryParse(product.sellingPrice ?? '0') ?? 0.0;

    // Auto set default down payment = 25% of price (or keep previous if reasonable)
    if (downPayment <= 0 || downPayment > price) {
      downPayment = (price * 0.25).roundToDouble();
    }

    calculateQuotation();
    notifyListeners();
  }

  void selectTenure(int months) {
    selectedTenureMonths = months;
    calculateQuotation();
  }

  void updateDownPayment(double value) {
    downPayment = value;
    calculateQuotation();
  }

  void updateInterestRate(double value) {
    interestRate = value;
    calculateQuotation();
  }

  // ===================== CALCULATION (PDF Logic) =====================
  void calculateQuotation() {
    if (selectedProduct == null) return;

    final sellingPrice = double.tryParse(selectedProduct!.sellingPrice ?? '0') ?? 0.0;
    resultSellingPrice = sellingPrice;

    // 1. Down Payment
    resultDownPayment = downPayment;

    // 2. Base EMI Charge (Interest)
    resultBaseEmiCharge = (sellingPrice * interestRate) / 100;
    resultAppEmiCharge = resultBaseEmiCharge; // no additional components for now

    // 3. Cashback
    resultCashback = (sellingPrice * cashbackRate) / 100;

    // 4. Financed Amount
    resultFinancedAmount = sellingPrice + resultAppEmiCharge - resultDownPayment;

    // 5. Monthly Installment
    final months = selectedTenureMonths;
    resultMonthlyEmi = months > 0 ? resultFinancedAmount / months : 0;
    resultMonthlyEmi = _round(resultMonthlyEmi);

    // 6. Final Installment
    resultFinalInstallment = resultFinancedAmount - (resultMonthlyEmi * (months - 1));
    resultFinalInstallment = _round(resultFinalInstallment);

    // 7. Total Payable
    resultTotalPayable = resultDownPayment + resultFinancedAmount;

    // 8. Total Interest
    resultTotalInterest = resultAppEmiCharge - resultCashback;

    _generateInstallmentSchedule(months);
    notifyListeners();
  }

  void _generateInstallmentSchedule(int months) {
    installmentSchedule.clear();
    for (int i = 1; i <= months; i++) {
      final amount = (i == months) ? resultFinalInstallment : resultMonthlyEmi;
      installmentSchedule.add({'month': i, 'amount': amount});
    }
  }

  double _round(double val) => double.parse(val.toStringAsFixed(0));

  void setPurchaseType(String type) {
    selectedPurchaseType = type;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}