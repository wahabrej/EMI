import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/constant/Token_storage.dart';
import '../model/OrderSummaryModel.dart';

class OrderSummaryViewModel extends ChangeNotifier {
  final AppStorage _appStorage = AppStorage();

  bool _isLoading = false;
  String? _errorMessage;
  Data? _summaryData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Data? get summaryData => _summaryData;

  Future<void> fetchOrderSummary({
    String? fromDate,
    String? toDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 🔹 AppStorage থেকে টোকেন রিড করা হচ্ছে
      final token = await _appStorage.getToken();

      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token missing. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Query parameters handling
      Map<String, String> queryParams = {};
      if (fromDate != null && fromDate.isNotEmpty) queryParams['from'] = fromDate;
      if (toDate != null && toDate.isNotEmpty) queryParams['to'] = toDate;

      final uri = Uri.parse('https://api.smartpay.click/loans/summary')
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
        final model = OrderSummaryModel.fromJson(data);
        _summaryData = model.data;
      } else {
        _errorMessage = 'Failed to load summary (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}