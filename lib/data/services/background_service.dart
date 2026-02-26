import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../firebase_options.dart';
import '../models/device.dart';

class BackgroundServiceManager {
  static const int _serviceNotifId = 9999;
  static const String _serviceChannelId = 'mangrove_bg_service';
  static const String _serviceChannelName = 'Mangrove Monitor Service';

  static Future<void> init() async {
    final service = FlutterBackgroundService();

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      ),
    );
    final androidImpl = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _serviceChannelId,
        _serviceChannelName,
        description: 'Monitor sensor berjalan di latar belakang',
        importance: Importance.low,
      ),
    );

    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'mangrove_alerts',
        'Mangrove Sensor Alerts',
        description: 'Notifikasi peringatan sensor sarang kelulut',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
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

/// MUST be a top-level, PUBLIC function.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Required for background isolate to access plugins
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // 1. Init notifications in this isolate
  final notifPlugin = FlutterLocalNotificationsPlugin();
  await notifPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    ),
  );

  // Ensure alert channel exists in this isolate
  await notifPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'mangrove_alerts',
          'Mangrove Sensor Alerts',
          description: 'Notifikasi peringatan sensor sarang kelulut',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );

  // 2. Init Firebase in this isolate
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Already initialized — ignore
  }

  // 3. Constants
  const double weightHarvestKg = 10.0;
  const double tempMaxC = 40.0;
  const double tempMinC = 25.0;
  const double batteryMinV = 3.5;
  const String prefsKey = 'sent_alerts_bg';

  // 4. Helper to fire notification
  Future<void> fireNotif(int id, String title, String body) async {
    await notifPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mangrove_alerts',
          'Mangrove Sensor Alerts',
          channelDescription: 'Notifikasi peringatan sensor sarang kelulut',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/launcher_icon',
        ),
      ),
    );
  }

  int notifId(String deviceId, String alertType) =>
      '${deviceId}_$alertType'.hashCode.abs() % 100000;

  // 5. Listen to Firebase RTDB
  final devicesRef = FirebaseDatabase.instance.ref().child('devices');

  devicesRef.onValue.listen((event) async {
    final data = event.snapshot.value;
    if (data == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final sent = prefs.getStringList(prefsKey)?.toSet() ?? {};

      final map = data as Map<dynamic, dynamic>;

      for (final entry in map.entries) {
        final key = entry.key.toString();
        final deviceMap = Map<String, dynamic>.from(entry.value as Map);
        deviceMap.putIfAbsent('id', () => key);
        final device = Device.fromJson(deviceMap);

        // Weight
        final harvestKey = '${device.id}_harvest';
        if (device.weight >= weightHarvestKg && !sent.contains(harvestKey)) {
          sent.add(harvestKey);
          await fireNotif(
            notifId(device.id, 'harvest'),
            '🍯 Siap Panen! — ${device.name}',
            'Berat sarang ${device.weight.toStringAsFixed(1)} kg sudah mencapai target panen.',
          );
        } else if (device.weight < weightHarvestKg) {
          sent.remove(harvestKey);
        }

        // Temperature high
        final hotKey = '${device.id}_temp_hot';
        if (device.temperature > tempMaxC && !sent.contains(hotKey)) {
          sent.add(hotKey);
          sent.remove('${device.id}_temp_cold');
          await fireNotif(
            notifId(device.id, 'temp_hot'),
            '🌡 Suhu Terlalu Panas — ${device.name}',
            'Suhu ${device.temperature.toStringAsFixed(1)}°C melebihi batas ${tempMaxC.toInt()}°C.',
          );
        }

        // Temperature low
        final coldKey = '${device.id}_temp_cold';
        if (device.temperature < tempMinC && !sent.contains(coldKey)) {
          sent.add(coldKey);
          sent.remove('${device.id}_temp_hot');
          await fireNotif(
            notifId(device.id, 'temp_cold'),
            '🌡 Suhu Terlalu Dingin — ${device.name}',
            'Suhu ${device.temperature.toStringAsFixed(1)}°C di bawah batas ${tempMinC.toInt()}°C.',
          );
        }

        // Normal range — clear temp alerts
        if (device.temperature >= tempMinC && device.temperature <= tempMaxC) {
          sent.remove('${device.id}_temp_hot');
          sent.remove('${device.id}_temp_cold');
        }

        // Battery
        final batKey = '${device.id}_battery';
        if (device.batteryVoltage > 0 &&
            device.batteryVoltage < batteryMinV &&
            !sent.contains(batKey)) {
          sent.add(batKey);
          await fireNotif(
            notifId(device.id, 'battery'),
            '🔋 Baterai Lemah — ${device.name}',
            'Tegangan ${device.batteryVoltage.toStringAsFixed(2)}V. Segera isi daya!',
          );
        } else if (device.batteryVoltage >= batteryMinV) {
          sent.remove(batKey);
        }
      }

      await prefs.setStringList(prefsKey, sent.toList());
    } catch (_) {}
  });

  // Keep alive
  service.on('stopService').listen((_) => service.stopSelf());
}
