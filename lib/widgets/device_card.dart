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

  double get _batteryPercent {
    const minV = 3.3;
    const maxV = 4.2;
    final pct = ((device.batteryVoltage - minV) / (maxV - minV)).clamp(0.0, 1.0);
    return pct;
  }

  Color get _batteryColor {
    if (_batteryPercent > 0.5) return MangroveTheme.success;
    if (_batteryPercent > 0.2) return MangroveTheme.warning;
    return MangroveTheme.error;
  }

  IconData get _batteryIcon {
    if (_batteryPercent > 0.75) return Icons.battery_full;
    if (_batteryPercent > 0.5) return Icons.battery_5_bar;
    if (_batteryPercent > 0.25) return Icons.battery_3_bar;
    if (_batteryPercent > 0.1) return Icons.battery_1_bar;
    return Icons.battery_alert;
  }

  @override
  Widget build(BuildContext context) {
    final batteryPct = (_batteryPercent * 100).toStringAsFixed(0);
    final voltageStr = device.batteryVoltage.toStringAsFixed(2);

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
                  Row(
                    children: [
                      _buildBatteryBadge(context, batteryPct, voltageStr),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: MangroveTheme.textHint,
                      ),
                    ],
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

  Widget _buildBatteryBadge(BuildContext context, String pct, String voltage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _batteryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _batteryColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_batteryIcon, color: _batteryColor, size: 16),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _batteryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${voltage}V',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _batteryColor.withValues(alpha: 0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
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
