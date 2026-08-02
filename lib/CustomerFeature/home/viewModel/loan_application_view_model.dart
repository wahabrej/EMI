import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../model/customer_loan_application_model.dart';

class CustomerLoanApplicationViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CustomerLoanApplicationModel> _applications = [];
  List<CustomerLoanApplicationModel> get applications => _applications;

  CustomerLoanApplicationModel? _selectedApplication;
  CustomerLoanApplicationModel? get selectedApplication => _selectedApplication;

  // 🔹 Fetch all applications
  Future<void> fetchApplications() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final token = await _tokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiEndPoint.customerLoanApplications),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _applications = (data['data'] as List)
            .map((e) => CustomerLoanApplicationModel.fromJson(e))
            .toList();
      } else {
        _errorMessage = data['message'] ?? "Failed to load applications";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // 🔹 Point 9: Fetch specific application details
  Future<void> fetchApplicationDetails(String id) async {
    _setLoading(true);
    _errorMessage = null;
    debugPrint("🌐 [LoanAppVM] Fetching Application ID: $id...");

    try {
      final token = await _tokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiEndPoint.customerLoanApplicationById(id)),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _selectedApplication = CustomerLoanApplicationModel.fromJson(data['data']);
        debugPrint("✅ [LoanAppVM] Application details loaded");
      } else {
        _errorMessage = data['message'] ?? "Failed to load details";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}