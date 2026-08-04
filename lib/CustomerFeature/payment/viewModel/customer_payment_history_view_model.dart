import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../model/customer_payment_history_model.dart';

class CustomerPaymentHistoryViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CustomerPaymentHistoryModel> _paymentList = [];
  List<CustomerPaymentHistoryModel> get paymentList => _paymentList;

  // 🔹 Fetch Payment History
  Future<void> fetchPaymentHistory({String? loanId}) async {
    _setLoading(true);
    _errorMessage = null;

    final token = await _tokenStorage.getToken();
    String url = ApiEndPoint.customerPayments;
    if (loanId != null) url += "?loanId=$loanId";

    debugPrint("\n================ 🌐 [FETCH PAYMENTS START] ================");
    debugPrint("📌 URL: $url");
    debugPrint("🔑 Token Present: ${token != null && token.isNotEmpty}");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("📥 Status Code: ${response.statusCode}");
      debugPrint("📦 Raw Body: ${response.body}");

      // Check if response is valid JSON
      if (response.headers['content-type']?.contains('application/json') ?? false) {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && data['success'] == true) {
          _paymentList = (data['data'] as List)
              .map((e) => CustomerPaymentHistoryModel.fromJson(e))
              .toList();
          debugPrint("✅ Loaded ${_paymentList.length} payments successfully.");
        } else {
          _errorMessage = data['message'] ?? "Failed to load payments";
          debugPrint("⚠️ Server Error Message: $_errorMessage");
        }
      } else {
        _errorMessage = "Server returned non-JSON response (${response.statusCode})";
        debugPrint("🚨 [Non-JSON Response] Check endpoint URL or backend server.");
      }
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      debugPrint("🚨 [Fetch Exception]: $e");
      debugPrint("🔍 StackTrace: $stackTrace");
    } finally {
      debugPrint("================ 🌐 [FETCH PAYMENTS END] ==================\n");
      _setLoading(false);
    }
  }

  // 🔹 Submit Bank Payment (Point 3 in Documentation)
  Future<bool> submitBankPayment({
    required String loanId,
    String? installmentId,
    required num amount,
    required String bankAccountName,
    required String bankAccountNumber,
    required String bankName,
    String? referenceNumber,
    String? remarks,
    required File receiptFile,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final token = await _tokenStorage.getToken();
    final url = ApiEndPoint.submitBankPayment;

    debugPrint("\n================ 📤 [SUBMIT BANK PAYMENT START] ================");
    debugPrint("📌 Endpoint Target: $url");
    debugPrint("🔑 Token Present: ${token != null && token.isNotEmpty}");

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Required Form Fields
      request.fields['loanId'] = loanId;
      request.fields['amount'] = amount.toString();
      request.fields['bankAccountName'] = bankAccountName;
      request.fields['bankAccountNumber'] = bankAccountNumber;
      request.fields['bankName'] = bankName;

      // Optional Fields
      if (installmentId != null && installmentId.isNotEmpty) {
        request.fields['installmentId'] = installmentId;
      }
      if (referenceNumber != null && referenceNumber.isNotEmpty) {
        request.fields['referenceNumber'] = referenceNumber;
      }
      if (remarks != null && remarks.isNotEmpty) {
        request.fields['remarks'] = remarks;
      }

      // Receipt File Inspection & Validation
      if (!await receiptFile.exists()) {
        throw Exception("Receipt file does not exist at path: ${receiptFile.path}");
      }

      int fileSizeInBytes = await receiptFile.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      String ext = receiptFile.path.split('.').last.toLowerCase();

      debugPrint("📋 Form Fields: ${request.fields}");
      debugPrint("📁 Receipt File Path: ${receiptFile.path}");
      debugPrint("📏 Receipt File Size: ${fileSizeInMB.toStringAsFixed(2)} MB");
      debugPrint("🏷️ File Extension: $ext");

      if (fileSizeInMB > 5.0) {
        debugPrint("⚠️ Warning: File size exceeds 5 MB limit!");
      }

      MediaType contentType = MediaType(
        'image',
        ext == 'png' ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'receipt',
        receiptFile.path,
        contentType: contentType,
      ));

      debugPrint("🚀 Sending Multipart Request...");
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("📥 Status Code: ${response.statusCode}");
      debugPrint("📦 Response Headers: ${response.headers}");
      debugPrint("📦 Raw Response Body: ${response.body}");

      // Safe Parsing Logic
      if (response.headers['content-type']?.contains('application/json') ?? false) {
        final data = jsonDecode(response.body);

        if (response.statusCode == 201 || (response.statusCode == 200 && data['success'] == true)) {
          debugPrint("✅ Bank Payment Submitted Successfully!");
          return true;
        } else {
          _errorMessage = data['message'] ?? data['error']?['message'] ?? "Bank payment submission failed";
          debugPrint("⚠️ API Returned Error: $_errorMessage");
          return false;
        }
      } else {
        // If Server returned HTML (e.g. 404/500 internal server error page)
        _errorMessage = "Server error (${response.statusCode}). Endpoint not found or Server crash.";
        debugPrint("🚨 [Non-JSON Response] Backend returned HTML/Text response instead of JSON!");
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      debugPrint("🚨 [Submit Bank Exception]: $e");
      debugPrint("🔍 StackTrace: $stackTrace");
      return false;
    } finally {
      _isSubmitting = false;
      debugPrint("================ 📤 [SUBMIT BANK PAYMENT END] ==================\n");
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}