import 'package:flutter/material.dart';
import '../data/models/device.dart';
import '../core/theme/mangrove_theme.dart';

class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback? onTap;
  
  const DeviceCard({
    super.key,
    required this.device,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: MangroveTheme.primaryGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.hive_outlined,
                          color: MangroveTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Last updated: ${_formatTime(device.lastUpdated)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: MangroveTheme.textHint,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSensorValue(
                    context,
                    icon: Icons.thermostat_outlined,
                    label: 'Temperature',
                    value: '${device.temperature.toStringAsFixed(1)}°C',
                    color: MangroveTheme.warning,
                  ),
                  _buildSensorValue(
                    context,
                    icon: Icons.water_drop_outlined,
                    label: 'Humidity',
                    value: '${device.humidity.toStringAsFixed(1)}%',
                    color: MangroveTheme.primaryGreen,
                  ),
                  _buildSensorValue(
                    context,
                    icon: Icons.scale_outlined,
                    label: 'Weight',
                    value: '${device.weight.toStringAsFixed(1)} kg',
                    color: MangroveTheme.mutedBrown,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSensorValue(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
