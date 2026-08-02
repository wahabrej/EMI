import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../model/customer_dashboard_model.dart';

class CustomerHomeViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isPaymentLoading = false;
  bool get isPaymentLoading => _isPaymentLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CustomerDashboardModel? _dashboardData;
  CustomerDashboardModel? get dashboardData => _dashboardData;

  // 🔹 Fetch Dashboard Data
  Future<void> fetchDashboard() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final token = await _tokenStorage.getToken();
      debugPrint("🔑 Token: ${token != null ? 'Found' : 'NULL'}");

      if (token == null) {
        _errorMessage = "Authentication token missing.";
        _setLoading(false);
        return;
      }

      final url = ApiEndPoint.customerDashboard;
      debugPrint("🌐 [Dashboard] Requesting: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("📥 [Dashboard] Status Code: ${response.statusCode}");
      debugPrint("📦 [Dashboard] Raw Body: ${response.body}");

      final data = jsonDecode(response.body);
      debugPrint("🧩 [Dashboard] Parsed success: ${data['success']}");

      if (response.statusCode == 200 && data['success'] == true) {

        // ─── এখানে দুইভাবে ট্রাই করছি ───
        try {
          // Way 1: পুরো response দিয়ে
          _dashboardData = CustomerDashboardModel.fromJson(data);
          debugPrint("✅ [Dashboard] Parsed with FULL response");
        } catch (e1) {
          debugPrint("⚠️ Way 1 failed: $e1");

          try {
            // Way 2: শুধু data অংশ দিয়ে
            _dashboardData = CustomerDashboardModel.fromJson({
              "success": true,
              "data": data['data']
            });
            debugPrint("✅ [Dashboard] Parsed with data wrapper");
          } catch (e2) {
            debugPrint("❌ Way 2 also failed: $e2");
            _errorMessage = "Model parsing failed";
          }
        }

        // ডেটা কতটুকু এসেছে চেক করা
        final loansCount = _dashboardData?.data?.loans?.length ?? 0;
        debugPrint("📊 Total Loans found: $loansCount");

        if (loansCount > 0) {
          for (int i = 0; i < loansCount; i++) {
            final loan = _dashboardData!.data!.loans![i];
            final emiCount = loan.installments?.length ?? 0;
            debugPrint("   Loan[$i] → ID: ${loan.id}, Status: ${loan.status}, EMIs: $emiCount");

            if (emiCount > 0) {
              for (var emi in loan.installments!) {
                debugPrint("      EMI #${emi.installmentNumber} → Status: ${emi.status}, Due: ${emi.dueDate}, Amount: ${emi.totalDue}");
              }
            }
          }
        } else {
          debugPrint("⚠️ No loans found inside dashboard data");
        }

      } else {
        _errorMessage = data['message'] ?? data['error']?['message'] ?? "Failed to load dashboard data.";
        debugPrint("❌ [Dashboard] API Error: $_errorMessage");
      }
    } catch (e, stack) {
      _errorMessage = "Network error: ${e.toString()}";
      debugPrint("🚨 [Dashboard] Exception: $e");
      debugPrint("Stack: $stack");
    } finally {
      _setLoading(false);
    }
  }

  // 🔹 Initiate Payment
  Future<String?> initiatePayment(String loanId, num amount, String method) async {
    _isPaymentLoading = true;
    notifyListeners();
    debugPrint("💳 [Payment] Initiating → Loan: $loanId | Amount: ৳$amount | Method: $method");

    try {
      final token = await _tokenStorage.getToken();
      final response = await http.post(
        Uri.parse(ApiEndPoint.initiateCustomerPayment),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'loanId': loanId,
          'amount': amount,
          'paymentMethod': method,
        }),
      );

      debugPrint("📥 [Payment] Status: ${response.statusCode}");
      debugPrint("📦 [Payment] Body: ${response.body}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final result = data['data']?['paymentUrl'] ?? data['data']?['transactionId'];
        debugPrint("✅ [Payment] Success → $result");
        return result;
      } else {
        _errorMessage = data['message'] ?? "Payment initiation failed";
        debugPrint("❌ [Payment] Failed: $_errorMessage");
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("🚨 [Payment] Exception: $e");
      return null;
    } finally {
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}