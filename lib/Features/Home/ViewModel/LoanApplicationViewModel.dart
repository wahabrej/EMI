import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../Model/loan_application_detail_model.dart';

class LoanApplicationViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  LoanDetailData? _applicationDetails;
  LoanDetailData? get applicationDetails => _applicationDetails;

  Map<String, dynamic>? _rawData;
  Map<String, dynamic>? get rawData => _rawData;

  Future<void> fetchApplicationDetails(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _applicationDetails = null;
    _rawData = null;
    notifyListeners();

    debugPrint('🔍 [ViewModel] ========== FETCH START ==========');
    debugPrint('🔍 [ViewModel] ID: $id');

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // 🔥 ১ম: Loan Application এন্ডপয়েন্ট (Pending Applications)
      final url1 = ApiEndPoint.loanApplicationById(id);
      debugPrint('🌐 [ViewModel] URL 1 (Loan App): $url1');

      var response = await http.get(Uri.parse(url1), headers: headers);

      debugPrint('📊 [ViewModel] URL 1 Status: ${response.statusCode}');

      // 🔥 ২য়: যদি 404 বা 400 আসে, Loan এন্ডপয়েন্ট (Active Loans)
      if (response.statusCode == 404 || response.statusCode == 400) {
        final url2 = ApiEndPoint.getLoanById(id);
        debugPrint('🌐 [ViewModel] URL 2 (Active Loan): $url2');

        response = await http.get(Uri.parse(url2), headers: headers);
        debugPrint('📊 [ViewModel] URL 2 Status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      debugPrint('📦 [ViewModel] Response Keys: ${data.keys}');

      if (response.statusCode == 200) {
        dynamic detailData;

        if (data['success'] == true && data.containsKey('data')) {
          detailData = data['data'];
        } else if (data.containsKey('data')) {
          detailData = data['data'];
        } else {
          detailData = data;
        }

        if (detailData != null) {
          // Raw Data সংরক্ষণ করুন
          if (detailData is Map<String, dynamic>) {
            _rawData = detailData;
          } else {
            try {
              _rawData = detailData.toJson() as Map<String, dynamic>;
            } catch (_) {
              _rawData = {};
            }
          }

          // 🔥 Active Loan হলে ডকুমেন্ট ম্যাপিং করুন
          if (_rawData != null) {
            final status = _rawData!['status']?.toString().toUpperCase() ?? '';
            if (status == 'APPROVED' ||
                status == 'ACTIVE' ||
                status == 'DISBURSED') {
              debugPrint(
                '🔄 [ViewModel] Active Loan detected, mapping documents...',
              );
              _rawData = _mapActiveLoanFields(_rawData!);
            }
          }

          _applicationDetails = LoanDetailData.fromJson(detailData);
          _errorMessage = null;

          debugPrint('✅ [ViewModel] ========== PARSED MODEL ==========');
          debugPrint('📋 [ViewModel] ID: ${_applicationDetails?.id}');
          debugPrint('📋 [ViewModel] Status: ${_applicationDetails?.status}');
          debugPrint('📋 [ViewModel] Name: ${_applicationDetails?.name}');
          debugPrint(
            '📋 [ViewModel] Raw Data Keys: ${_rawData?.keys.join(', ')}',
          );

          if (_rawData != null) {
            debugPrint(
              '📄 [ViewModel] customerImageUrl: ${_rawData!['customerImageUrl']}',
            );
            debugPrint(
              '📄 [ViewModel] customerVideoUrl: ${_rawData!['customerVideoUrl']}',
            );
            debugPrint(
              '📄 [ViewModel] incomeProofUrl: ${_rawData!['incomeProofUrl']}',
            );
            debugPrint(
              '📄 [ViewModel] customerDocuments: ${_rawData!['customerDocuments']}',
            );
            debugPrint(
              '📄 [ViewModel] guarantorDocuments: ${_rawData!['guarantorDocuments']}',
            );
          }

          debugPrint('✅ [ViewModel] ========== END PARSED MODEL ==========');
        } else {
          _errorMessage = 'No data found';
        }
      } else {
        _errorMessage =
            data['message'] ??
            data['error']?['message'] ??
            "Failed to load details (${response.statusCode})";
        debugPrint('❌ [ViewModel] Error: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('❌ [ViewModel] Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('🔍 [ViewModel] ========== FETCH COMPLETE ==========');
    }
  }

  // ─── Active Loan Fields Map ───
  Map<String, dynamic> _mapActiveLoanFields(Map<String, dynamic> data) {
    debugPrint('🔄 [ViewModel] Mapping Active Loan fields...');

    if (data['customer'] != null && data['customer'] is Map<String, dynamic>) {
      final customer = data['customer'] as Map<String, dynamic>;
      debugPrint('📄 [ViewModel] Customer keys: ${customer.keys.join(', ')}');

      List<Map<String, dynamic>> docs = [];

      // 🔥 1. customerImageUrl
      if (customer['customerImageUrl'] != null &&
          customer['customerImageUrl'].toString().isNotEmpty) {
        docs.add({
          'url': customer['customerImageUrl'].toString(),
          'documentType': 'CUSTOMER_PHOTO',
        });
      }

      // 🔥 2. customerVideoUrl
      if (customer['customerVideoUrl'] != null &&
          customer['customerVideoUrl'].toString().isNotEmpty) {
        docs.add({
          'url': customer['customerVideoUrl'].toString(),
          'documentType': 'CUSTOMER_VIDEO',
        });
      }

      // 🔥 3. customerNidFront / NID Front
      if (customer['customerNidFront'] != null &&
          customer['customerNidFront'].toString().isNotEmpty) {
        docs.add({
          'url': customer['customerNidFront'].toString(),
          'documentType': 'NID_FRONT',
        });
      }

      // 🔥 4. customerNidBack / NID Back
      if (customer['customerNidBack'] != null &&
          customer['customerNidBack'].toString().isNotEmpty) {
        docs.add({
          'url': customer['customerNidBack'].toString(),
          'documentType': 'NID_BACK',
        });
      }

      // 🔥 5. incomeProofDocument / incomeProofUrl
      if (customer['incomeProofDocument'] != null &&
          customer['incomeProofDocument'].toString().isNotEmpty) {
        docs.add({
          'url': customer['incomeProofDocument'].toString(),
          'documentType': 'INCOME_PROOF',
        });
      }
      if (customer['incomeProofUrl'] != null &&
          customer['incomeProofUrl'].toString().isNotEmpty) {
        bool exists = docs.any(
          (d) => d['url'] == customer['incomeProofUrl'].toString(),
        );
        if (!exists) {
          docs.add({
            'url': customer['incomeProofUrl'].toString(),
            'documentType': 'INCOME_PROOF',
          });
        }
      }

      // 🔥 6. bankReceiptUrl / bankReceipt
      if (customer['bankReceiptUrl'] != null &&
          customer['bankReceiptUrl'].toString().isNotEmpty) {
        docs.add({
          'url': customer['bankReceiptUrl'].toString(),
          'documentType': 'BANK_RECEIPT',
        });
      }
      if (customer['bankReceipt'] != null &&
          customer['bankReceipt'].toString().isNotEmpty) {
        bool exists = docs.any(
          (d) => d['url'] == customer['bankReceipt'].toString(),
        );
        if (!exists) {
          docs.add({
            'url': customer['bankReceipt'].toString(),
            'documentType': 'BANK_RECEIPT',
          });
        }
      }

      // 🔥 7. MOST IMPORTANT: customer['documents'] থেকে ডকুমেন্ট নিন
      if (customer['documents'] != null && customer['documents'] is List) {
        debugPrint(
          '📄 [ViewModel] Found documents in customer: ${customer['documents']}',
        );
        for (var doc in customer['documents']) {
          String url = doc['url'] ?? doc['fileUrl'] ?? doc['path'] ?? '';
          String docType = doc['documentType'] ?? doc['type'] ?? 'DOCUMENT';
          if (url.isNotEmpty) {
            bool exists = docs.any((d) => d['url'] == url);
            if (!exists) {
              docs.add({'url': url, 'documentType': docType});
              debugPrint(
                '📄 [ViewModel] Added doc from customer.documents: $docType -> $url',
              );
            }
          }
        }
      }

      // 🔥 8. customerDocuments (যদি থাকে)
      if (customer['customerDocuments'] != null &&
          customer['customerDocuments'] is List) {
        for (var doc in customer['customerDocuments']) {
          String url = doc['url'] ?? doc['fileUrl'] ?? '';
          String docType = doc['documentType'] ?? doc['type'] ?? 'DOCUMENT';
          if (url.isNotEmpty) {
            bool exists = docs.any((d) => d['url'] == url);
            if (!exists) {
              docs.add({'url': url, 'documentType': docType});
            }
          }
        }
      }

      data['customerDocuments'] = docs;
      debugPrint(
        '📄 [ViewModel] Created customerDocuments: ${docs.length} items',
      );

      // ─── customer থেকে URL গুলো data তে যোগ করুন ───
      if (customer['customerImageUrl'] != null)
        data['customerImageUrl'] = customer['customerImageUrl'];
      if (customer['customerVideoUrl'] != null)
        data['customerVideoUrl'] = customer['customerVideoUrl'];
      if (customer['customerNidFront'] != null)
        data['customerNidFront'] = customer['customerNidFront'];
      if (customer['customerNidBack'] != null)
        data['customerNidBack'] = customer['customerNidBack'];
      if (customer['incomeProofUrl'] != null)
        data['incomeProofUrl'] = customer['incomeProofUrl'];
      if (customer['bankReceiptUrl'] != null)
        data['bankReceiptUrl'] = customer['bankReceiptUrl'];

      // customer info
      if (customer['name'] != null) data['name'] = customer['name'];
      if (customer['phone'] != null) data['phone'] = customer['phone'];
      if (customer['nidPassportNumber'] != null)
        data['nidPassportNumber'] = customer['nidPassportNumber'];
      if (customer['sourceOfIncome'] != null)
        data['sourceOfIncome'] = customer['sourceOfIncome'];
      if (customer['monthlyIncome'] != null)
        data['monthlyIncome'] = customer['monthlyIncome'];
      if (customer['presentAddress'] != null)
        data['presentAddress'] = customer['presentAddress'];
      if (customer['permanentAddress'] != null)
        data['permanentAddress'] = customer['permanentAddress'];

      // 🔥 MOST IMPORTANT: Guarantor Documents
      List<Map<String, dynamic>> guarantorDocs = [];

      // customer['guarantors'] থেকে ডকুমেন্ট নিন
      if (customer['guarantors'] != null && customer['guarantors'] is List) {
        debugPrint(
          '📄 [ViewModel] Found guarantors in customer: ${customer['guarantors']}',
        );
        for (int i = 0; i < customer['guarantors'].length; i++) {
          final g = customer['guarantors'][i];

          // Guarantor এর নিজস্ব ডকুমেন্ট
          if (g['nidFront'] != null && g['nidFront'].toString().isNotEmpty) {
            guarantorDocs.add({
              'url': g['nidFront'].toString(),
              'documentType': 'NID_FRONT',
              'guarantorIndex': i,
            });
            debugPrint('📄 [ViewModel] Added guarantor $i NID FRONT');
          }

          if (g['nidBack'] != null && g['nidBack'].toString().isNotEmpty) {
            guarantorDocs.add({
              'url': g['nidBack'].toString(),
              'documentType': 'NID_BACK',
              'guarantorIndex': i,
            });
            debugPrint('📄 [ViewModel] Added guarantor $i NID BACK');
          }

          // Guarantor এর documents ফিল্ড (যদি থাকে)
          if (g['documents'] != null && g['documents'] is List) {
            for (var doc in g['documents']) {
              String url = doc['url'] ?? doc['fileUrl'] ?? '';
              String docType = doc['documentType'] ?? doc['type'] ?? 'DOCUMENT';
              if (url.isNotEmpty) {
                bool exists = guarantorDocs.any((d) => d['url'] == url);
                if (!exists) {
                  guarantorDocs.add({
                    'url': url,
                    'documentType': docType,
                    'guarantorIndex': i,
                  });
                  debugPrint('📄 [ViewModel] Added guarantor $i doc: $docType');
                }
              }
            }
          }
        }
      }

      // data['guarantors'] থেকেও ডকুমেন্ট নিন (যদি customer এর ভিতরে না থাকে)
      if (data['guarantors'] != null && data['guarantors'] is List) {
        for (int i = 0; i < data['guarantors'].length; i++) {
          final g = data['guarantors'][i];

          if (g['nidFront'] != null && g['nidFront'].toString().isNotEmpty) {
            bool exists = guarantorDocs.any(
              (d) =>
                  d['url'] == g['nidFront'].toString() &&
                  d['guarantorIndex'] == i,
            );
            if (!exists) {
              guarantorDocs.add({
                'url': g['nidFront'].toString(),
                'documentType': 'NID_FRONT',
                'guarantorIndex': i,
              });
            }
          }

          if (g['nidBack'] != null && g['nidBack'].toString().isNotEmpty) {
            bool exists = guarantorDocs.any(
              (d) =>
                  d['url'] == g['nidBack'].toString() &&
                  d['guarantorIndex'] == i,
            );
            if (!exists) {
              guarantorDocs.add({
                'url': g['nidBack'].toString(),
                'documentType': 'NID_BACK',
                'guarantorIndex': i,
              });
            }
          }
        }
      }

      data['guarantorDocuments'] = guarantorDocs;
      debugPrint(
        '📄 [ViewModel] Created guarantorDocuments: ${guarantorDocs.length} items',
      );
    } else {
      // ─── customer অবজেক্ট না থাকলে সরাসরি data থেকে নিন ───
      // ... আগের কোড ...
    }

    return data;
  }

  // ─── Approve Application ───
  Future<bool> approveApplication(String id, String remarks) async {
    debugPrint('✅ [ViewModel] Approving application: $id');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = ApiEndPoint.approveLoanApplication(id);
      debugPrint('🌐 [ViewModel] Approve URL: $url');

      final body = {
        'approvalRemarks': remarks.isNotEmpty ? remarks : 'Approved by system',
      };

      debugPrint('📤 [ViewModel] Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('📊 [ViewModel] Approve Status: ${response.statusCode}');
      debugPrint('📄 [ViewModel] Approve Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            data['message'] ?? data['error']?['message'] ?? "Approval failed";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Reject Application ───
  Future<bool> rejectApplication(
    String id,
    String reason,
    String remarks,
  ) async {
    debugPrint('❌ [ViewModel] Rejecting application: $id');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = 'Authentication required';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final url = ApiEndPoint.rejectLoanApplication(id);
      debugPrint('🌐 [ViewModel] Reject URL: $url');

      final body = {'rejectionReason': reason};

      if (remarks.isNotEmpty) {
        body['approvalRemarks'] = remarks;
      }

      debugPrint('📤 [ViewModel] Request Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      debugPrint('📊 [ViewModel] Reject Status: ${response.statusCode}');
      debugPrint('📄 [ViewModel] Reject Response: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            data['message'] ?? data['error']?['message'] ?? "Rejection failed";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearData() {
    _applicationDetails = null;
    _errorMessage = null;
    _isLoading = false;
    _rawData = null;
    notifyListeners();
  }
}
