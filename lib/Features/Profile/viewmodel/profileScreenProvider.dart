import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../model/ProfileModel.dart';

class ProfileProvider extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileData? _profileData;
  ProfileData? get profileData => _profileData;

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

      debugPrint("🌐 [Profile] Fetching: ${ApiEndPoint.currentUser}");

      final response = await http.get(
        Uri.parse(ApiEndPoint.currentUser),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("📥 [Profile] Status: ${response.statusCode}");
      debugPrint("📄 [Profile] Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          _profileData = ProfileData.fromJson(jsonData['data']);
          debugPrint("✅ [Profile] Name: ${_profileData?.name}");
          debugPrint("✅ [Profile] Email: ${_profileData?.email}");
          debugPrint("✅ [Profile] Roles: ${_profileData?.roles?.length}");
        } else {
          _errorMessage = jsonData['message'] ?? "Failed to load profile.";
        }
      } else {
        _errorMessage = "Server error: ${response.statusCode}";
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