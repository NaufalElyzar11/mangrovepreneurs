library;

class Device {
  final String id;
  final String name;
  final double temperature;
  final double humidity;
  final double weight;
  final double batteryVoltage;
  final DateTime lastUpdated;
  
  const Device({
    required this.id,
    required this.name,
    required this.temperature,
    required this.humidity,
    required this.weight,
    this.batteryVoltage = 0.0,
    required this.lastUpdated,
  });
  
  factory Device.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.now();
    }

    return Device(
      id: json['id']?.toString() ?? 'unknown_id',
      name: json['name']?.toString() ?? 'Unknown Device',
      temperature: parseDouble(json['temperature']),
      humidity: parseDouble(json['humidity']),
      weight: parseDouble(json['weight']).abs(),
      batteryVoltage: parseDouble(json['batteryVoltage']),
      lastUpdated: parseDate(json['lastUpdated']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'temperature': temperature,
      'humidity': humidity,
      'weight': weight,
      'batteryVoltage': batteryVoltage,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  Device copyWith({
    String? id,
    String? name,
    double? temperature,
    double? humidity,
    double? weight,
    double? batteryVoltage,
    DateTime? lastUpdated,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      weight: weight ?? this.weight,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class SensorDataPoint {
  final DateTime timestamp;
  final double value;
  
  const SensorDataPoint({
    required this.timestamp,
    required this.value,
  });
  
  factory SensorDataPoint.fromJson(Map<String, dynamic> json) {
    return SensorDataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
    };
  }
}

class DeviceHistory {
  final String deviceId;
  final List<SensorDataPoint> temperatureHistory;
  final List<SensorDataPoint> humidityHistory;
  final List<SensorDataPoint> weightHistory;
  
  const DeviceHistory({
    required this.deviceId,
    required this.temperatureHistory,
    required this.humidityHistory,
    required this.weightHistory,
  });
}
