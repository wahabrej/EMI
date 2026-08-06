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
  int _currentStep = 0;
  int get currentStep => _currentStep;

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
    debugPrint("🔍 [CheckoutVM] Initialized ViewModel");
    _initTokenAndLoadShops(passedToken: token);
  }

  Future<void> _initTokenAndLoadShops({String? passedToken}) async {
    if (passedToken != null && passedToken.isNotEmpty) {
      userToken = passedToken;
      debugPrint("🔑 [CheckoutVM] Using Passed Token: $userToken");
    } else {
      userToken = await _tokenStorage.getToken() ?? "";
      debugPrint(" [CheckoutVM] Retrieved Token from AppStorage: $userToken");
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
  int get currentDisplayStep => activeStepIndices.indexOf(_currentStep);

  void nextStep() {
    final steps = activeStepIndices;
    int currentIndex = steps.indexOf(_currentStep);
    if (currentIndex < steps.length - 1) {
      _currentStep = steps[currentIndex + 1];
      debugPrint(" [CheckoutVM] Step Forward to Index: $_currentStep");
      notifyListeners();
    }
  }

  void previousStep() {
    final steps = activeStepIndices;
    int currentIndex = steps.indexOf(_currentStep);
    if (currentIndex > 0) {
      _currentStep = steps[currentIndex - 1];
      debugPrint("[CheckoutVM] Step Backward to Index: $_currentStep");
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
  }) {
    debugPrint("📦 [CheckoutVM] Catalog Product Synced: $name (৳$price)");
    checkoutData.productId = id;
    checkoutData.productModel = name;
    checkoutData.brandName = brandName;
    checkoutData.mrp = price;
    checkoutData.saleType = saleType;
    
    if (saleType == 'EMI') {
      checkoutData.emiMode = 'CREATE_NEW_PLAN';
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
    }

    final exists = productList.any((p) => p.id == id);
    if (!exists) {
      productList.add(DropdownItemModel(
        id: id, name: name, price: price,
        rawJson: {'id': id, 'name': name, 'mrp': price}
      ));
    }
    onProductSelected(id);
    recalculateEmi();
    notifyListeners();
  }

  void recalculateEmi() {
    if (checkoutData.saleType != 'EMI') {
      checkoutData.monthlyEmi = 0;
      return;
    }

    double mrp = checkoutData.mrp;

    if (checkoutData.emiMode == 'CREATE_NEW_PLAN') {
      int months = checkoutData.newPlanMonths;
      double dp = 0;
      if (checkoutData.downPaymentCalculationType == 'RATE') {
        double dpRate = double.tryParse(checkoutData.downPaymentCalculationRate) ?? 0;
        dp = (mrp * dpRate) / 100;
      } else {
        dp = double.tryParse(checkoutData.downPaymentAmount ?? '0') ?? checkoutData.downPayment;
      }
      
      // Update global DP for display
      checkoutData.downPayment = dp;
      checkoutData.emiTenureMonths = months;

      double rate = double.tryParse(checkoutData.appEmiChargeRate) ?? 0.0;
      double interest = (mrp * rate) / 100;
      double financed = mrp + interest - dp;
      checkoutData.monthlyEmi = months > 0 ? (financed / months) : 0;
      
    } else if (checkoutData.emiMode == 'REMAINING_BALANCE') {
       double upfront = checkoutData.customUpfrontPayment;
       int months = checkoutData.customEmiDurationMonths;
       double rate = double.tryParse(checkoutData.customAppEmiChargeRate) ?? 0.0;
       
       checkoutData.downPayment = upfront;
       checkoutData.emiTenureMonths = months;

       double interest = (mrp * rate) / 100;
       double financed = mrp + interest - upfront;
       checkoutData.monthlyEmi = months > 0 ? (financed / months) : 0;
    }
  }

  // ─────────────── Hierarchy Dropdowns ───────────────
  Future<void> fetchShops() async {
    _isFetchingDropdowns = true; notifyListeners();
    debugPrint(" [CheckoutVM] Fetching Shops...");
    try {
      final response = await http.get(Uri.parse(ApiEndPoint.shops), headers: _headers);
      debugPrint(" [CheckoutVM] Fetch Shops Code: ${response.statusCode}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        shopList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
      }
    } catch (e) { debugPrint(" [CheckoutVM] fetchShops Error: $e"); }
    _isFetchingDropdowns = false; notifyListeners();
  }

  Future<void> onShopSelected(String? shopId) async {
    debugPrint(" [CheckoutVM] Shop Selected: $shopId");
    checkoutData.shopId = shopId;
    agentList.clear(); managerList.clear(); salesPersonList.clear(); 
    notifyListeners();
    if (shopId == null) return;
    try {
      final res = await http.get(Uri.parse("${ApiEndPoint.agents}?shopId=$shopId"), headers: _headers);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        agentList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
      }
    } catch (e) { debugPrint(" [CheckoutVM] onShopSelected Error: $e"); }
    notifyListeners();
  }

  Future<void> onAgentSelected(String? agentId) async {
    debugPrint(" [CheckoutVM] Agent Selected: $agentId");
    checkoutData.agentId = agentId;
    managerList.clear(); salesPersonList.clear();
    notifyListeners();
    if (agentId == null) return;
    try {
      final res = await http.get(Uri.parse("${ApiEndPoint.managers}?agentId=$agentId"), headers: _headers);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        managerList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
      }
    } catch (e) { debugPrint(" [CheckoutVM] onAgentSelected Error: $e"); }
    notifyListeners();
  }

  Future<void> onManagerSelected(String? managerId) async {
    debugPrint(" [CheckoutVM] Manager Selected: $managerId");
    checkoutData.managerId = managerId;
    salesPersonList.clear();
    notifyListeners();
    if (managerId == null) return;
    try {
      final res = await http.get(Uri.parse("${ApiEndPoint.salesPersons}?managerId=$managerId"), headers: _headers);
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        salesPersonList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
      }
    } catch (e) { debugPrint(" [CheckoutVM] onManagerSelected Error: $e"); }
    notifyListeners();
  }

  Future<void> onSalesPersonSelected(String? salesPersonId) async {
    debugPrint("═══════════════════════════════════════════════════");
    debugPrint(" [CheckoutVM] onSalesPersonSelected() CALLED");
    debugPrint(" Sales Person ID: $salesPersonId");
    debugPrint("═══════════════════════════════════════════════════");

    // ─── ১. Sales Person ID  ───
    checkoutData.salesPersonId = salesPersonId;
    debugPrint(" [CheckoutVM] checkoutData.salesPersonId set to: ${checkoutData.salesPersonId}");

    // ─── ২. ───
    DropdownItemModel? currentProduct;
    if (checkoutData.productId != null) {
      debugPrint(" [CheckoutVM] Current Product ID: ${checkoutData.productId}");
      try {
        currentProduct = productList.firstWhere(
              (p) => p.id == checkoutData.productId,
          orElse: () {
            debugPrint(" [CheckoutVM] Current product not found in list!");
            return productList.isNotEmpty ? productList.first : DropdownItemModel(id: '', name: 'Not Found', rawJson: {});
          },
        );
        debugPrint(" [CheckoutVM] Current Product Name: ${currentProduct?.name}");
      } catch (e) {
        debugPrint(" [CheckoutVM] Error finding current product: $e");
      }
    } else {
      debugPrint(" [CheckoutVM] No product selected yet.");
    }

    // ─── ৩. প্রোডাক্ট লিস্ট ক্লিয়ার করা ───
    debugPrint("🗑️ [CheckoutVM] Clearing productList...");
    productList.clear();
    notifyListeners();
    debugPrint("✅ [CheckoutVM] productList cleared. Length: ${productList.length}");

    // ─── ৪. Sales Person ID NULL চেক ───
    if (salesPersonId == null) {
      debugPrint("⚠️ [CheckoutVM] Sales Person ID is NULL. Skipping API call.");
      debugPrint("═══════════════════════════════════════════════════");
      notifyListeners();
      return;
    }

    // ─── ৫. API URL তৈরি ───
    final String apiUrl = "${ApiEndPoint.products}?salesPersonId=$salesPersonId";
    debugPrint("🌐 [CheckoutVM] API URL: $apiUrl");

    // ─── ৬. API কল ───
    try {
      debugPrint("⏳ [CheckoutVM] Calling API...");
      final stopwatch = Stopwatch()..start();

      final res = await http.get(
        Uri.parse(apiUrl),
        headers: _headers,
      );

      stopwatch.stop();
      debugPrint("⏱️ [CheckoutVM] API Response Time: ${stopwatch.elapsedMilliseconds}ms");
      debugPrint("📡 [CheckoutVM] Response Status Code: ${res.statusCode}");

      // ─── ৭. রেসপন্স বডি ডিবাগ ───
      debugPrint("📄 [CheckoutVM] Raw Response Body (first 500 chars):");
      if (res.body.length > 500) {
        debugPrint("   ${res.body.substring(0, 500)}...");
      } else {
        debugPrint("   $res.body");
      }

      final data = jsonDecode(res.body);

      // ─── ৮. সাকসেস চেক ───
      if (res.statusCode == 200 && data['success'] == true) {
        debugPrint("✅ [CheckoutVM] API call SUCCESSFUL!");

        final List rawList = data['data'] ?? [];
        debugPrint("📊 [CheckoutVM] Total Products in Response: ${rawList.length}");

        // ─── ৯. প্রোডাক্ট লিস্ট পার্স ───
        productList = rawList.map((e) {
          final item = DropdownItemModel.fromJson(e);
          debugPrint("   📱 Product: ${item.id} | ${item.name} | Price: ${item.price}");
          return item;
        }).toList();

        debugPrint("✅ [CheckoutVM] Parsed ${productList.length} products successfully.");

        // ─── ১০. প্রিভিয়াস প্রোডাক্ট রিস্টোর ───
        if (currentProduct != null &&
            currentProduct!.id.isNotEmpty &&
            !productList.any((p) => p.id == currentProduct!.id)) {
          debugPrint("🔄 [CheckoutVM] Restoring previous product: ${currentProduct!.name}");
          productList.add(currentProduct);
          debugPrint("✅ [CheckoutVM] Product restored. Total products now: ${productList.length}");
        } else if (currentProduct != null) {
          debugPrint("✅ [CheckoutVM] Previous product already in list.");
        }

        // ─── ১১. প্রোডাক্ট লিস্টের সারাংশ ───
        debugPrint("📋 [CheckoutVM] FINAL PRODUCT LIST SUMMARY:");
        for (int i = 0; i < productList.length; i++) {
          final p = productList[i];
          debugPrint("   ${i+1}. ID: ${p.id} | Name: ${p.name} | Price: ${p.price}");
        }

      } else {
        debugPrint("❌ [CheckoutVM] API call FAILED!");
        debugPrint("   Success: ${data['success']}");
        debugPrint("   Message: ${data['message'] ?? 'No error message'}");
        debugPrint("   Status Code: ${res.statusCode}");
      }

    } catch (e, stackTrace) {
      debugPrint("❌ [CheckoutVM] EXCEPTION CAUGHT!");
      debugPrint("   Error: $e");
      debugPrint("   StackTrace: $stackTrace");
    }

    debugPrint("✅ [CheckoutVM] onSalesPersonSelected() COMPLETED");
    debugPrint("═══════════════════════════════════════════════════");

    notifyListeners();
  }
  Future<void> onProductSelected(String? productId) async {
    debugPrint(" [CheckoutVM] Product Selected: $productId");
    checkoutData.productId = productId;
    emiPlanList.clear();
    if (productId != null) {
      final selected = productList.firstWhere((p) => p.id == productId, orElse: () => DropdownItemModel(id: '', name: 'Not Found', rawJson: {}));
      checkoutData.mrp = selected.price ?? 0.0;
      checkoutData.productModel = selected.name;
      debugPrint(" [CheckoutVM] Product MRP: ${checkoutData.mrp}");

      final url = "${ApiEndPoint.emiPlans}?productId=$productId&isActive=true";
      try {
        final res = await http.get(Uri.parse(url), headers: _headers);
        final data = jsonDecode(res.body);
        if (res.statusCode == 200 && data['success'] == true) {
          emiPlanList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
        }
      } catch (e) { debugPrint(" [CheckoutVM] onProductSelected Error: $e"); }
    }
    recalculateEmi();
    notifyListeners();
  }

  Future<void> onEmiPlanSelected(String? emiPlanId) async {
    debugPrint(" [CheckoutVM] EMI Plan Selected: $emiPlanId");
    checkoutData.emiPlanId = emiPlanId;
    if (emiPlanId == null || checkoutData.productId == null) return;
    final url = ApiEndPoint.emiQuotation(emiPlanId);
    final body = {"productId": checkoutData.productId, "regularPrice": checkoutData.mrp.toString()};
    debugPrint(" [CheckoutVM] Requesting Quotation: $url");
    try {
      final res = await http.post(Uri.parse(url), headers: _headers, body: jsonEncode(body));
      debugPrint(" [CheckoutVM] Quotation Code: ${res.statusCode}");
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final q = data['data'];
        checkoutData.downPayment = double.tryParse(q['downPayment'].toString()) ?? 0.0;
        checkoutData.monthlyEmi = double.tryParse(q['monthlyEmi'].toString()) ?? 0.0;
        checkoutData.emiTenureMonths = int.tryParse(q['months']?.toString() ?? '0') ?? 0;
        debugPrint(" [CheckoutVM] Calculated DP: ${checkoutData.downPayment}, Monthly: ${checkoutData.monthlyEmi}");
      }
    } catch (e) { debugPrint(" [CheckoutVM] onEmiPlanSelected Error: $e"); }
    notifyListeners();
  }

  // ─────────────── Submission Logic ───────────────
  Future<bool> submitOrder() async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    debugPrint(" [CheckoutVM] Starting Order Submission...");
    try {
      if (checkoutData.saleType == 'Selling Price') {
        return await _submitSellingPriceCustomer();
      }

      if (checkoutData.emiMode == 'CREATE_NEW_PLAN') {
        final newId = await createNewEmiPlan();
        if (newId == null) {
          _isLoading = false; notifyListeners(); return false;
        }
      }
      return await _submitLoanApplication();
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<String?> createNewEmiPlan() async {
    final body = {
      "productId": checkoutData.productId,
      "name": checkoutData.newPlanName.isEmpty ? "${checkoutData.newPlanMonths} Month Plan" : checkoutData.newPlanName,
      "months": checkoutData.newPlanMonths,
      "downPaymentCalculationType": checkoutData.downPaymentCalculationType,
      "downPaymentCalculationRate": checkoutData.downPaymentCalculationRate,
      "downPaymentAmount": checkoutData.downPaymentAmount,
      "appEmiChargeType": checkoutData.appEmiChargeType,
      "appEmiChargeRate": checkoutData.appEmiChargeRate,
      "appEmiChargeAmount": checkoutData.appEmiChargeAmount,
      "cashbackRate": checkoutData.cashbackRate,
      "cashbackAmount": checkoutData.cashbackAmount,
      "isActive": true, "sortOrder": 0, "note": "Created from customer registration",
    };
    try {
      final res = await http.post(Uri.parse(ApiEndPoint.emiPlans), headers: _headers, body: jsonEncode(body));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        String id = data['data']['id'].toString();
        checkoutData.emiPlanId = id; checkoutData.emiTenureMonths = checkoutData.newPlanMonths;
        return id;
      } else {
        _errorMessage = data['error']?['message'] ?? 'Failed to create plan';
        return null;
      }
    } catch (e) { return null; }
  }

  Future<bool> _submitSellingPriceCustomer() async {
    final url = Uri.parse(ApiEndPoint.customers);
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $userToken';
    _addCommonFields(request);
    request.fields['downPayment'] = checkoutData.mrp.toString();
    request.fields['emiCharge'] = '0'; request.fields['emiTenureMonths'] = '0'; request.fields['monthlyEmi'] = '0';

    await _attachAllFiles(request);
    final response = await request.send();
    final body = await http.Response.fromStream(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      _isLoading = false; notifyListeners(); return true;
    }
    final data = jsonDecode(body.body);
    _errorMessage = data['error']?['message'] ?? 'Submission failed';
    _isLoading = false; notifyListeners(); return false;
  }

  Future<bool> _submitLoanApplication() async {
    final url = Uri.parse(ApiEndPoint.loanApplications);
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $userToken';
    _addCommonFields(request);

    if (checkoutData.emiMode == 'EXISTING_PLAN' || checkoutData.emiMode == 'CREATE_NEW_PLAN') {
      request.fields['emiCalculationMode'] = 'STANDARD_PLAN';
      request.fields['emiPlanId'] = checkoutData.emiPlanId ?? '';
      request.fields['planMonths'] = checkoutData.emiTenureMonths.toString();
      if (checkoutData.monthlyPaymentDate != null) request.fields['monthlyPaymentDate'] = checkoutData.monthlyPaymentDate!;
    } else if (checkoutData.emiMode == 'REMAINING_BALANCE') {
      request.fields['emiCalculationMode'] = 'REMAINING_BALANCE';
      request.fields['customUpfrontPayment'] = checkoutData.customUpfrontPayment.toString();
      request.fields['customEmiDurationMonths'] = checkoutData.customEmiDurationMonths.toString();
      request.fields['customAppEmiChargeType'] = checkoutData.customAppEmiChargeType;
      request.fields['customAppEmiChargeRate'] = checkoutData.customAppEmiChargeRate;
      request.fields['customCashbackRate'] = checkoutData.customCashbackRate;
      if (checkoutData.customEmiNote.isNotEmpty) request.fields['customEmiNote'] = checkoutData.customEmiNote;
      if (checkoutData.customAdditionalCharges.isNotEmpty) request.fields['customAdditionalChargeComponents'] = jsonEncode(checkoutData.customAdditionalCharges);
    }
    await _attachAllFiles(request);
    final response = await request.send();
    final body = await http.Response.fromStream(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      _isLoading = false; notifyListeners(); return true;
    }
    final data = jsonDecode(body.body);
    _errorMessage = data['error']?['message'] ?? 'Loan submission failed';
    _isLoading = false; notifyListeners(); return false;
  }

  void _addCommonFields(http.MultipartRequest request) {
    request.fields['issueDate'] = DateTime.now().toIso8601String().split('T')[0];
    request.fields['name'] = checkoutData.name; request.fields['phone'] = checkoutData.phone;
    request.fields['password'] = checkoutData.password.isEmpty ? '12345678' : checkoutData.password;
    request.fields['presentAddress'] = checkoutData.presentAddress; request.fields['permanentAddress'] = checkoutData.permanentAddress;
    request.fields['nidPassportNumber'] = checkoutData.nidPassportNumber;
    request.fields['sourceOfIncome'] = checkoutData.sourceOfIncome; request.fields['monthlyIncome'] = checkoutData.monthlyIncome.toString();
    request.fields['productId'] = checkoutData.productId ?? ''; request.fields['productModelId'] = checkoutData.productModelId ?? '';
    request.fields['mrp'] = checkoutData.mrp.toString(); request.fields['shopId'] = checkoutData.shopId ?? '';
    request.fields['agentId'] = checkoutData.agentId ?? ''; request.fields['managerId'] = checkoutData.managerId ?? '';
    request.fields['salesPersonId'] = checkoutData.salesPersonId ?? ''; request.fields['downPaymentMethod'] = checkoutData.downPaymentMethod;
    request.fields['incomeProofDocumentType'] = checkoutData.incomeProofDocumentType;
    if (checkoutData.downPaymentMethod == 'BANK') {
      request.fields['bankAccountName'] = checkoutData.bankAccountName ?? ''; request.fields['bankAccountNumber'] = checkoutData.bankAccountNumber ?? ''; request.fields['bankName'] = checkoutData.bankName ?? '';
    }
    final guarantors = checkoutData.guarantors.map((g) => g.toJson()).toList();
    request.fields['guarantors'] = jsonEncode(guarantors);
  }

  Future<void> _attachAllFiles(http.MultipartRequest request) async {
    Future<void> attach(String fieldName, File? file) async {
      if (file == null || !file.existsSync()) return;
      String ext = file.path.split('.').last.toLowerCase();
      String mimeSubtype = (ext == 'png') ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg');
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path, contentType: MediaType('image', mimeSubtype)));
    }
    await attach('customerImage', customerImageFile);
    await attach('customerNidFront', checkoutData.nidFront);
    await attach('customerNidBack', checkoutData.nidBack);
    await attach('incomeProofDocument', checkoutData.incomeProof);
    if (checkoutData.downPaymentMethod == 'BANK') await attach('bankReceipt', checkoutData.bankReceipt);
    for (int i = 0; i < checkoutData.guarantors.length; i++) {
      await attach('guarantor${i}NidFront', checkoutData.guarantors[i].nidFront);
      await attach('guarantor${i}NidBack', checkoutData.guarantors[i].nidBack);
    }
  }

  // Setters & Reset
  void resetStep() { _currentStep = 0; notifyListeners(); }
  void setPermanentAddress(String val) { checkoutData.permanentAddress = val; notifyListeners(); }
  void setIncomeProofType(String val) { checkoutData.incomeProofDocumentType = val; notifyListeners(); }
  void setMonthlyPaymentDate(String val) { checkoutData.monthlyPaymentDate = val; notifyListeners(); }
  void setProductModelId(String val) { checkoutData.productModelId = val; notifyListeners(); }
  void setSourceOfIncome(String val) { checkoutData.sourceOfIncome = val; notifyListeners(); }
  void setMonthlyIncome(double val) { checkoutData.monthlyIncome = val; notifyListeners(); }
  void setNidPassportNumber(String val) { checkoutData.nidPassportNumber = val; notifyListeners(); }
  void setCustomerImage(File image) { customerImageFile = image; notifyListeners(); }
  void setNidFront(File file) { checkoutData.nidFront = file; notifyListeners(); }
  void setNidBack(File file) { checkoutData.nidBack = file; notifyListeners(); }
  void setIncomeProof(File file) { checkoutData.incomeProof = file; notifyListeners(); }
  void addGuarantor() { checkoutData.guarantors.add(GuarantorInfo(type: 'NON_FAMILY', relationship: 'Friend')); notifyListeners(); }
  void removeGuarantor(int index) { if (checkoutData.guarantors.length > 1) { checkoutData.guarantors.removeAt(index); notifyListeners(); } }
  void setGuarantorNidFront(int index, File file) { if (index < checkoutData.guarantors.length) { checkoutData.guarantors[index].nidFront = file; notifyListeners(); } }
  void setGuarantorNidBack(int index, File file) { if (index < checkoutData.guarantors.length) { checkoutData.guarantors[index].nidBack = file; notifyListeners(); } }
  void setPaymentMethod(String method) { checkoutData.downPaymentMethod = method; notifyListeners(); }
  void setBankReceipt(File file) { checkoutData.bankReceipt = file; notifyListeners(); }
}
