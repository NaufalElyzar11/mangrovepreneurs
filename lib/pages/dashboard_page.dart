import 'package:flutter/material.dart';
import '../data/models/device.dart';
// import '../data/services/mock_data_service.dart'; // Deprecated
import '../data/services/firebase_service.dart';
import '../widgets/device_card.dart';
import 'device_detail_page.dart';

/// Dashboard Page - Main screen showing all IoT devices
/// Displays 3 device cards with summary sensor data from Firebase Realtime Database
/// Tapping a card navigates to the Device Detail page

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Service instance
    final firebaseService = FirebaseService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mangrovepreneurs'),
        actions: [
          // Hidden debug button to seed data if needed
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Sync Test Data',
            onPressed: () {
              // Shows a snackbar feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing test data to Firebase...')),
              );
              firebaseService.seedInitialData();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Device>>(
        stream: firebaseService.getDevicesStream(),
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Error State
          if (snapshot.hasError) {
             return Center(
               child: Text('Error loading data: ${snapshot.error}'),
             );
          }

          final devices = snapshot.data ?? [];

          // Empty State
          if (devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.devices_other, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No devices connected',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => firebaseService.seedInitialData(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Demo Devices'),
                  ),
                ],
              ),
            );
          }

          // Data Content
          return RefreshIndicator(
            onRefresh: () async {
              // Valid update simulation
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Header section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Your Hives',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${devices.length} devices active',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Device cards
                ...devices.map((device) => DeviceCard(
                  device: device,
                  onTap: () => _navigateToDetail(context, device),
                )),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _navigateToDetail(BuildContext context, Device device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceDetailPage(device: device),
      ),
    );
  }
}
