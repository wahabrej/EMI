import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';

class AuthScreenProvider extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 🔹 Login Method
  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await http.post(
        Uri.parse(ApiEndPoint.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 🔑 Dynamic Token Extraction
        final token = data['token'] ?? data['data']?['token'] ?? data['accessToken'];

        // 👤 User details extraction from API Response
        final userObj = data['data']?['user'];

        // 🆔 Dynamic User ID Extraction
        final userId = data['id'] ??
            data['userId'] ??
            data['data']?['id'] ??
            data['data']?['userId'] ??
            userObj?['id'];

        // 📧 Dynamic Email Extraction
        final userEmail = userObj?['email'] ?? data['email'] ?? data['data']?['email'];

        // 🏷️ Dynamic Name Extraction
        final userName = userObj?['name'] ?? data['name'] ?? data['data']?['name'];

        if (token != null) {
          // 💾 Save Token
          await _tokenStorage.saveToken(token.toString());

          // 💾 Save User ID
          if (userId != null) {
            await _tokenStorage.saveUserId(userId.toString());
          }

          // 💾 Save User Email
          if (userEmail != null) {
            await _tokenStorage.saveUserEmail(userEmail.toString());
          }

          // 💾 Save User Name
          if (userName != null) {
            await _tokenStorage.saveUserName(userName.toString());
          }

          _setLoading(false);
          return true;
        } else {
          _errorMessage = "Token not found in response body.";
        }
      } else {
        _errorMessage = data['message'] ?? "Login failed. Status: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Network error: ${e.toString()}";
    }

    _setLoading(false);
    return false;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}