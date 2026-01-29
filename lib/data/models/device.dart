/// Device model representing an IoT monitoring device
/// Each device has sensors for temperature, humidity, and weight
/// This model is structured for future REST API integration
library;

class Device {
  final String id;
  final String name;
  final double temperature; // in Celsius
  final double humidity; // in percentage
  final double weight; // in kilograms
  final DateTime lastUpdated;
  
  const Device({
    required this.id,
    required this.name,
    required this.temperature,
    required this.humidity,
    required this.weight,
    required this.lastUpdated,
  });
  
  /// Factory constructor for creating a Device from JSON
  /// Ready for future API integration
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String,
      name: json['name'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
  
  /// Convert device to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'temperature': temperature,
      'humidity': humidity,
      'weight': weight,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  /// Create a copy of device with updated values
  Device copyWith({
    String? id,
    String? name,
    double? temperature,
    double? humidity,
    double? weight,
    DateTime? lastUpdated,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      weight: weight ?? this.weight,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Historical sensor data point for charts
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

/// Historical data for a device containing multiple sensor readings
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
