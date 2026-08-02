import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../model/customer_notification_model.dart';

class CustomerNotificationViewModel extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<CustomerNotificationModel> _notifications = [];
  List<CustomerNotificationModel> get notifications => _notifications;

  Future<void> fetchNotifications() async {
    _setLoading(true);
    _errorMessage = null;
    debugPrint("🌐 [NotificationVM] Fetching Notifications...");

    try {
      final token = await _tokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiEndPoint.customerNotifications),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint("📥 [NotificationVM] Status Code: ${response.statusCode}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _notifications = (data['data'] as List)
            .map((e) => CustomerNotificationModel.fromJson(e))
            .toList();
        debugPrint("✅ [NotificationVM] Loaded ${_notifications.length} Notifications");
      } else {
        _errorMessage = data['message'] ?? "Failed to load notifications";
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("🚨 [NotificationVM] Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}