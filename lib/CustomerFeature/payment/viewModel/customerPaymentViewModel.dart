import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';

class CustomerPaymentViewModel extends ChangeNotifier {
  final AppStorage _appStorage = AppStorage();

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _payments = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<dynamic> get payments => _payments;

  Future<void> fetchPaymentHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _appStorage.getToken();
      if (token == null) {
        _errorMessage = "Session expired. Please login again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse(ApiEndPoint.customerPayments),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _payments = data['data'] ?? [];
        } else {
          _errorMessage = data['message'] ?? "Failed to load payment history";
        }
      } else {
        _errorMessage = "Server error: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Connection error: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}