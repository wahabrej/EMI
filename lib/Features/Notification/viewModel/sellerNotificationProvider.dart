import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

  // সব নোটিফিকেশন
  List<Items> get allNotifications => _notificationData?.data?.items ?? [];

  // শুধু unread ফিল্টার
  List<Items> get unreadNotifications {
    return allNotifications.where((item) => item.read == false).toList();
  }

  // শুধু read ফিল্টার
  List<Items> get readNotifications {
    return allNotifications.where((item) => item.read == true).toList();
  }

  // ⭐ Unread Count - এইটা ব্যবহার করুন
  int get unreadCount {
    // প্রথমে API থেকে আসা unreadCount ব্যবহার করি
    if (_notificationData?.data?.unreadCount != null) {
      return _notificationData!.data!.unreadCount!;
    }
    // না হলে ফিল্টার করে কাউন্ট করি
    return unreadNotifications.length;
  }

  SharedPreferences? _prefs;

  SellerNotificationProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Fetch Notifications ──────────────────────────────────────────
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

        // Read status সিঙ্ক করুন
        await _syncReadStatus();

        notifyListeners();
      } else {
        _errorMessage = 'Failed to load notifications (${response.statusCode})';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Sync Read Status from Local Storage ─────────────────────────
  Future<void> _syncReadStatus() async {
    if (_prefs == null) await _initPrefs();

    final List<String> readIds = _prefs?.getStringList('read_notification_ids') ?? [];

    final allItems = _notificationData?.data?.items ?? [];
    for (var item in allItems) {
      if (item.id != null && readIds.contains(item.id)) {
        item.read = true;
      } else {
        item.read = false;
      }
    }

    // Unread count রিক্যালকুলেট করুন
    if (_notificationData?.data != null) {
      _notificationData!.data!.unreadCount = unreadNotifications.length;
    }
  }

  // ─── Mark Single Notification as Read ────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    try {
      // Local update
      final allItems = _notificationData?.data?.items ?? [];
      final index = allItems.indexWhere((item) => item.id == notificationId);

      if (index != -1) {
        allItems[index].read = true;
        await _saveReadId(notificationId);

        // Unread count আপডেট করুন
        if (_notificationData?.data != null) {
          _notificationData!.data!.unreadCount = unreadNotifications.length;
        }

        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to mark as read: $e';
      notifyListeners();
    }
  }

  // ─── Save Read ID to Local Storage ──────────────────────────────
  Future<void> _saveReadId(String notificationId) async {
    if (_prefs == null) await _initPrefs();

    List<String> readIds = _prefs?.getStringList('read_notification_ids') ?? [];
    if (!readIds.contains(notificationId)) {
      readIds.add(notificationId);
      await _prefs?.setStringList('read_notification_ids', readIds);
    }
  }

  // ─── Mark All as Read ────────────────────────────────────────────
  Future<void> markAllAsRead() async {
    try {
      final allItems = _notificationData?.data?.items ?? [];
      List<String> readIds = [];

      for (var item in allItems) {
        if (!(item.read ?? false)) {
          item.read = true;
          if (item.id != null) {
            readIds.add(item.id!);
          }
        }
      }

      if (_prefs == null) await _initPrefs();
      final existingIds = _prefs?.getStringList('read_notification_ids') ?? [];
      final updatedIds = {...existingIds, ...readIds}.toList();
      await _prefs?.setStringList('read_notification_ids', updatedIds);

      if (_notificationData?.data != null) {
        _notificationData!.data!.unreadCount = 0;
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to mark all as read: $e';
      notifyListeners();
    }
  }

  // ─── Get Unread Count (API Call ছাড়া) ──────────────────────────
  Future<int> getUnreadCount() async {
    // যদি ডেটা already লোড করা থাকে
    if (_notificationData != null) {
      return unreadCount;
    }

    // নাহলে API কল করুন
    await fetchNotifications(page: 1, limit: 1);
    return unreadCount;
  }

  // ─── Clear Local Data ────────────────────────────────────────────
  Future<void> clearLocalData() async {
    if (_prefs == null) await _initPrefs();
    await _prefs?.remove('read_notification_ids');
    _notificationData = null;
    notifyListeners();
  }

  // ─── Reset Provider ──────────────────────────────────────────────
  void resetProvider() {
    _isLoading = false;
    _errorMessage = null;
    _notificationData = null;
    notifyListeners();
  }
}