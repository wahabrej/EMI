import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/constant/Token_storage.dart';
import '../model/PaymentHistoryModel.dart';

class PaymentHistoryViewModel extends ChangeNotifier {
  final AppStorage _appStorage = AppStorage();

  bool _isLoading = false;
  String? _errorMessage;
  List<Data> _payments = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Data> get payments => _payments;

  Future<void> fetchPaymentHistory({String? loanId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 🔹 AppStorage থেকে টোকেন নেওয়া হচ্ছে
      final token = await _appStorage.getToken();

      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token missing. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      Map<String, String> queryParams = {};
      if (loanId != null && loanId.isNotEmpty) {
        queryParams['loanId'] = loanId;
      }

      final uri = Uri.parse('https://api.smartpay.click/payments')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final model = PaymentHistoryModel.fromJson(data);
        _payments = model.data ?? [];
      } else {
        _errorMessage = 'Failed to fetch payments (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}