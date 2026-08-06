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

  // 🔹 Fetch Customer Payment History
  Future<void> fetchPaymentHistory() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final token = await _tokenStorage.getToken();
      final url = ApiEndPoint.customerPayments;

      debugPrint("📥 Fetching Payment History: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> list = body['data'];
          _paymentList = list
              .map((e) => CustomerPaymentHistoryModel.fromJson(e))
              .toList();
        } else {
          _paymentList = [];
        }
      } else {
        _errorMessage = "Failed to load payment history (${response.statusCode})";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // 🔹 Submit Universal Payment (Handles both BANK and BKASH)
  Future<bool> submitPayment({
    required String loanId,
    String? installmentId,
    required num amount,
    required String paymentMethod, // 'BANK' or 'BKASH'

    // Bank Fields
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankName,

    // bKash Fields
    String? senderMobileNumber,

    // Common Optional Fields
    String? referenceNumber, // Bank Ref or bKash TrxID
    String? remarks,
    File? receiptFile,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final token = await _tokenStorage.getToken();
    final url = ApiEndPoint.payInstallment;

    debugPrint("\n================ 📤 [SUBMIT PAYMENT START] ================");
    debugPrint("📌 Target URL: $url");
    debugPrint("💳 Payment Method: $paymentMethod");

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // 1. Mandatory Common Fields
      request.fields['loanId'] = loanId;
      request.fields['amount'] = amount.toString();
      request.fields['paymentMethod'] = paymentMethod;

      // 2. Optional Common Fields
      if (installmentId != null && installmentId.isNotEmpty) {
        request.fields['installmentId'] = installmentId;
      }
      if (referenceNumber != null && referenceNumber.isNotEmpty) {
        request.fields['referenceNumber'] = referenceNumber;
      }
      if (remarks != null && remarks.isNotEmpty) {
        request.fields['remarks'] = remarks;
      }

      // 3. Conditional Method Fields
      if (paymentMethod == 'BANK') {
        if (bankAccountName != null) request.fields['bankAccountName'] = bankAccountName;
        if (bankAccountNumber != null) request.fields['bankAccountNumber'] = bankAccountNumber;
        if (bankName != null) request.fields['bankName'] = bankName;
      } else if (paymentMethod == 'BKASH') {
        if (senderMobileNumber != null) request.fields['senderMobileNumber'] = senderMobileNumber;
      }

      // 4. File Attachment Handling
      if (receiptFile != null && await receiptFile.exists()) {
        String ext = receiptFile.path.split('.').last.toLowerCase();
        MediaType contentType = MediaType(
          'image',
          ext == 'png' ? 'png' : (ext == 'webp' ? 'webp' : 'jpeg'),
        );

        request.files.add(await http.MultipartFile.fromPath(
          'receipt',
          receiptFile.path,
          contentType: contentType,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("📥 Status Code: ${response.statusCode}");
      debugPrint("📦 Response Body: ${response.body}");

      if (response.headers['content-type']?.contains('application/json') ?? false) {
        final data = jsonDecode(response.body);

        if (response.statusCode == 201 || (response.statusCode == 200 && data['success'] == true)) {
          debugPrint("✅ Payment Submitted Successfully!");

          // Refresh list after success
          await fetchPaymentHistory();
          return true;
        } else {
          _errorMessage = data['message'] ?? "Payment submission failed";
          return false;
        }
      } else {
        _errorMessage = "Server error (${response.statusCode}). Non-JSON response.";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}