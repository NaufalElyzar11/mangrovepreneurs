import 'package:flutter/material.dart';
import '../data/models/device.dart';
import '../data/services/mock_data_service.dart';
import '../widgets/device_card.dart';
import 'device_detail_page.dart';

/// Dashboard Page - Main screen showing all IoT devices
/// Displays 3 device cards with summary sensor data
/// Tapping a card navigates to the Device Detail page

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockService = MockDataService();
    final devices = mockService.getDevices();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mangrovepreneurs'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Placeholder for future API refresh
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
                '${devices.length} devices connected',
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
