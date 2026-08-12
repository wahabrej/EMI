import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/singleLoanModel.dart';

class PaymentViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // ─── Single Loan Data ───
  SingleLoanModel? _loanData;
  SingleLoanModel? get loanData => _loanData;

  Data? get loanDetails => _loanData?.data;

  // ─── Fetch Single Loan Details ───
  Future<bool> fetchLoanDetails(String loanId) async {
    _isLoading = true;
    _errorMessage = null;
    _loanData = null;
    notifyListeners();

    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('📋 [PaymentVM] ========== FETCH LOAN DETAILS ==========');
    debugPrint('📋 [PaymentVM] Loan ID: $loanId');

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = ApiEndPoint.getLoanById(loanId);
      debugPrint('🌐 [PaymentVM] URL: $url');
      debugPrint('🔑 [PaymentVM] Token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📊 [PaymentVM] Status Code: ${response.statusCode}');
      debugPrint('📄 [PaymentVM] Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      try {
        const encoder = JsonEncoder.withIndent('  ');
        final prettyString = encoder.convert(data);
        debugPrint('📄 [PaymentVM] Pretty Response:\n$prettyString');
      } catch (_) {}

      if (response.statusCode == 200 && data['success'] == true) {
        _loanData = SingleLoanModel.fromJson(data);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();

        _logLoanDetails();
        debugPrint('✅ [PaymentVM] Loan details fetched successfully!');
        debugPrint('═══════════════════════════════════════════════════');
        return true;
      } else {
        _errorMessage = data['message'] ?? data['error']?['message'] ?? 'Failed to load loan details';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ [PaymentVM] Error: $_errorMessage');
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ [PaymentVM] Exception: $e');
      debugPrint('📚 [PaymentVM] StackTrace: $stackTrace');
      return false;
    }
  }

  // ─── Log Loan Details ───
  void _logLoanDetails() {
    final data = _loanData?.data;
    if (data == null) return;

    debugPrint('📋 [PaymentVM] ========== LOAN DETAILS ==========');
    debugPrint('📋 ID: ${data.id}');
    debugPrint('📋 Display ID: ${data.displayId}');
    debugPrint('📋 Status: ${data.status}');

    if (data.customer != null) {
      debugPrint('👤 [Customer] Name: ${data.customer!.name}');
      debugPrint('👤 [Customer] Phone: ${data.customer!.phone}');
      debugPrint('👤 [Customer] ID: ${data.customer!.id}');
    }

    if (data.product != null) {
      debugPrint('📱 [Product] Name: ${data.product!.name}');
      debugPrint('📱 [Product] Code: ${data.product!.code}');
    }

    if (data.calculationSnapshot != null) {
      final calc = data.calculationSnapshot!;
      debugPrint('📊 [Calculation] Regular Price: ${calc.regularPrice}');
      debugPrint('📊 [Calculation] Monthly EMI: ${calc.monthlyEmi}');
      debugPrint('📊 [Calculation] Plan Months: ${calc.planMonths}');
      debugPrint('📊 [Calculation] Down Payment Amount: ${calc.downPaymentAmount}');
      debugPrint('📊 [Calculation] Financed Amount: ${calc.financedAmount}');
      debugPrint('📊 [Calculation] Total Payable: ${calc.totalScheduledPayable}');
    }

    if (data.installments != null && data.installments!.isNotEmpty) {
      debugPrint('📋 [Installments] Count: ${data.installments!.length}');

      int paid = 0;
      int pending = 0;
      double totalDue = 0;

      for (var inst in data.installments!) {
        if (inst.status?.toUpperCase() == 'PAID') {
          paid++;
        } else {
          pending++;
          totalDue += double.tryParse(inst.totalDue ?? '0') ?? 0;
        }
      }

      debugPrint('📋 [Installments] Paid: $paid');
      debugPrint('📋 [Installments] Pending: $pending');
      debugPrint('📋 [Installments] Total Due: $totalDue');

      final nextInst = getNextInstallment();
      if (nextInst != null) {
        debugPrint('📋 [Next Installment] #${nextInst.installmentNumber}');
        debugPrint('📋 [Next Installment] Due Date: ${nextInst.dueDate}');
        debugPrint('📋 [Next Installment] Total Due: ${nextInst.totalDue}');
        debugPrint('📋 [Next Installment] Due Amount: ${getNextInstallmentDueAmount()}');
      }
    }
  }

  // ─── Get Next Installment ───
  Installments? getNextInstallment() {
    final data = _loanData?.data;
    if (data?.installments == null || data!.installments!.isEmpty) return null;

    final unpaid = data.installments!
        .where((inst) => inst.status?.toUpperCase() != 'PAID')
        .toList();

    if (unpaid.isEmpty) return null;

    unpaid.sort((a, b) {
      final dateA = DateTime.tryParse(a.dueDate ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b.dueDate ?? '') ?? DateTime.now();
      return dateA.compareTo(dateB);
    });

    return unpaid.first;
  }

  // ─── Get Next Installment Due Amount ───
  double getNextInstallmentDueAmount() {
    final nextInst = getNextInstallment();
    if (nextInst == null) return 0;

    double eligibleCashback = 0;
    if (nextInst.cashbackStatus?.toUpperCase() == 'PENDING') {
      try {
        final dueDate = DateTime.parse(nextInst.dueDate ?? '');
        if (DateTime.now().isBefore(dueDate)) {
          eligibleCashback = double.tryParse(nextInst.cashbackAmount ?? '0') ?? 0;
        }
      } catch (_) {}
    }

    double totalDue = double.tryParse(nextInst.totalDue ?? '0') ?? 0;
    double remainingAmount = double.tryParse(nextInst.remainingAmount ?? '0') ?? 0;
    double penaltyAmount = double.tryParse(nextInst.penaltyAmount ?? '0') ?? 0;

    if (totalDue > 0) {
      return (totalDue - eligibleCashback).clamp(0, double.infinity);
    } else {
      return (remainingAmount + penaltyAmount - eligibleCashback).clamp(0, double.infinity);
    }
  }

  // ─── Get Total Outstanding ───
  double getTotalOutstanding() {
    final data = _loanData?.data;
    if (data?.installments == null || data!.installments!.isEmpty) return 0;

    double total = 0;
    for (var inst in data.installments!) {
      if (inst.status?.toUpperCase() != 'PAID') {
        total += double.tryParse(inst.totalDue ?? '0') ?? 0;
      }
    }
    return total;
  }

  // ─── Get Paid Installments Count ───
  int getPaidInstallmentsCount() {
    final data = _loanData?.data;
    if (data?.installments == null || data!.installments!.isEmpty) return 0;

    return data.installments!
        .where((inst) => inst.status?.toUpperCase() == 'PAID')
        .length;
  }

  // ─── Get Pending Installments Count ───
  int getPendingInstallmentsCount() {
    final data = _loanData?.data;
    if (data?.installments == null || data!.installments!.isEmpty) return 0;

    return data.installments!
        .where((inst) => inst.status?.toUpperCase() != 'PAID')
        .length;
  }

  // ─── Get Customer Name ───
  String getCustomerName() {
    return _loanData?.data?.customer?.name ?? 'N/A';
  }

  // ─── Get Customer Phone ───
  String getCustomerPhone() {
    return _loanData?.data?.customer?.phone ?? 'N/A';
  }

  // ─── Get Product Name ───
  String getProductName() {
    return _loanData?.data?.product?.name ?? 'N/A';
  }

  // ─── Get Loan Amount ───
  double getLoanAmount() {
    final price = _loanData?.data?.calculationSnapshot?.regularPrice;
    return double.tryParse(price ?? '0') ?? 0;
  }

  // ─── Get Monthly EMI ───
  double getMonthlyEmi() {
    final emi = _loanData?.data?.calculationSnapshot?.monthlyEmi;
    return double.tryParse(emi ?? '0') ?? 0;
  }

  // ─── Get Tenure ───
  int getTenure() {
    return _loanData?.data?.calculationSnapshot?.planMonths ?? 0;
  }

  // ─── Get Loan Status ───
  String getLoanStatus() {
    return _loanData?.data?.status ?? 'N/A';
  }

  // ─── Check if Loan is Collectible ───
  bool isLoanCollectible() {
    final status = _loanData?.data?.status?.toUpperCase() ?? '';
    return status == 'APPROVED' || status == 'ACTIVE' || status == 'DISBURSED';
  }

  // ─── 🔥 Payment Submit (Staff Collection API) ───
  Future<bool> submitPayment({
    required String loanId,
    String? installmentId,
    required String amount,
    String paymentMethod = 'CASH',
    String? bankAccountName,
    String? bankAccountNumber,
    String? bankName,
    String? senderMobileNumber,
    String? referenceNumber,
    String? remarks,
    File? receipt,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    debugPrint('💰 [Payment] ========== SUBMITTING PAYMENT ==========');
    debugPrint('💰 [Payment] Loan ID: $loanId');
    debugPrint('💰 [Payment] Installment ID: $installmentId');
    debugPrint('💰 [Payment] Amount: $amount');
    debugPrint('💰 [Payment] Method: $paymentMethod');
    debugPrint('💰 [Payment] Reference: $referenceNumber');
    debugPrint('💰 [Payment] Remarks: $remarks');
    debugPrint('💰 [Payment] Receipt: ${receipt?.path ?? 'NULL'}');

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 🔥 Staff Collection API ব্যবহার করুন
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndPoint.collectPayment), // 🔥 collectPayment ব্যবহার করুন
      );

      // Headers
      request.headers['Authorization'] = 'Bearer $token';
      debugPrint('🔑 [Payment] Token: ${token.substring(0, 20)}...');

      // ─── Form Fields ───
      request.fields['loanId'] = loanId;
      request.fields['amount'] = amount;
      request.fields['paymentMethod'] = paymentMethod;
      request.fields['collectedAt'] = DateTime.now().toIso8601String();

      // Reference Number
      if (referenceNumber != null && referenceNumber.isNotEmpty) {
        request.fields['referenceNumber'] = referenceNumber;
      }

      // Remarks
      if (remarks != null && remarks.isNotEmpty) {
        request.fields['remarks'] = remarks;
      }

      // ─── Receipt File ───
      if (receipt != null && receipt.existsSync()) {
        String ext = receipt.path.split('.').last.toLowerCase();
        String mimeType = _getMimeType(ext);
        request.files.add(
          await http.MultipartFile.fromPath(
            'receipt',
            receipt.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
        debugPrint('📎 [Payment] Receipt attached: ${receipt.path.split('/').last} ($mimeType)');
      } else {
        debugPrint('⚠️ [Payment] No receipt attached');
      }

      // ─── Log Request ───
      debugPrint('📤 [Payment] Request Fields: ${request.fields}');
      debugPrint('📤 [Payment] Request Files: ${request.files.length}');

      // ─── Send Request ───
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('📊 [Payment] Status Code: ${response.statusCode}');
      debugPrint('📄 [Payment] Response: $responseBody');

      final data = jsonDecode(responseBody);

      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        _successMessage = data['message'] ?? 'Payment submitted successfully';
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        debugPrint('✅ [Payment] Payment successful!');
        return true;
      } else {
        _errorMessage = data['message'] ?? data['error']?['message'] ?? 'Payment failed';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ [Payment] Payment failed: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('❌ [Payment] Exception: $e');
      return false;
    }
  }

  // ─── Get MIME Type ───
  String _getMimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  void clearData() {
    _loanData = null;
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}