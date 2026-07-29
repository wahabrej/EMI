// lib/features/dashboard/viewmodels/sales_dashboard_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/sales_dashboard_model.dart';

class SalesDashboardViewModel extends ChangeNotifier {
  final AppStorage _appStorage = AppStorage();

  bool _isLoading = false;
  String? _errorMessage;
  Data? _dashboardData; // Updated to 'Data' model class

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Data? get dashboardData => _dashboardData;

  /// Fetch Sales Dashboard Data using stored Token & User ID
  Future<void> fetchSalesDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? token = await _appStorage.getToken();
      final String? userId = await _appStorage.getUserId();

      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token is missing. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (userId == null || userId.isEmpty) {
        _errorMessage = 'User ID is missing. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = ApiEndPoint.salesDashboardSummary(userId);

      debugPrint('================= 🌐 API REQUEST 🌐 =================');
      debugPrint('URL: $url');
      debugPrint('Headers: Authorization: Bearer $token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final salesModel = SalesDashboardModel.fromJson(body);

        if (salesModel.success == true) {
          _dashboardData = salesModel.data;
          debugPrint('✅ [SalesDashboardViewModel] Parsing Successful!');
        } else {
          _errorMessage = 'Failed to load dashboard data.';
        }
      } else {
        final body = jsonDecode(response.body);
        _errorMessage = body['message'] ??
            body['error']?['message'] ??
            'Server error occurred (${response.statusCode})';
      }
    } catch (e, stackTrace) {
      _errorMessage = 'Network connection failed: ${e.toString()}';
      debugPrint('💥 Exception Caught: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}