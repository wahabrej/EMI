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

  // 📌 Raw data store for documents
  Map<String, dynamic>? _rawData;
  Map<String, dynamic>? get rawData => _rawData;

  Future<void> fetchCustomerDetail(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _customerDetail = null;
    _rawData = null;
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
      debugPrint("📦 [CustomerDetailVM] Response: ${response.statusCode}");

      if (response.statusCode == 200 && data['success'] == true) {
        // 📌 Store raw data
        _rawData = data['data'] as Map<String, dynamic>?;

        // 📌 Parse customer data
        _customerDetail = CustomerData.fromJson(data['data']);

        // 📌 IMPORTANT: Map documents from raw data to customer
        _mapDocumentsToCustomer(_customerDetail!, _rawData);

        debugPrint("✅ [CustomerDetailVM] Loaded Successfully");
        debugPrint("📄 [CustomerDetailVM] NID Front: ${_customerDetail?.nidFront}");
        debugPrint("📄 [CustomerDetailVM] NID Back: ${_customerDetail?.nidBack}");
        debugPrint("📄 [CustomerDetailVM] Income Proof: ${_customerDetail?.incomeProof}");
        debugPrint("📄 [CustomerDetailVM] Profile Image: ${_customerDetail?.profileImage}");
        debugPrint("📄 [CustomerDetailVM] Customer Video: ${_customerDetail?.customerVideo}");

        // 📌 Debug guarantor documents
        if (_customerDetail?.guarantors != null) {
          for (var g in _customerDetail!.guarantors!) {
            debugPrint("📄 [CustomerDetailVM] Guarantor: ${g.name}, NID Front: ${g.nidFront}, Video: ${g.guarantorVideo}");
          }
        }

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

  // 📌 Map documents from raw data to customer model (ভিডিও সহ)
  void _mapDocumentsToCustomer(CustomerData customer, Map<String, dynamic>? rawData) {
    if (rawData == null) return;

    debugPrint("🔄 [CustomerDetailVM] Mapping documents...");

    // ─── Customer Documents ───
    // Check if documents exist in raw data
    if (rawData['documents'] != null && rawData['documents'] is List) {
      List docs = rawData['documents'];
      for (var doc in docs) {
        String docType = doc['documentType']?.toString()?.toUpperCase() ?? '';
        String url = doc['url']?.toString() ?? '';

        if (url.isEmpty) continue;

        if (docType.contains('NID_FRONT') || docType.contains('NIDFRONT')) {
          customer.nidFront = url;
          debugPrint("📄 [CustomerDetailVM] Mapped NID Front: $url");
        } else if (docType.contains('NID_BACK') || docType.contains('NIDBACK')) {
          customer.nidBack = url;
          debugPrint("📄 [CustomerDetailVM] Mapped NID Back: $url");
        } else if (docType.contains('INCOME') || docType.contains('SALARY')) {
          customer.incomeProof = url;
          debugPrint("📄 [CustomerDetailVM] Mapped Income Proof: $url");
        } else if (docType.contains('PHOTO') || docType.contains('PROFILE')) {
          customer.profileImage = url;
          debugPrint("📄 [CustomerDetailVM] Mapped Profile Image: $url");
        } else if (docType.contains('VIDEO')) {
          customer.customerVideo = url;
          debugPrint("📄 [CustomerDetailVM] Mapped Customer Video: $url");
        }
      }
    }

    // ─── Direct fields from customer object ───
    if (rawData['customer'] != null && rawData['customer'] is Map<String, dynamic>) {
      Map<String, dynamic> customerData = rawData['customer'];

      if (customerData['customerNidFront'] != null && customerData['customerNidFront'].toString().isNotEmpty) {
        customer.nidFront = customerData['customerNidFront'].toString();
        debugPrint("📄 [CustomerDetailVM] Mapped customerNidFront: ${customer.nidFront}");
      }

      if (customerData['customerNidBack'] != null && customerData['customerNidBack'].toString().isNotEmpty) {
        customer.nidBack = customerData['customerNidBack'].toString();
        debugPrint("📄 [CustomerDetailVM] Mapped customerNidBack: ${customer.nidBack}");
      }

      if (customerData['customerImageUrl'] != null && customerData['customerImageUrl'].toString().isNotEmpty) {
        customer.profileImage = customerData['customerImageUrl'].toString();
        debugPrint("📄 [CustomerDetailVM] Mapped customerImageUrl: ${customer.profileImage}");
      }

      // 📌 ভিডিও URL ম্যাপিং
      if (customerData['customerVideoUrl'] != null && customerData['customerVideoUrl'].toString().isNotEmpty) {
        customer.customerVideo = customerData['customerVideoUrl'].toString();
        debugPrint("📄 [CustomerDetailVM] Mapped customerVideoUrl: ${customer.customerVideo}");
      }

      if (customerData['customerVideo'] != null && customerData['customerVideo'].toString().isNotEmpty) {
        customer.customerVideo = customerData['customerVideo'].toString();
        debugPrint("📄 [CustomerDetailVM] Mapped customerVideo: ${customer.customerVideo}");
      }

      if (customerData['incomeProofUrl'] != null && customerData['incomeProofUrl'].toString().isNotEmpty) {
        customer.incomeProof = customerData['incomeProofUrl'].toString();
        debugPrint("📄 [CustomerDetailVM] Mapped incomeProofUrl: ${customer.incomeProof}");
      }

      if (customerData['incomeProofDocument'] != null && customerData['incomeProofDocument'].toString().isNotEmpty) {
        customer.incomeProof = customerData['incomeProofDocument'].toString();
        debugPrint("📄 [CustomerDetailVM] Mapped incomeProofDocument: ${customer.incomeProof}");
      }
    }

    // ─── Guarantor Documents (ভিডিও সহ) ───
    if (customer.guarantors != null) {
      for (int i = 0; i < customer.guarantors!.length; i++) {
        Guarantor g = customer.guarantors![i];

        // Check from raw data guarantors
        if (rawData['guarantors'] != null && rawData['guarantors'] is List) {
          List guarantors = rawData['guarantors'];
          if (i < guarantors.length) {
            Map<String, dynamic> guarantorData = guarantors[i];

            // Direct fields
            if (guarantorData['nidFront'] != null && guarantorData['nidFront'].toString().isNotEmpty) {
              g.nidFront = guarantorData['nidFront'].toString();
              debugPrint("📄 [CustomerDetailVM] Guarantor $i NID Front: ${g.nidFront}");
            }

            if (guarantorData['nidBack'] != null && guarantorData['nidBack'].toString().isNotEmpty) {
              g.nidBack = guarantorData['nidBack'].toString();
              debugPrint("📄 [CustomerDetailVM] Guarantor $i NID Back: ${g.nidBack}");
            }

            // 📌 Guarantor Video
            if (guarantorData['guarantorVideoUrl'] != null && guarantorData['guarantorVideoUrl'].toString().isNotEmpty) {
              g.guarantorVideo = guarantorData['guarantorVideoUrl'].toString();
              debugPrint("📄 [CustomerDetailVM] Guarantor $i Video: ${g.guarantorVideo}");
            }

            if (guarantorData['guarantorVideo'] != null && guarantorData['guarantorVideo'].toString().isNotEmpty) {
              g.guarantorVideo = guarantorData['guarantorVideo'].toString();
              debugPrint("📄 [CustomerDetailVM] Guarantor $i Video: ${g.guarantorVideo}");
            }

            // Documents array
            if (guarantorData['documents'] != null && guarantorData['documents'] is List) {
              List docs = guarantorData['documents'];
              for (var doc in docs) {
                String docType = doc['documentType']?.toString()?.toUpperCase() ?? '';
                String url = doc['url']?.toString() ?? '';

                if (url.isEmpty) continue;

                if (docType.contains('NID_FRONT') || docType.contains('NIDFRONT')) {
                  g.nidFront = url;
                } else if (docType.contains('NID_BACK') || docType.contains('NIDBACK')) {
                  g.nidBack = url;
                } else if (docType.contains('VIDEO')) {
                  g.guarantorVideo = url;
                }
              }
            }
          }
        }

        // Check from customer's guarantors in raw data
        if (rawData['customer'] != null &&
            rawData['customer']['guarantors'] != null &&
            rawData['customer']['guarantors'] is List) {
          List guarantors = rawData['customer']['guarantors'];
          if (i < guarantors.length) {
            Map<String, dynamic> guarantorData = guarantors[i];

            if (guarantorData['nidFront'] != null && guarantorData['nidFront'].toString().isNotEmpty) {
              g.nidFront = guarantorData['nidFront'].toString();
            }

            if (guarantorData['nidBack'] != null && guarantorData['nidBack'].toString().isNotEmpty) {
              g.nidBack = guarantorData['nidBack'].toString();
            }

            // 📌 Guarantor Video from customer's guarantors
            if (guarantorData['guarantorVideoUrl'] != null && guarantorData['guarantorVideoUrl'].toString().isNotEmpty) {
              g.guarantorVideo = guarantorData['guarantorVideoUrl'].toString();
            }

            if (guarantorData['guarantorVideo'] != null && guarantorData['guarantorVideo'].toString().isNotEmpty) {
              g.guarantorVideo = guarantorData['guarantorVideo'].toString();
            }
          }
        }
      }
    }

    debugPrint("✅ [CustomerDetailVM] Document mapping complete");
  }
}