import '../models/device.dart';

/// Mock data service for IoT devices
/// Provides dummy data for development and testing
/// Structure is prepared for easy replacement with real REST API

class MockDataService {
  // Singleton pattern for easy access
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();
  
  /// Get all monitored devices
  /// In future: Replace with HTTP GET request to IoT API
  List<Device> getDevices() {
    return [
      Device(
        id: 'device_001',
        name: 'Sarang 1',
        temperature: 32.5,
        humidity: 75.2,
        weight: 12.8,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Device(
        id: 'device_002',
        name: 'Sarang 2',
        temperature: 31.8,
        humidity: 78.5,
        weight: 15.3,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      Device(
        id: 'device_003',
        name: 'Sarang 3',
        temperature: 55.1,
        humidity: 10.8,
        weight: 50.5,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
    ];
  }
  
  /// Get a single device by ID
  /// In future: Replace with HTTP GET request to IoT API
  Device? getDeviceById(String id) {
    final devices = getDevices();
    try {
      return devices.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Get historical data for statistics charts
  /// In future: Replace with HTTP GET request to IoT API
  DeviceHistory getDeviceHistory(String deviceId) {
    final now = DateTime.now();
    
    // Generate mock historical data for the past 7 days
    List<SensorDataPoint> generateHistory(
      double baseValue,
      double variance,
    ) {
      return List.generate(7, (index) {
        final dayOffset = 6 - index;
        // Add some variation to make it look realistic
        final variation = (index % 3 - 1) * variance;
        return SensorDataPoint(
          timestamp: now.subtract(Duration(days: dayOffset)),
          value: baseValue + variation,
        );
      });
    }
    
    // Different base values for each device
    double tempBase, humBase, weightBase;
    switch (deviceId) {
      case 'device_001':
        tempBase = 32.0;
        humBase = 75.0;
        weightBase = 12.5;
        break;
      case 'device_002':
        tempBase = 31.5;
        humBase = 78.0;
        weightBase = 15.0;
        break;
      case 'device_003':
      default:
        tempBase = 33.0;
        humBase = 73.0;
        weightBase = 10.0;
    }
    
    return DeviceHistory(
      deviceId: deviceId,
      temperatureHistory: generateHistory(tempBase, 1.5),
      humidityHistory: generateHistory(humBase, 3.0),
      weightHistory: generateHistory(weightBase, 0.8),
    );
  }
  
  /// Get aggregated history across all devices for statistics page
  DeviceHistory getAggregatedHistory() {
    final now = DateTime.now();
    
    // Generate averaged data points
    return DeviceHistory(
      deviceId: 'all',
      temperatureHistory: List.generate(7, (index) {
        final dayOffset = 6 - index;
        return SensorDataPoint(
          timestamp: now.subtract(Duration(days: dayOffset)),
          value: 32.0 + (index % 3 - 1) * 1.2,
        );
      }),
      humidityHistory: List.generate(7, (index) {
        final dayOffset = 6 - index;
        return SensorDataPoint(
          timestamp: now.subtract(Duration(days: dayOffset)),
          value: 75.0 + (index % 3 - 1) * 2.5,
        );
      }),
      weightHistory: List.generate(7, (index) {
        final dayOffset = 6 - index;
        return SensorDataPoint(
          timestamp: now.subtract(Duration(days: dayOffset)),
          value: 12.5 + (index * 0.3),
        );
      }),
    );
  }
}
