import '../models/device.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();
  
  List<Device> getDevices() {
    return [
      Device(
        id: 'device_001',
        name: 'Sarang 1',
        temperature: 32.5,
        humidity: 75.2,
        weight: 12.8,
        batteryVoltage: 4.10,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Device(
        id: 'device_002',
        name: 'Sarang 2',
        temperature: 31.8,
        humidity: 78.5,
        weight: 15.3,
        batteryVoltage: 3.85,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      Device(
        id: 'device_003',
        name: 'Sarang 3',
        temperature: 55.1,
        humidity: 10.8,
        weight: 50.5,
        batteryVoltage: 3.45,
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
    ];
  }
  
  Device? getDeviceById(String id) {
    final devices = getDevices();
    try {
      return devices.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
  
  DeviceHistory getDeviceHistory(String deviceId) {
    final now = DateTime.now();
    
    List<SensorDataPoint> generateHistory(
      double baseValue,
      double variance,
    ) {
      return List.generate(7, (index) {
        final dayOffset = 6 - index;
        final variation = (index % 3 - 1) * variance;
        return SensorDataPoint(
          timestamp: now.subtract(Duration(days: dayOffset)),
          value: baseValue + variation,
        );
      });
    }
    
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
  
  DeviceHistory getAggregatedHistory() {
    final now = DateTime.now();
    
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
