import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'mangrove_alerts';
  static const String _channelName = 'Mangrove Sensor Alerts';
  static const String _channelDesc =
      'Notifikasi peringatan sensor sarang kelulut';

  bool _pluginInitialized = false;
  bool _permissionGranted = false;

  Future<void> init() async {
    if (_pluginInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );
    _pluginInitialized = true;

    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Create high-importance notification channel
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Request permission — required on Android 13+
    // Fix: separate permission state from plugin init state
    final granted = await androidImpl?.requestNotificationsPermission();
    _permissionGranted = granted ?? true; // null = older Android (always allowed)
  }

  Future<bool> get isPermissionGranted async {
    if (!_pluginInitialized) await init();
    return _permissionGranted;
  }

  /// Show an OS-level notification. Safe to call from background isolate.
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final plugin = FlutterLocalNotificationsPlugin();
    // Re-initialise if called from a fresh isolate (background service)
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );
    await plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/launcher_icon',
        ),
      ),
    );
  }

  /// Instance-based wrapper (used from UI isolate via DashboardPage).
  Future<void> showAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_pluginInitialized) await init();
    if (!_permissionGranted) {
      // Re-request if still not granted
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImpl?.requestNotificationsPermission();
      _permissionGranted = granted ?? true; // null = older Android (always allowed)
      if (!_permissionGranted) return;
    }

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/launcher_icon',
        ),
      ),
    );
  }
}
