import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../model/customer_profile_model.dart';

class CustomerProfileViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Data? _profileData;               // ← সরাসরি Data রাখছি
  Data? get profileData => _profileData;

  Future<void> fetchProfile() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final token = await _tokenStorage.getToken();
      if (token == null) {
        _errorMessage = "Authentication failed. Please login again.";
        _setLoading(false);
        return;
      }

      debugPrint("🌐 [Profile] Fetching: ${ApiEndPoint.customerProfile}");

      final response = await http.get(
        Uri.parse(ApiEndPoint.customerProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("📥 [Profile] Status: ${response.statusCode}");
      debugPrint("📄 [Profile] Body: ${response.body}");

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        // data অংশটা নিয়ে Data.fromJson করছি
        _profileData = Data.fromJson(jsonData['data']);
        debugPrint("✅ [Profile] Name: ${_profileData?.name}");
      } else {
        _errorMessage = jsonData['message'] ?? "Failed to load profile.";
      }
    } catch (e) {
      _errorMessage = "Connection error: $e";
      debugPrint("🚨 [Profile] Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}