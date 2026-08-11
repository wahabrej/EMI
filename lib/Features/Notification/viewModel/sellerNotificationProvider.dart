import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constant/Api_End_point.dart';
import '../../../core/constant/Token_storage.dart';
import '../model/sellerNotificationModel.dart';

class SellerNotificationProvider extends ChangeNotifier {
  final AppStorage _tokenStorage = AppStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SellerNotificationModel? _notificationData;
  SellerNotificationModel? get notificationData => _notificationData;

  List<Items> get notifications => _notificationData?.data?.items ?? [];
  int get unreadCount => _notificationData?.data?.unreadCount ?? 0;

  // 🔹 Fetch Notifications
  Future<void> fetchNotifications({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _tokenStorage.getToken();
      final url = '${ApiEndPoint.sellerNotifications}?page=$page&limit=$limit';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _notificationData = SellerNotificationModel.fromJson(data);
      } else {
        _errorMessage = 'Failed to load notifications (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}