import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/device.dart';
import '../data/services/firebase_service.dart';
import '../data/services/alert_service.dart';
import '../widgets/device_card.dart';
import 'device_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final AlertService _alertService = AlertService();

  StreamSubscription<List<Device>>? _deviceSubscription;
  List<Device> _devices = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _deviceSubscription = _firebaseService.getDevicesStream().listen(
      (devices) {
        for (final device in devices) {
          _alertService.checkAndNotify(device);
        }
        if (mounted) {
          setState(() {
            _devices = devices;
            _loading = false;
            _error = null;
          });
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _error = err;
            _loading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _deviceSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mangrovepreneurs'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text('Error loading data: $_error'),
      );
    }

    if (_devices.isEmpty) {
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
              onPressed: () => _firebaseService.seedInitialData(),
              icon: const Icon(Icons.add),
              label: const Text('Add Demo Devices'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
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
              '${_devices.length} devices active',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ..._devices.map((device) => DeviceCard(
                device: device,
                onTap: () => _navigateToDetail(context, device),
              )),
          const SizedBox(height: 20),
        ],
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
