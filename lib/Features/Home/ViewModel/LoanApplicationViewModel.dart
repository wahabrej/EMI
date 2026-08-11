import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/loan_application_detail_model.dart';

class LoanApplicationViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoanDetailData? _applicationDetails;
  LoanDetailData? get applicationDetails => _applicationDetails;

  Future<void> fetchApplicationDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _applicationDetails = null;
    notifyListeners();

    debugPrint('🔍 [ViewModel] ========== FETCH START ==========');
    debugPrint('🔍 [ViewModel] ID: $id');

    try {
      final token = await _tokenStorage.getToken();
      debugPrint('🔑 [ViewModel] Token: ${token != null ? 'Available' : 'NULL'}');

      if (token == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Try both endpoints
      final url1 = ApiEndPoint.loanApplicationById(id);
      final url2 = ApiEndPoint.getLoanById(id);

      debugPrint('🌐 [ViewModel] URL 1: $url1');
      debugPrint('🌐 [ViewModel] URL 2: $url2');

      // Try first endpoint - /loan-applications/:id (for pending applications)
      debugPrint('📡 [ViewModel] Trying URL 1...');
      var response = await http.get(
        Uri.parse(url1),
        headers: headers,
      );

      debugPrint('📊 [ViewModel] URL 1 Status: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        debugPrint('📄 [ViewModel] URL 1 Response Preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      }

      // If first fails, try second endpoint - /loans/:id (for active loans)
      if (response.statusCode != 200) {
        debugPrint('⚠️ [ViewModel] URL 1 failed, trying URL 2...');
        response = await http.get(
          Uri.parse(url2),
          headers: headers,
        );
        debugPrint('📊 [ViewModel] URL 2 Status: ${response.statusCode}');
        if (response.body.isNotEmpty) {
          debugPrint('📄 [ViewModel] URL 2 Response Preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        }
      }

      // --- START: FULL RESPONSE LOGGING ---
      debugPrint('📦 [ViewModel] ========== FULL API RESPONSE ==========');
      debugPrint('📦 [ViewModel] Status Code: ${response.statusCode}');
      debugPrint('📦 [ViewModel] Headers: ${response.headers}');

      // Pretty print the JSON response
      try {
        final decoded = jsonDecode(response.body);
        const encoder = JsonEncoder.withIndent('  ');
        final prettyString = encoder.convert(decoded);
        debugPrint('📦 [ViewModel] Full Response Body (Pretty):\n$prettyString');

        // Log all top-level keys
        debugPrint('📦 [ViewModel] Top-level Keys: ${decoded.keys.join(', ')}');

        // Log data structure in detail
        if (decoded['success'] != null) {
          debugPrint('📦 [ViewModel] Success: ${decoded['success']}');
        }

        if (decoded['data'] != null) {
          debugPrint('📦 [ViewModel] Data Keys: ${decoded['data'].keys.join(', ')}');

          // Log each field in data
          final data = decoded['data'];
          debugPrint('📦 [ViewModel] ========== DATA FIELDS ==========');

          // Basic fields
          if (data['id'] != null) debugPrint('📦 [ViewModel] id: ${data['id']} (${data['id'].runtimeType})');
          if (data['displayId'] != null) debugPrint('📦 [ViewModel] displayId: ${data['displayId']} (${data['displayId'].runtimeType})');
          if (data['name'] != null) debugPrint('📦 [ViewModel] name: ${data['name']} (${data['name'].runtimeType})');
          if (data['phone'] != null) debugPrint('📦 [ViewModel] phone: ${data['phone']} (${data['phone'].runtimeType})');
          if (data['presentAddress'] != null) debugPrint('📦 [ViewModel] presentAddress: ${data['presentAddress']} (${data['presentAddress'].runtimeType})');
          if (data['permanentAddress'] != null) debugPrint('📦 [ViewModel] permanentAddress: ${data['permanentAddress']} (${data['permanentAddress'].runtimeType})');
          if (data['nidPassportNumber'] != null) debugPrint('📦 [ViewModel] nidPassportNumber: ${data['nidPassportNumber']} (${data['nidPassportNumber'].runtimeType})');
          if (data['sourceOfIncome'] != null) debugPrint('📦 [ViewModel] sourceOfIncome: ${data['sourceOfIncome']} (${data['sourceOfIncome'].runtimeType})');
          if (data['monthlyIncome'] != null) debugPrint('📦 [ViewModel] monthlyIncome: ${data['monthlyIncome']} (${data['monthlyIncome'].runtimeType})');
          if (data['status'] != null) debugPrint('📦 [ViewModel] status: ${data['status']} (${data['status'].runtimeType})');
          if (data['issueDate'] != null) debugPrint('📦 [ViewModel] issueDate: ${data['issueDate']} (${data['issueDate'].runtimeType})');
          if (data['createdAt'] != null) debugPrint('📦 [ViewModel] createdAt: ${data['createdAt']} (${data['createdAt'].runtimeType})');

          // Document fields
          if (data['customerImage'] != null) debugPrint('📦 [ViewModel] customerImage: ${data['customerImage']} (${data['customerImage'].runtimeType})');
          if (data['customerNidFront'] != null) debugPrint('📦 [ViewModel] customerNidFront: ${data['customerNidFront']} (${data['customerNidFront'].runtimeType})');
          if (data['customerNidBack'] != null) debugPrint('📦 [ViewModel] customerNidBack: ${data['customerNidBack']} (${data['customerNidBack'].runtimeType})');
          if (data['incomeProofDocument'] != null) debugPrint('📦 [ViewModel] incomeProofDocument: ${data['incomeProofDocument']} (${data['incomeProofDocument'].runtimeType})');
          if (data['incomeProofDocumentType'] != null) debugPrint('📦 [ViewModel] incomeProofDocumentType: ${data['incomeProofDocumentType']} (${data['incomeProofDocumentType'].runtimeType})');

          // Loan fields
          if (data['mrp'] != null) debugPrint('📦 [ViewModel] mrp: ${data['mrp']} (${data['mrp'].runtimeType})');
          if (data['downPayment'] != null) debugPrint('📦 [ViewModel] downPayment: ${data['downPayment']} (${data['downPayment'].runtimeType})');
          if (data['downPaymentMethod'] != null) debugPrint('📦 [ViewModel] downPaymentMethod: ${data['downPaymentMethod']} (${data['downPaymentMethod'].runtimeType})');
          if (data['planMonths'] != null) debugPrint('📦 [ViewModel] planMonths: ${data['planMonths']} (${data['planMonths'].runtimeType})');
          if (data['monthlyEmi'] != null) debugPrint('📦 [ViewModel] monthlyEmi: ${data['monthlyEmi']} (${data['monthlyEmi'].runtimeType})');

          // Remarks fields
          if (data['rejectionReason'] != null) debugPrint('📦 [ViewModel] rejectionReason: ${data['rejectionReason']} (${data['rejectionReason'].runtimeType})');
          if (data['approvalRemarks'] != null) debugPrint('📦 [ViewModel] approvalRemarks: ${data['approvalRemarks']} (${data['approvalRemarks'].runtimeType})');

          // Product
          if (data['product'] != null) {
            debugPrint('📦 [ViewModel] ========== PRODUCT DATA ==========');
            final product = data['product'];
            if (product['id'] != null) debugPrint('📦 [ViewModel] product.id: ${product['id']} (${product['id'].runtimeType})');
            if (product['name'] != null) debugPrint('📦 [ViewModel] product.name: ${product['name']} (${product['name'].runtimeType})');
            if (product['code'] != null) debugPrint('📦 [ViewModel] product.code: ${product['code']} (${product['code'].runtimeType})');
            if (product['price'] != null) debugPrint('📦 [ViewModel] product.price: ${product['price']} (${product['price'].runtimeType})');
            if (product['category'] != null) debugPrint('📦 [ViewModel] product.category: ${product['category']} (${product['category'].runtimeType})');
            // Log all product fields
            debugPrint('📦 [ViewModel] All product keys: ${product.keys.join(', ')}');
          }

          // Guarantors
          if (data['guarantors'] != null) {
            final guarantors = data['guarantors'] as List;
            debugPrint('📦 [ViewModel] ========== GUARANTORS (${guarantors.length}) ==========');
            for (int i = 0; i < guarantors.length; i++) {
              final g = guarantors[i];
              debugPrint('📦 [ViewModel] Guarantor ${i + 1}:');
              if (g['name'] != null) debugPrint('📦 [ViewModel]   name: ${g['name']} (${g['name'].runtimeType})');
              if (g['phone'] != null) debugPrint('📦 [ViewModel]   phone: ${g['phone']} (${g['phone'].runtimeType})');
              if (g['relationship'] != null) debugPrint('📦 [ViewModel]   relationship: ${g['relationship']} (${g['relationship'].runtimeType})');
              if (g['nidFront'] != null) debugPrint('📦 [ViewModel]   nidFront: ${g['nidFront']} (${g['nidFront'].runtimeType})');
              if (g['nidBack'] != null) debugPrint('📦 [ViewModel]   nidBack: ${g['nidBack']} (${g['nidBack'].runtimeType})');
              if (g['email'] != null) debugPrint('📦 [ViewModel]   email: ${g['email']} (${g['email'].runtimeType})');
              if (g['address'] != null) debugPrint('📦 [ViewModel]   address: ${g['address']} (${g['address'].runtimeType})');
              // Log all guarantor keys
              debugPrint('📦 [ViewModel]   All guarantor keys: ${g.keys.join(', ')}');
            }
          }

          // Any additional fields not covered
          final allKeys = data.keys.toList();
          final coveredKeys = [
            'id', 'displayId', 'name', 'phone', 'presentAddress', 'permanentAddress',
            'nidPassportNumber', 'sourceOfIncome', 'monthlyIncome', 'status', 'issueDate',
            'createdAt', 'customerImage', 'customerNidFront', 'customerNidBack',
            'incomeProofDocument', 'incomeProofDocumentType', 'mrp', 'downPayment',
            'downPaymentMethod', 'planMonths', 'monthlyEmi', 'rejectionReason',
            'approvalRemarks', 'product', 'guarantors'
          ];
          final missingKeys = allKeys.where((k) => !coveredKeys.contains(k)).toList();
          if (missingKeys.isNotEmpty) {
            debugPrint('📦 [ViewModel] ⚠️ Additional fields found: ${missingKeys.join(', ')}');
            for (var key in missingKeys) {
              debugPrint('📦 [ViewModel]   $key: ${data[key]} (${data[key].runtimeType})');
            }
          }
        }

        // Check for errors
        if (decoded['error'] != null) {
          debugPrint('📦 [ViewModel] Error field: ${decoded['error']}');
          if (decoded['error']['message'] != null) {
            debugPrint('📦 [ViewModel] Error message: ${decoded['error']['message']}');
          }
        }
        if (decoded['message'] != null) {
          debugPrint('📦 [ViewModel] Message: ${decoded['message']}');
        }

      } catch (e) {
        debugPrint('❌ [ViewModel] Error parsing JSON: $e');
        debugPrint('📄 [ViewModel] Raw response: ${response.body}');
      }

      debugPrint('📦 [ViewModel] ========== END FULL RESPONSE ==========');
      // --- END: FULL RESPONSE LOGGING ---

      final data = jsonDecode(response.body);
      debugPrint('📦 [ViewModel] Response Keys: ${data.keys}');

      if (response.statusCode == 200) {
        // Check different response structures
        dynamic detailData;

        if (data['success'] == true) {
          if (data.containsKey('data')) {
            detailData = data['data'];
            debugPrint('✅ [ViewModel] Using data["data"]');
          } else {
            detailData = data;
            debugPrint('✅ [ViewModel] Using root data');
          }
        } else if (data.containsKey('data')) {
          detailData = data['data'];
          debugPrint('✅ [ViewModel] Using data["data"] without success flag');
        } else {
          detailData = data;
          debugPrint('✅ [ViewModel] Using root data');
        }

        if (detailData != null) {
          _applicationDetails = LoanDetailData.fromJson(detailData);
          _errorMessage = null;

          debugPrint('✅ [ViewModel] ========== PARSED MODEL ==========');
          debugPrint('📋 [ViewModel] ID: ${_applicationDetails?.id}');
          debugPrint('📋 [ViewModel] Display ID: ${_applicationDetails?.displayId}');
          debugPrint('📋 [ViewModel] Name: ${_applicationDetails?.name}');
          debugPrint('📋 [ViewModel] Phone: ${_applicationDetails?.phone}');
          debugPrint('📋 [ViewModel] Status: ${_applicationDetails?.status}');
          debugPrint('📋 [ViewModel] Present Address: ${_applicationDetails?.presentAddress}');
          debugPrint('📋 [ViewModel] Permanent Address: ${_applicationDetails?.permanentAddress}');
          debugPrint('📋 [ViewModel] NID/Passport: ${_applicationDetails?.nidPassportNumber}');
          debugPrint('📋 [ViewModel] Source of Income: ${_applicationDetails?.sourceOfIncome}');
          debugPrint('📋 [ViewModel] Monthly Income: ${_applicationDetails?.monthlyIncome}');
          debugPrint('📋 [ViewModel] Issue Date: ${_applicationDetails?.issueDate}');
          debugPrint('📋 [ViewModel] Created At: ${_applicationDetails?.createdAt}');
          debugPrint('📋 [ViewModel] MRP: ${_applicationDetails?.mrp}');
          debugPrint('📋 [ViewModel] Down Payment: ${_applicationDetails?.downPayment}');
          debugPrint('📋 [ViewModel] Down Payment Method: ${_applicationDetails?.downPaymentMethod}');
          debugPrint('📋 [ViewModel] Plan Months: ${_applicationDetails?.planMonths}');
          debugPrint('📋 [ViewModel] Monthly EMI: ${_applicationDetails?.monthlyEmi}');
          debugPrint('📋 [ViewModel] Rejection Reason: ${_applicationDetails?.rejectionReason}');
          debugPrint('📋 [ViewModel] Approval Remarks: ${_applicationDetails?.approvalRemarks}');
          debugPrint('📋 [ViewModel] Customer Image: ${_applicationDetails?.customerImage}');
          debugPrint('📋 [ViewModel] NID Front: ${_applicationDetails?.customerNidFront}');
          debugPrint('📋 [ViewModel] NID Back: ${_applicationDetails?.customerNidBack}');
          debugPrint('📋 [ViewModel] Income Proof: ${_applicationDetails?.incomeProofDocument}');
          debugPrint('📋 [ViewModel] Income Proof Type: ${_applicationDetails?.incomeProofDocumentType}');

          if (_applicationDetails?.product != null) {
            debugPrint('📋 [ViewModel] Product ID: ${_applicationDetails?.product?.id}');
            debugPrint('📋 [ViewModel] Product Name: ${_applicationDetails?.product?.name}');
            debugPrint('📋 [ViewModel] Product Code: ${_applicationDetails?.product?.code}');
          }

          if (_applicationDetails?.guarantors != null) {
            debugPrint('📋 [ViewModel] Guarantors Count: ${_applicationDetails?.guarantors?.length}');
            for (int i = 0; i < (_applicationDetails?.guarantors?.length ?? 0); i++) {
              final g = _applicationDetails!.guarantors![i];
              debugPrint('📋 [ViewModel] Guarantor ${i + 1}:');
              debugPrint('📋 [ViewModel]   Name: ${g.name}');
              debugPrint('📋 [ViewModel]   Phone: ${g.phone}');
              debugPrint('📋 [ViewModel]   Relationship: ${g.relationship}');
              debugPrint('📋 [ViewModel]   NID Front: ${g.nidFront}');
              debugPrint('📋 [ViewModel]   NID Back: ${g.nidBack}');
            }
          }
          debugPrint('✅ [ViewModel] ========== END PARSED MODEL ==========');
        } else {
          _errorMessage = 'No data found';
          debugPrint('❌ [ViewModel] No data found');
        }
      } else {
        _errorMessage = data['message'] ?? data['error']?['message'] ?? "Failed to load details (${response.statusCode})";
        debugPrint('❌ [ViewModel] Error: $_errorMessage');
        debugPrint('📄 [ViewModel] Full Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      debugPrint('❌ [ViewModel] Exception: $e');
      debugPrint('📚 [ViewModel] StackTrace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('🔍 [ViewModel] ========== FETCH COMPLETE ==========');
    }
  }

  Future<bool> approveApplication(String id, String remarks) async {
    debugPrint('✅ [ViewModel] Approving application: $id');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = ApiEndPoint.approveLoanApplication(id);
      debugPrint('🌐 [ViewModel] Approve URL: $url');

      final body = {
        'approvalRemarks': remarks.isNotEmpty ? remarks : 'Approved by system',
      };

      debugPrint('📤 [ViewModel] Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('📊 [ViewModel] Approve Status: ${response.statusCode}');
      debugPrint('📄 [ViewModel] Approve Response: ${response.body}');

      try {
        final decoded = jsonDecode(response.body);
        const encoder = JsonEncoder.withIndent('  ');
        debugPrint('📄 [ViewModel] Approve Response Pretty:\n${encoder.convert(decoded)}');
      } catch (e) {
        // Ignore
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? data['error']?['message'] ?? "Approval failed";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectApplication(String id, String reason, String remarks) async {
    debugPrint('❌ [ViewModel] Rejecting application: $id');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = ApiEndPoint.rejectLoanApplication(id);
      debugPrint('🌐 [ViewModel] Reject URL: $url');

      final body = {
        'rejectionReason': reason,
      };

      if (remarks.isNotEmpty) {
        body['approvalRemarks'] = remarks;
      }

      debugPrint('📤 [ViewModel] Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('📊 [ViewModel] Reject Status: ${response.statusCode}');
      debugPrint('📄 [ViewModel] Reject Response: ${response.body}');

      try {
        final decoded = jsonDecode(response.body);
        const encoder = JsonEncoder.withIndent('  ');
        debugPrint('📄 [ViewModel] Reject Response Pretty:\n${encoder.convert(decoded)}');
      } catch (e) {
        // Ignore
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? data['error']?['message'] ?? "Rejection failed";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearData() {
    _applicationDetails = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}