import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:audioplayers/audioplayers.dart'; // <--- ĐÃ THÊM THƯ VIỆN ÂM THANH

// Model mô tả cấu trúc của 1 thông báo
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        timestamp: DateTime.parse(json['timestamp']),
        isRead: json['isRead'],
      );
}

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];

  // 🔴 THÊM: Biến điều khiển âm thanh
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _loadNotifications();
    _setupForegroundListener();
  }

  // 🔴 BẮT THÔNG BÁO VÀ PHÁT ÂM THANH NGAY CẢ KHI ĐANG MỞ APP
  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        // 1. KÍCH HOẠT PHÁT ÂM THANH CẢNH BÁO
        _playAlertSound();

        // 2. LƯU THÔNG BÁO VÀO DANH SÁCH
        addNotification(
          message.notification!.title ?? 'Cảnh báo hệ thống',
          message.notification!.body ?? 'Bạn có một cảnh báo mới',
        );
      }
    });
  }

  // 🔴 THÊM: Hàm phát âm thanh
  Future<void> _playAlertSound() async {
    try {
      // Gọi file âm thanh alert.mp3 từ thư mục assets/sounds/
      await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
    } catch (e) {
      debugPrint('Lỗi phát âm thanh: $e');
    }
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('saved_notifications');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _notifications = jsonList
          .map((e) => AppNotification.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(
      _notifications.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('saved_notifications', data);
  }

  void addNotification(String title, String body) {
    final newNotif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, newNotif); // Thêm lên đầu danh sách
    _saveNotifications();
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      _saveNotifications();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _saveNotifications();
    notifyListeners();
  }
}
