import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../model/customer_payment_history_model.dart';

class CustomerPaymentHistoryViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CustomerPaymentHistoryModel> _paymentList = [];
  List<CustomerPaymentHistoryModel> get paymentList => _paymentList;

  // 🔹 Fetch Payment History
  Future<void> fetchPaymentHistory({String? loanId}) async {
    _setLoading(true);
    _errorMessage = null;
    debugPrint("🌐 [PaymentVM] Fetching Payments...");

    try {
      final token = await _tokenStorage.getToken();
      String url = ApiEndPoint.customerPayments;
      if (loanId != null) url += "?loanId=$loanId";

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint("📥 [PaymentVM] Status Code: ${response.statusCode}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _paymentList = (data['data'] as List)
            .map((e) => CustomerPaymentHistoryModel.fromJson(e))
            .toList();
        debugPrint("✅ [PaymentVM] Loaded ${_paymentList.length} payments");
      } else {
        _errorMessage = data['message'] ?? "Failed to load payments";
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("🚨 [PaymentVM] Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}