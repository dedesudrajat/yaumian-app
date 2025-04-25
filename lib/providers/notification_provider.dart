import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yaumian_app/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  static const String _notificationBoxName = 'notification_box';
  static const String _isNotificationEnabledKey = 'is_notification_enabled';

  late Box<dynamic> _notificationBox;
  bool _isNotificationEnabled = true;

  NotificationProvider() {
    _loadNotificationPreference();
  }

  bool get isNotificationEnabled => _isNotificationEnabled;

  Future<void> _loadNotificationPreference() async {
    if (!Hive.isBoxOpen(_notificationBoxName)) {
      _notificationBox = await Hive.openBox(_notificationBoxName);
    } else {
      _notificationBox = Hive.box(_notificationBoxName);
    }

    _isNotificationEnabled = _notificationBox.get(
      _isNotificationEnabledKey,
      defaultValue: true,
    );
    notifyListeners();
  }

  Future<void> toggleNotification() async {
    _isNotificationEnabled = !_isNotificationEnabled;
    await _notificationBox.put(
      _isNotificationEnabledKey,
      _isNotificationEnabled,
    );

    if (_isNotificationEnabled) {
      // Aktifkan kembali notifikasi
      // Tidak perlu melakukan apa-apa karena notifikasi akan dijadwalkan saat amalan dibuat/diperbarui
    } else {
      // Nonaktifkan semua notifikasi
      await NotificationService.cancelAllNotifications();
    }

    notifyListeners();
  }

  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_notificationBoxName)) {
      await Hive.openBox(_notificationBoxName);
    }
  }
}
