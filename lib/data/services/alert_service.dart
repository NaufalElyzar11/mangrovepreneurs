import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';
import 'notification_service.dart';

class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  // Threshold constants
  static const double weightHarvestKg = 10.0;
  static const double tempMaxC = 40.0;
  static const double tempMinC = 25.0;
  static const double batteryMinV = 3.5;

  static const String _prefsKey = 'sent_alerts';

  // In-memory set, synced with SharedPreferences
  Set<String> _sentAlerts = {};
  bool _loaded = false;

  Future<void> _load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _sentAlerts = prefs.getStringList(_prefsKey)?.toSet() ?? {};
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _sentAlerts.toList());
  }

  Future<void> checkAndNotify(Device device) async {
    await _load();
    await Future.wait([
      _checkWeight(device),
      _checkTemperature(device),
      _checkBattery(device),
    ]);
  }

  Future<void> _checkWeight(Device device) async {
    final key = '${device.id}_harvest';
    if (device.weight >= weightHarvestKg && !_sentAlerts.contains(key)) {
      _sentAlerts.add(key);
      await _save();
      await NotificationService().showAlert(
        id: _notifId(device.id, 'harvest'),
        title: '🍯 ${device.name} – Siap Panen!',
        body:
            'Berat sarang ${device.weight.toStringAsFixed(1)} kg sudah mencapai batas panen!',
      );
    } else if (device.weight < weightHarvestKg && _sentAlerts.contains(key)) {
      _sentAlerts.remove(key);
      await _save();
    }
  }

  Future<void> _checkTemperature(Device device) async {
    final hotKey = '${device.id}_temp_hot';
    final coldKey = '${device.id}_temp_cold';

    if (device.temperature > tempMaxC && !_sentAlerts.contains(hotKey)) {
      _sentAlerts.add(hotKey);
      _sentAlerts.remove(coldKey);
      await _save();
      await NotificationService().showAlert(
        id: _notifId(device.id, 'temp_hot'),
        title: '🌡 ${device.name} – Suhu Terlalu Panas',
        body:
            'Suhu ${device.temperature.toStringAsFixed(1)}°C melebihi batas atas ${tempMaxC.toInt()}°C.',
      );
    } else if (device.temperature < tempMinC &&
        !_sentAlerts.contains(coldKey)) {
      _sentAlerts.add(coldKey);
      _sentAlerts.remove(hotKey);
      await _save();
      await NotificationService().showAlert(
        id: _notifId(device.id, 'temp_cold'),
        title: '🌡 ${device.name} – Suhu Terlalu Dingin',
        body:
            'Suhu ${device.temperature.toStringAsFixed(1)}°C di bawah batas bawah ${tempMinC.toInt()}°C.',
      );
    } else if (device.temperature >= tempMinC &&
        device.temperature <= tempMaxC) {
      _sentAlerts.remove(hotKey);
      _sentAlerts.remove(coldKey);
      await _save();
    }
  }

  Future<void> _checkBattery(Device device) async {
    final key = '${device.id}_battery';
    if (device.batteryVoltage > 0 &&
        device.batteryVoltage < batteryMinV &&
        !_sentAlerts.contains(key)) {
      _sentAlerts.add(key);
      await _save();
      await NotificationService().showAlert(
        id: _notifId(device.id, 'battery'),
        title: '🔋 ${device.name} – Baterai Lemah',
        body:
            'Tegangan ${device.batteryVoltage.toStringAsFixed(2)}V. Segera isi daya!',
      );
    } else if (device.batteryVoltage >= batteryMinV &&
        _sentAlerts.contains(key)) {
      _sentAlerts.remove(key);
      await _save();
    }
  }

  /// Used by background service (static, isolate-safe)
  static Future<void> checkAndNotifyStatic(Device device) async {
    final prefs = await SharedPreferences.getInstance();
    final sent = prefs.getStringList(_prefsKey)?.toSet() ?? {};

    Future<void> fire(String key, int id, String title, String body) async {
      if (!sent.contains(key)) {
        sent.add(key);
        await prefs.setStringList(_prefsKey, sent.toList());
        await NotificationService.showNotification(
            id: id, title: title, body: body);
      }
    }

    Future<void> reset(String key) async {
      if (sent.contains(key)) {
        sent.remove(key);
        await prefs.setStringList(_prefsKey, sent.toList());
      }
    }

    // Weight
    if (device.weight >= weightHarvestKg) {
      await fire(
        '${device.id}_harvest',
        _notifIdStatic(device.id, 'harvest'),
        '🍯 ${device.name} – Siap Panen!',
        'Berat ${device.weight.toStringAsFixed(1)} kg sudah mencapai batas panen!',
      );
    } else {
      await reset('${device.id}_harvest');
    }

    // Temperature hot
    if (device.temperature > tempMaxC) {
      await fire(
        '${device.id}_temp_hot',
        _notifIdStatic(device.id, 'temp_hot'),
        '🌡 ${device.name} – Suhu Terlalu Panas',
        'Suhu ${device.temperature.toStringAsFixed(1)}°C melebihi ${tempMaxC.toInt()}°C.',
      );
      await reset('${device.id}_temp_cold');
    } else if (device.temperature < tempMinC) {
      await fire(
        '${device.id}_temp_cold',
        _notifIdStatic(device.id, 'temp_cold'),
        '🌡 ${device.name} – Suhu Terlalu Dingin',
        'Suhu ${device.temperature.toStringAsFixed(1)}°C di bawah ${tempMinC.toInt()}°C.',
      );
      await reset('${device.id}_temp_hot');
    } else {
      await reset('${device.id}_temp_hot');
      await reset('${device.id}_temp_cold');
    }

    // Battery
    if (device.batteryVoltage > 0 && device.batteryVoltage < batteryMinV) {
      await fire(
        '${device.id}_battery',
        _notifIdStatic(device.id, 'battery'),
        '🔋 ${device.name} – Baterai Lemah',
        'Tegangan ${device.batteryVoltage.toStringAsFixed(2)}V. Segera isi daya!',
      );
    } else if (device.batteryVoltage >= batteryMinV) {
      await reset('${device.id}_battery');
    }
  }

  int _notifId(String deviceId, String alertType) =>
      '${deviceId}_$alertType'.hashCode.abs() % 100000;

  static int _notifIdStatic(String deviceId, String alertType) =>
      '${deviceId}_$alertType'.hashCode.abs() % 100000;

  void resetAlerts() {
    _sentAlerts.clear();
    SharedPreferences.getInstance()
        .then((p) => p.remove(_prefsKey));
  }
}
