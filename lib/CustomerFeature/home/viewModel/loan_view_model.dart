import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../model/customer_loan_model.dart';

class CustomerLoanViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // লিস্টের জন্য
  List<Data> _loanList = [];
  List<Data> get loanList => _loanList;

  // সিঙ্গেল লোন ডিটেইলসের জন্য (Data টাইপ)
  Data? _selectedLoanDetails;
  Data? get selectedLoanDetails => _selectedLoanDetails;

  // 🔹 সব লোন লোড করা
  Future<void> fetchLoans({String? status}) async {
    _setLoading(true);
    _errorMessage = null;
    debugPrint("🌐 [LoanVM] Fetching Loans (Status: $status)...");

    try {
      final token = await _tokenStorage.getToken();
      String url = ApiEndPoint.customerLoans;
      if (status != null) url += "?status=$status";

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint("📥 [LoanVM] Fetch Loans Status: ${response.statusCode}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _loanList = (data['data'] as List)
            .map((e) => Data.fromJson(e))
            .toList();
        debugPrint("✅ [LoanVM] Loaded ${_loanList.length} loans");
      } else {
        _errorMessage = data['message'] ?? "Failed to load loans";
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("🚨 [LoanVM] Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  // 🔹 নির্দিষ্ট লোনের ডিটেইলস
  Future<void> fetchLoanDetails(String loanId) async {
    _setLoading(true);
    _errorMessage = null;
    _selectedLoanDetails = null;
    debugPrint("🌐 [LoanVM] Fetching Details for Loan ID: $loanId...");

    try {
      final token = await _tokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiEndPoint.customerLoanById(loanId)),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint("📥 [LoanVM] Loan Details Status: ${response.statusCode}");
      debugPrint("📦 Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // data['data'] সরাসরি একটা লোন অবজেক্ট
        _selectedLoanDetails = Data.fromJson(data['data']);
        debugPrint("✅ [LoanVM] Loan Details Loaded Successfully");
      } else {
        _errorMessage = data['message'] ?? "Failed to load loan details";
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("🚨 [LoanVM] Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}