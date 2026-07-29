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
      debugPrint("🔑 [CheckoutVM] Token set from constructor");
    } else {
      userToken = await _tokenStorage.getToken() ?? "";
      debugPrint("🔑 [CheckoutVM] Token loaded from storage: ${userToken.isNotEmpty ? 'SUCCESS' : 'EMPTY'}");
    }
    await fetchShops();
  }

  // Helper to allow external widgets to trigger notifyListeners()
  void notify() => notifyListeners();

  // ─────────────── Hierarchy Dropdowns ───────────────
  Future<void> fetchShops() async {
    _isFetchingDropdowns = true;
    notifyListeners();
    debugPrint("🌐 [API Call] GET -> ${ApiEndPoint.shops}");
    try {
      final response = await http.get(Uri.parse(ApiEndPoint.shops), headers: _headers);
      debugPrint("📩 [API Response] Status Code: ${response.statusCode}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        shopList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
        debugPrint("✅ [CheckoutVM] Loaded ${shopList.length} shops");
      } else {
        debugPrint("⚠️ [CheckoutVM] Failed to load shops: ${data['message'] ?? 'Unknown Error'}");
      }
    } catch (e, stackTrace) {
      debugPrint("🚨 fetchShops Error: $e");
      debugPrint("📌 StackTrace: $stackTrace");
    }
    _isFetchingDropdowns = false;
    notifyListeners();
  }

  Future<void> onShopSelected(String? shopId) async {
    debugPrint("👉 [Selection] Shop Selected ID: $shopId");
    checkoutData.shopId = shopId;
    agentList.clear(); managerList.clear(); salesPersonList.clear(); productList.clear();
    notifyListeners();
    if (shopId == null) return;
    final url = "${ApiEndPoint.agents}?shopId=$shopId";
    debugPrint("🌐 [API Call] GET -> $url");
    try {
      final res = await http.get(Uri.parse(url), headers: _headers);
      debugPrint("📩 [API Response] Status Code: ${res.statusCode}");
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        agentList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
        debugPrint("✅ [CheckoutVM] Loaded ${agentList.length} agents");
      }
    } catch (e) {
      debugPrint("🚨 onShopSelected Error: $e");
    }
    notifyListeners();
  }

  Future<void> onAgentSelected(String? agentId) async {
    debugPrint("👉 [Selection] Agent Selected ID: $agentId");
    checkoutData.agentId = agentId;
    managerList.clear(); salesPersonList.clear(); productList.clear();
    notifyListeners();
    if (agentId == null) return;
    final url = "${ApiEndPoint.managers}?agentId=$agentId";
    debugPrint("🌐 [API Call] GET -> $url");
    try {
      final res = await http.get(Uri.parse(url), headers: _headers);
      debugPrint("📩 [API Response] Status Code: ${res.statusCode}");
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        managerList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
        debugPrint("✅ [CheckoutVM] Loaded ${managerList.length} managers");
      }
    } catch (e) {
      debugPrint("🚨 onAgentSelected Error: $e");
    }
    notifyListeners();
  }

  Future<void> onManagerSelected(String? managerId) async {
    debugPrint("👉 [Selection] Manager Selected ID: $managerId");
    checkoutData.managerId = managerId;
    salesPersonList.clear(); productList.clear();
    notifyListeners();
    if (managerId == null) return;
    final url = "${ApiEndPoint.salesPersons}?managerId=$managerId";
    debugPrint("🌐 [API Call] GET -> $url");
    try {
      final res = await http.get(Uri.parse(url), headers: _headers);
      debugPrint("📩 [API Response] Status Code: ${res.statusCode}");
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        salesPersonList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
        debugPrint("✅ [CheckoutVM] Loaded ${salesPersonList.length} salespersons");
      }
    } catch (e) {
      debugPrint("🚨 onManagerSelected Error: $e");
    }
    notifyListeners();
  }

  Future<void> onSalesPersonSelected(String? salesPersonId) async {
    debugPrint("👉 [Selection] SalesPerson Selected ID: $salesPersonId");
    checkoutData.salesPersonId = salesPersonId;
    productList.clear();
    notifyListeners();
    if (salesPersonId == null) return;
    final url = "${ApiEndPoint.products}?salesPersonId=$salesPersonId";
    debugPrint("🌐 [API Call] GET -> $url");
    try {
      final res = await http.get(Uri.parse(url), headers: _headers);
      debugPrint("📩 [API Response] Status Code: ${res.statusCode}");
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        productList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
        debugPrint("✅ [CheckoutVM] Loaded ${productList.length} products");
      }
    } catch (e) {
      debugPrint("🚨 onSalesPersonSelected Error: $e");
    }
    notifyListeners();
  }

  Future<void> onProductSelected(String? productId) async {
    debugPrint("👉 [Selection] Product Selected ID: $productId");
    checkoutData.productId = productId;
    emiPlanList.clear();
    
    if (productId != null) {
      // Find the selected product in the list to extract its price
      final selected = productList.firstWhere(
        (p) => p.id == productId, 
        orElse: () => DropdownItemModel(id: '', name: 'Not Found', rawJson: {})
      );
      
      checkoutData.mrp = selected.price ?? 0.0;
      debugPrint("🏷️ [Product Selection] ID: $productId, Name: ${selected.name}, Price (MRP): ${checkoutData.mrp}");
      
      if (checkoutData.mrp == 0) {
        debugPrint("⚠️ [Warning] Product price is 0. Check API response for product list.");
        debugPrint("🔍 [Raw JSON]: ${selected.rawJson}");
      }

      final url = "${ApiEndPoint.emiPlans}?productId=$productId&isActive=true";
      debugPrint("🌐 [API Call] GET -> $url");
      try {
        final res = await http.get(Uri.parse(url), headers: _headers);
        debugPrint("📩 [API Response] Status Code: ${res.statusCode}");
        final data = jsonDecode(res.body);
        if (res.statusCode == 200 && data['success'] == true) {
          emiPlanList = (data['data'] as List).map((e) => DropdownItemModel.fromJson(e)).toList();
          debugPrint("✅ [CheckoutVM] Loaded ${emiPlanList.length} EMI plans");
        }
      } catch (e) {
        debugPrint("🚨 onProductSelected EMI Fetch Error: $e");
      }
    }
    notifyListeners();
  }

  Future<void> onEmiPlanSelected(String? emiPlanId) async {
    debugPrint("👉 [Selection] EMI Plan Selected ID: $emiPlanId");
    checkoutData.emiPlanId = emiPlanId;
    if (emiPlanId == null || checkoutData.productId == null) return;

    final url = ApiEndPoint.emiQuotation(emiPlanId);
    final body = {"productId": checkoutData.productId, "regularPrice": checkoutData.mrp.toString()};
    debugPrint("🌐 [API Call] POST -> $url");
    debugPrint("📦 [Quotation Body]: ${jsonEncode(body)}");

    try {
      final res = await http.post(Uri.parse(url), headers: _headers, body: jsonEncode(body));
      debugPrint("📩 [API Response] Status Code: ${res.statusCode}");
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final q = data['data'];
        checkoutData.downPayment = double.tryParse(q['downPayment'].toString()) ?? 0.0;
        checkoutData.monthlyEmi = double.tryParse(q['monthlyEmi'].toString()) ?? 0.0;
        checkoutData.emiTenureMonths = int.tryParse(q['months']?.toString() ?? '0') ?? 0;
        debugPrint("📊 [Quotation Calculated] DownPayment: ${checkoutData.downPayment}, MonthlyEMI: ${checkoutData.monthlyEmi}, Months: ${checkoutData.emiTenureMonths}");
      } else {
        debugPrint("⚠️ [Quotation Failed]: ${data['error']?['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      debugPrint("🚨 onEmiPlanSelected Error: $e");
    }
    notifyListeners();
  }

  // ─────────────── Order Submission Workflow (PDF Logic) ───────────────
  Future<String?> createNewEmiPlan() async {
    debugPrint("📝 [CheckoutVM] Creating New EMI Plan...");
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
      "isActive": true,
      "sortOrder": 0,
      "note": "Created from customer registration",
    };

    final url = ApiEndPoint.emiPlans;
    debugPrint("🌐 [API Call] POST -> $url");
    debugPrint("📦 [New EMI Plan Body]: ${jsonEncode(body)}");

    try {
      final res = await http.post(Uri.parse(url), headers: _headers, body: jsonEncode(body));
      debugPrint("📩 [API Response] Status Code: ${res.statusCode}");
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        String id = data['data']['id'].toString();
        checkoutData.emiPlanId = id;
        checkoutData.emiTenureMonths = checkoutData.newPlanMonths;
        debugPrint("✅ [CheckoutVM] New EMI Plan Created Successfully with ID: $id");
        return id;
      } else {
        _errorMessage = data['error']?['message'] ?? 'Failed to create plan';
        debugPrint("🚨 [CheckoutVM] New EMI Plan Creation Failed: $_errorMessage");
        return null;
      }
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      debugPrint("🚨 createNewEmiPlan Error: $e");
      debugPrint("📌 StackTrace: $stackTrace");
      return null;
    }
  }

  Future<bool> submitOrder() async {
    debugPrint("🚀 [CheckoutVM] Initiating Order Submission Process...");
    debugPrint("📋 [Order Context] SaleType: ${checkoutData.saleType}, EmiMode: ${checkoutData.emiMode}");

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (checkoutData.saleType == 'Selling Price') {
        debugPrint("➡️ [Flow Selected] Selling Price Customer Flow");
        return await _submitSellingPriceCustomer();
      }

      if (checkoutData.emiMode == 'CREATE_NEW_PLAN') {
        debugPrint("➡️ [Flow Selected] EMI - Create New Plan First");
        final newId = await createNewEmiPlan();
        if (newId == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      debugPrint("➡️ [Flow Selected] Submitting Loan Application Flow");
      return await _submitLoanApplication();
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      debugPrint("🚨 submitOrder Exception: $e");
      debugPrint("📌 StackTrace: $stackTrace");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _submitSellingPriceCustomer() async {
    final url = Uri.parse(ApiEndPoint.customers);
    debugPrint("🌐 [Multipart API] POST -> $url");

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $userToken';

    _addCommonFields(request);
    
    request.fields['downPayment'] = checkoutData.mrp.toString();
    request.fields['emiCharge'] = '0';
    request.fields['emiTenureMonths'] = '0';
    request.fields['monthlyEmi'] = '0';

    debugPrint("📦 [Multipart Text Fields]: ${request.fields}");
    await _attachAllFiles(request);

    debugPrint("⏳ Sending Multipart Request to /customers...");
    final response = await request.send();
    final body = await http.Response.fromStream(response);
    debugPrint("📩 [API Response] Status Code: ${response.statusCode}");
    debugPrint("📄 [API Body Response]: ${body.body}");

    final data = jsonDecode(body.body);

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("🎉 [Success] Customer Created Successfully!");
      return true;
    }
    _errorMessage = data['error']?['message'] ?? 'Submission failed';
    debugPrint("🚨 [Failure] Customer Creation Failed: $_errorMessage");
    return false;
  }

  Future<bool> _submitLoanApplication() async {
    final url = Uri.parse(ApiEndPoint.loanApplications);
    debugPrint("🌐 [Multipart API] POST -> $url");

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $userToken';

    _addCommonFields(request);

    if (checkoutData.emiMode == 'EXISTING_PLAN' || checkoutData.emiMode == 'CREATE_NEW_PLAN') {
      request.fields['emiCalculationMode'] = 'STANDARD_PLAN';
      request.fields['emiPlanId'] = checkoutData.emiPlanId ?? '';
      request.fields['planMonths'] = checkoutData.emiTenureMonths.toString();
      if (checkoutData.monthlyPaymentDate != null) {
        request.fields['monthlyPaymentDate'] = checkoutData.monthlyPaymentDate!;
      }
    } else if (checkoutData.emiMode == 'REMAINING_BALANCE') {
      request.fields['emiCalculationMode'] = 'REMAINING_BALANCE';
      request.fields['customUpfrontPayment'] = checkoutData.customUpfrontPayment.toString();
      request.fields['customEmiDurationMonths'] = checkoutData.customEmiDurationMonths.toString();
      request.fields['customAppEmiChargeType'] = checkoutData.customAppEmiChargeType;
      request.fields['customAppEmiChargeRate'] = checkoutData.customAppEmiChargeRate;
      request.fields['customCashbackRate'] = checkoutData.customCashbackRate;
      if (checkoutData.customEmiNote.isNotEmpty) request.fields['customEmiNote'] = checkoutData.customEmiNote;
      if (checkoutData.customAdditionalCharges.isNotEmpty) {
        request.fields['customAdditionalChargeComponents'] = jsonEncode(checkoutData.customAdditionalCharges);
      }
    }

    debugPrint("📦 [Multipart Text Fields]: ${request.fields}");
    await _attachAllFiles(request);

    debugPrint("⏳ Sending Multipart Request to /loan-applications...");
    final response = await request.send();
    final body = await http.Response.fromStream(response);
    debugPrint("📩 [API Response] Status Code: ${response.statusCode}");
    debugPrint("📄 [API Body Response]: ${body.body}");

    final data = jsonDecode(body.body);

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("🎉 [Success] Loan Application Submitted Successfully!");
      return true;
    }
    _errorMessage = data['error']?['message'] ?? 'Loan Application failed';
    debugPrint("🚨 [Failure] Loan Application Submission Failed: $_errorMessage");
    return false;
  }

  void _addCommonFields(http.MultipartRequest request) {
    request.fields['issueDate'] = DateTime.now().toIso8601String().split('T')[0];
    request.fields['name'] = checkoutData.name;
    request.fields['phone'] = checkoutData.phone;
    request.fields['password'] = checkoutData.password.isEmpty ? '12345678' : checkoutData.password;
    request.fields['presentAddress'] = checkoutData.presentAddress;
    request.fields['permanentAddress'] = checkoutData.permanentAddress;
    request.fields['nidPassportNumber'] = checkoutData.nidPassportNumber;
    request.fields['sourceOfIncome'] = checkoutData.sourceOfIncome;
    request.fields['monthlyIncome'] = checkoutData.monthlyIncome.toString();
    request.fields['productId'] = checkoutData.productId ?? '';
    request.fields['productModelId'] = checkoutData.productModelId ?? '';
    request.fields['mrp'] = checkoutData.mrp.toString();
    request.fields['shopId'] = checkoutData.shopId ?? '';
    request.fields['agentId'] = checkoutData.agentId ?? '';
    request.fields['managerId'] = checkoutData.managerId ?? '';
    request.fields['salesPersonId'] = checkoutData.salesPersonId ?? '';
    request.fields['downPaymentMethod'] = checkoutData.downPaymentMethod;
    request.fields['incomeProofDocumentType'] = checkoutData.incomeProofDocumentType;

    if (checkoutData.downPaymentMethod == 'BANK') {
      request.fields['bankAccountName'] = checkoutData.bankAccountName ?? '';
      request.fields['bankAccountNumber'] = checkoutData.bankAccountNumber ?? '';
      request.fields['bankName'] = checkoutData.bankName ?? '';
    }

    final guarantors = checkoutData.guarantors.map((g) => g.toJson()).toList();
    request.fields['guarantors'] = jsonEncode(guarantors);
  }

  Future<void> _attachAllFiles(http.MultipartRequest request) async {
    Future<void> attach(String fieldName, File? file) async {
      if (file == null) {
        debugPrint("📎 [File Attachment] Null file for field: '$fieldName'");
        return;
      }
      if (!file.existsSync()) {
        debugPrint("⚠️ [File Attachment] File does NOT exist at path: ${file.path}");
        return;
      }
      String ext = file.path.split('.').last.toLowerCase();
      String mimeSubtype = (ext == 'png') ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg');
      debugPrint("📎 [File Attachment] Attaching '$fieldName' -> Path: ${file.path} (mime: image/$mimeSubtype)");
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path, contentType: MediaType('image', mimeSubtype)));
    }

    await attach('customerImage', customerImageFile);
    await attach('customerNidFront', checkoutData.nidFront);
    await attach('customerNidBack', checkoutData.nidBack);
    await attach('incomeProofDocument', checkoutData.incomeProof);

    if (checkoutData.downPaymentMethod == 'BANK') {
      await attach('bankReceipt', checkoutData.bankReceipt);
    }

    for (int i = 0; i < checkoutData.guarantors.length; i++) {
      await attach('guarantor${i}NidFront', checkoutData.guarantors[i].nidFront);
      await attach('guarantor${i}NidBack', checkoutData.guarantors[i].nidBack);
    }
  }

  // ─────────────── Setters ───────────────
  void setPermanentAddress(String val) { checkoutData.permanentAddress = val; notifyListeners(); }
  void setIncomeProofType(String val) { checkoutData.incomeProofDocumentType = val; notifyListeners(); }
  void setMonthlyPaymentDate(String val) { checkoutData.monthlyPaymentDate = val; notifyListeners(); }
  void setProductModelId(String val) { checkoutData.productModelId = val; notifyListeners(); }
  void setSourceOfIncome(String val) { checkoutData.sourceOfIncome = val; notifyListeners(); }
  void setMonthlyIncome(double val) { checkoutData.monthlyIncome = val; notifyListeners(); }
  void setNidPassportNumber(String val) { checkoutData.nidPassportNumber = val; notifyListeners(); }

  void setCustomerImage(File image) {
    customerImageFile = image;
    debugPrint("📷 [Customer Image Set]: ${image.path}");
    notifyListeners();
  }

  void setNidFront(File file) {
    checkoutData.nidFront = file;
    debugPrint("🪪 [NID Front Set]: ${file.path}");
    notifyListeners();
  }

  void setNidBack(File file) {
    checkoutData.nidBack = file;
    debugPrint("🪪 [NID Back Set]: ${file.path}");
    notifyListeners();
  }

  void setIncomeProof(File file) {
    checkoutData.incomeProof = file;
    debugPrint("📄 [Income Proof Set]: ${file.path}");
    notifyListeners();
  }

  void addGuarantor() {
    checkoutData.guarantors.add(GuarantorInfo(type: 'NON_FAMILY', relationship: 'Friend'));
    debugPrint("👥 [Guarantor Added] Total: ${checkoutData.guarantors.length}");
    notifyListeners();
  }

  void removeGuarantor(int index) {
    if (checkoutData.guarantors.length > 1) {
      checkoutData.guarantors.removeAt(index);
      debugPrint("👥 [Guarantor Removed] Index $index removed. Total: ${checkoutData.guarantors.length}");
      notifyListeners();
    }
  }

  void setGuarantorNidFront(int index, File file) {
    if (index < checkoutData.guarantors.length) {
      checkoutData.guarantors[index].nidFront = file;
      debugPrint("🪪 [Guarantor $index NID Front Set]: ${file.path}");
      notifyListeners();
    }
  }

  void setGuarantorNidBack(int index, File file) {
    if (index < checkoutData.guarantors.length) {
      checkoutData.guarantors[index].nidBack = file;
      debugPrint("🪪 [Guarantor $index NID Back Set]: ${file.path}");
      notifyListeners();
    }
  }

  void setPaymentMethod(String method) {
    checkoutData.downPaymentMethod = method;
    debugPrint("💳 [Payment Method Set]: $method");
    notifyListeners();
  }

  void setBankReceipt(File file) {
    checkoutData.bankReceipt = file;
    debugPrint("🧾 [Bank Receipt Set]: ${file.path}");
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 5) {
      _currentStep++;
      debugPrint(" [Step Forward] Current Step: $_currentStep");
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      debugPrint(" [Step Back] Current Step: $_currentStep");
      notifyListeners();
    }
  }
}
