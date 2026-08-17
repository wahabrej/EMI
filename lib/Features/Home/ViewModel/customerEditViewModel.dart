// lib/features/customer/viewModel/CustomerEditViewModel.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/customerEditModel.dart';
import '../model/customer_detail_model.dart';

class CustomerEditViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  CustomerEditModel? _customerDetail;
  CustomerEditModel? get customerDetail => _customerDetail;

  EditData? get customerData => _customerDetail?.data;

  // ─── Fetch Customer Details ───
  Future<bool> fetchCustomerDetail(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    _customerDetail = null;
    notifyListeners();

    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('📋 [CustomerEditVM] ========== FETCH CUSTOMER DETAIL ==========');
    debugPrint('📋 [CustomerEditVM] Customer ID: $customerId');

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = ApiEndPoint.customerDetails(customerId);
      debugPrint('🌐 [CustomerEditVM] URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📊 [CustomerEditVM] Status Code: ${response.statusCode}');
      debugPrint('📄 [CustomerEditVM] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _customerDetail = CustomerEditModel.fromJson(data);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();

        debugPrint('✅ [CustomerEditVM] Customer details fetched successfully!');
        debugPrint('📋 [CustomerEditVM] Customer Name: ${_customerDetail?.data?.name}');
        debugPrint('📋 [CustomerEditVM] Customer Phone: ${_customerDetail?.data?.phone}');
        debugPrint('═══════════════════════════════════════════════════');
        return true;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? errorData['error']?['message'] ?? 'Failed to load customer details';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ [CustomerEditVM] Error: $_errorMessage');
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ [CustomerEditVM] Exception: $e');
      debugPrint('📚 [CustomerEditVM] StackTrace: $stackTrace');
      return false;
    }
  }

  // ─── ✅ Update Customer ───
  Future<bool> updateCustomer({
    required String customerId,
    required Map<String, dynamic> updatedData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('✏️ [CustomerEditVM] ========== UPDATE CUSTOMER ==========');
    debugPrint('✏️ [CustomerEditVM] Customer ID: $customerId');
    debugPrint('📝 [CustomerEditVM] Updated Data: $updatedData');

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = ApiEndPoint.updatePaymentDate(customerId);
      debugPrint('🌐 [CustomerEditVM] URL: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      debugPrint('📊 [CustomerEditVM] Status Code: ${response.statusCode}');
      debugPrint('📄 [CustomerEditVM] Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _successMessage = data['message'] ?? 'Customer updated successfully!';
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();

        // Refresh customer details after update
        await fetchCustomerDetail(customerId);

        debugPrint('✅ [CustomerEditVM] Customer updated successfully!');
        debugPrint('═══════════════════════════════════════════════════');
        return true;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? errorData['error']?['message'] ?? 'Failed to update customer';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ [CustomerEditVM] Error: $_errorMessage');
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ [CustomerEditVM] Exception: $e');
      debugPrint('📚 [CustomerEditVM] StackTrace: $stackTrace');
      return false;
    }
  }

  // ─── Clear Data ───
  void clearData() {
    _customerDetail = null;
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // ─── Getters ───
  String getCustomerName() {
    return _customerDetail?.data?.name ?? 'N/A';
  }

  String getCustomerPhone() {
    return _customerDetail?.data?.phone ?? 'N/A';
  }

  String getCustomerId() {
    return _customerDetail?.data?.displayId ?? 'N/A';
  }

  String getCustomerStatus() {
    return _customerDetail?.data?.status ?? 'ACTIVE';
  }

  String getCustomerIdType() {
    return _customerDetail?.data?.idType ?? 'NID';
  }
}