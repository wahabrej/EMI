import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../../Parent/ViewModel/Parent_screen_provider.dart';
import '../../../CustomerFeature/parent/viewModel/customerParentViewModel.dart';
import '../../../core/routes/Routes_name.dart';

class AuthScreenProvider extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userRole;
  String? get userRole => _userRole;

  // 🔹 Login Method
  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _userRole = null;

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
        final userData = data['data']?['user'];
        final token = data['token'] ?? data['data']?['token'] ?? data['accessToken'];

        final userId = data['id'] ?? userData?['id'];
        final userEmail = userData?['email'] ?? data['email'];
        final userName = userData?['name'] ?? data['name'];

        // 🛡️ Extract and Save Role Name
        final roles = userData?['roles'] as List?;
        if (roles != null && roles.isNotEmpty) {
          _userRole = roles[0]['role']?['name']?.toString().toUpperCase();
          await _tokenStorage.saveUserRole(_userRole!);
          print("Saving Role: $_userRole");

        }

        if (token != null) {
          await _tokenStorage.saveToken(token.toString());
          if (userId != null) await _tokenStorage.saveUserId(userId.toString());
          if (userEmail != null) await _tokenStorage.saveUserEmail(userEmail.toString());
          if (userName != null) await _tokenStorage.saveUserName(userName.toString());

          _setLoading(false);
          return true;
        }
      } else {
        _errorMessage = data['message'] ?? "Login failed.";
      }
    } catch (e) {
      _errorMessage = "Network error.";
    }

    _setLoading(false);
    return false;
  }

  // 🔹 Logout Method: Resets indices and navigates directly to Login
  Future<void> logout(BuildContext context) async {
    await _tokenStorage.clearAll(); 
    
    if (context.mounted) {
      // 🔄 Reset Bottom Navigation Indices to 0 (Home) before logging out
      // This ensures the next login starts at Home, not Profile
      Provider.of<ParentScreenProvider>(context, listen: false).setIndex(0);
      try {
        Provider.of<CustomerParentViewModel>(context, listen: false).setIndex(0);
      } catch (e) {
        debugPrint("CustomerParentViewModel not initialized or skipped");
      }

      // 🚪 Navigate directly to Login Screen (Skipping Splash)
      Navigator.pushNamedAndRemoveUntil(context, RouteName.loginScreen, (route) => false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}