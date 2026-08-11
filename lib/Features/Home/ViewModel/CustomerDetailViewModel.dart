import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/customer_detail_model.dart';

class CustomerDetailViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CustomerData? _customerDetail;
  CustomerData? get customerDetail => _customerDetail;

  Future<void> fetchCustomerDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _customerDetail = null;
    notifyListeners();

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = "Authentication token missing";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final url = ApiEndPoint.customerById(id);
      debugPrint("🌐 [CustomerDetailVM] Fetching: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _customerDetail = CustomerData.fromJson(data['data']);
        debugPrint("✅ [CustomerDetailVM] Loaded Successfully");
      } else {
        _errorMessage = data['message'] ?? data['error']?['message'] ?? "Failed to load customer details";
      }
    } catch (e) {
      _errorMessage = "Connection error: ${e.toString()}";
      debugPrint("❌ [CustomerDetailVM] Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
