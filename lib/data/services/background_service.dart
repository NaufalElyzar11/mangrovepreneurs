import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart';
import '../models/device.dart';
import 'alert_service.dart';
import 'notification_service.dart';

class BackgroundServiceManager {
  static const int _serviceNotifId = 9999;
  static const String _serviceChannelId = 'mangrove_bg_service';
  static const String _serviceChannelName = 'Mangrove Monitor Service';

  /// Call once from main() to configure and start the background service.
  static Future<void> init() async {
    final service = FlutterBackgroundService();

    // Create a separate channel for the sticky foreground-service notification
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _serviceChannelId,
            _serviceChannelName,
            description: 'Monitor sensor berjalan di latar belakang',
            importance: Importance.low, // silent sticky notif
          ),
        );

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onBackgroundStart,
        isForegroundMode: true,
        autoStart: true,
        autoStartOnBoot: true,
        notificationChannelId: _serviceChannelId,
        initialNotificationTitle: '🌿 Mangrove Monitor',
        initialNotificationContent: 'Memantau sensor sarang kelulut...',
        foregroundServiceNotificationId: _serviceNotifId,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
      iosConfiguration: IosConfiguration(autoStart: false),
    );

    await service.startService();
  }
}

/// This function runs in a SEPARATE Dart isolate (background process).
/// It must be a top-level function.
@pragma('vm:entry-point')
Future<void> _onBackgroundStart(ServiceInstance service) async {
  // Init Firebase in the background isolate
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init notification channel so we can fire alerts from here
  await plugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    ),
  );
  await _ensureAlertChannel();

  // Listen on Firebase RTDB — event-driven, no polling
  final devicesRef = FirebaseDatabase.instance.ref().child('devices');

  devicesRef.onValue.listen((event) async {
    final data = event.snapshot.value;
    if (data == null) return;

    try {
      final map = data as Map<dynamic, dynamic>;
      for (final entry in map.entries) {
        final deviceMap = Map<String, dynamic>.from(entry.value as Map);
        // CRITICAL: Firebase node key IS the device ID — inject it so
        // Device.fromJson gets a real id (not the fallback 'unknown_id').
        deviceMap.putIfAbsent('id', () => entry.key.toString());
        final device = Device.fromJson(deviceMap);
        await AlertService.checkAndNotifyStatic(device);
      }
    } catch (e) {
      // Log errors — previously silent catch hid all failures
    }
  });

  // Keep the service alive — the Firebase stream above handles events.
  // We just need to not exit the isolate.
  service.on('stopService').listen((_) => service.stopSelf());
}

/// Lazy plugin instance shared within this isolate.
final FlutterLocalNotificationsPlugin plugin =
    FlutterLocalNotificationsPlugin();

Future<void> _ensureAlertChannel() async {
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          NotificationService.channelId,
          'Mangrove Sensor Alerts',
          description: 'Notifikasi peringatan sensor sarang kelulut',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
}
