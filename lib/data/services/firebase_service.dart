import 'package:firebase_database/firebase_database.dart';
import '../models/device.dart';

class FirebaseService {
  final DatabaseReference _devicesRef = FirebaseDatabase.instance.ref().child('devices');
  
  Stream<List<Device>> getDevicesStream() {
    return _devicesRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      
      try {
        final Map<dynamic, dynamic> map = data as Map<dynamic, dynamic>;
        final List<Device> devices = [];
        
        map.forEach((key, value) {
          final deviceMap = Map<String, dynamic>.from(value as Map);
          devices.add(Device.fromJson(deviceMap));
        });
        
        return devices;
      } catch (e) {
        print('Error parsing devices: $e');
        return [];
      }
    });
  }
  
  Future<void> saveDevice(Device device) async {
    await _devicesRef.child(device.id).set(device.toJson());
  }
  
  Future<void> seedInitialData() async {
    final now = DateTime.now();
    
    final devices = [
      Device(
        id: 'hive_001',
        name: 'Hive Monitor #1',
        temperature: 32.5,
        humidity: 65,
        weight: 4.2,
        lastUpdated: now,
      ),
      Device(
        id: 'hive_002',
        name: 'Hive Monitor #2',
        temperature: 31.8,
        humidity: 62,
        weight: 3.8,
        lastUpdated: now.subtract(const Duration(minutes: 5)),
      ),
      Device(
        id: 'hive_003',
        name: 'Hive Monitor #3',
        temperature: 33.1,
        humidity: 68,
        weight: 5.5,
        lastUpdated: now.subtract(const Duration(minutes: 15)),
      ),
    ];
    
    for (var device in devices) {
      await saveDevice(device);
    }
  }
}
