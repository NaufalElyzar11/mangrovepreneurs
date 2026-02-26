import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../data/models/device.dart';
import '../data/models/calibration_settings.dart';
import '../data/services/firebase_service.dart';
import '../core/theme/mangrove_theme.dart';
import 'settings_page.dart';
import 'statistics_page.dart';

class DeviceDetailPage extends StatefulWidget {
  final Device device;

  const DeviceDetailPage({
    super.key,
    required this.device,
  });

  @override
  State<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<List<Device>>? _subscription;
  late Device _device;

  @override
  void initState() {
    super.initState();
    _device = widget.device;
    // Subscribe to live Firebase updates and filter for this device's id
    _subscription = _firebaseService.getDevicesStream().listen((devices) {
      final updated = devices.where((d) => d.id == _device.id).firstOrNull;
      if (updated != null && mounted) {
        setState(() => _device = updated);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ──────────────────────── Battery helpers ────────────────────────
  double get _batteryPercent {
    const minV = 3.0;
    const maxV = 4.2;
    return ((_device.batteryVoltage - minV) / (maxV - minV)).clamp(0.0, 1.0);
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

  // ──────────────────────── Build ────────────────────────
  @override
  Widget build(BuildContext context) {
    final calibration = CalibrationService().getSettings(_device.id);
    final double weightPercentage =
        calibration.getHarvestProgress(_device.weight);
    final bool isReadyToHarvest =
        calibration.isReadyForHarvest(_device.weight);

    return Scaffold(
      backgroundColor: MangroveTheme.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildMetaInfo(context),
                    _buildWeightCard(context, weightPercentage,
                        calibration.harvestWeight, isReadyToHarvest),
                    _buildEnvironmentGrid(context, calibration),
                    _buildDeviceStatus(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: MangroveTheme.offWhite,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: MangroveTheme.textPrimary,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _device.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MangroveTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: MangroveTheme.success,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MangroveTheme.success.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: MangroveTheme.success.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatisticsPage(device: _device),
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart),
                color: MangroveTheme.primaryGreenDark,
                tooltip: 'Live Data',
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(device: _device),
                    ),
                  ).then((_) {
                    // Refresh view if settings were modified
                    if (mounted) setState(() {});
                  });
                },
                icon: const Icon(Icons.settings_outlined),
                color: MangroveTheme.textPrimary,
                tooltip: 'Device Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(
            'Last updated ${_formatTime(_device.lastUpdated)}',
            style: TextStyle(
              fontSize: 12,
              color: MangroveTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard(BuildContext context, double percentage,
      double target, bool isReadyToHarvest) {
    const String weightChange = '+0.1kg';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isReadyToHarvest
                ? MangroveTheme.primaryGreen.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.05),
            width: isReadyToHarvest ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.scale_outlined,
                      color: MangroveTheme.mutedBrown,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hive Weight',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: MangroveTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Load Cell Reading',
                          style: TextStyle(
                            fontSize: 13,
                            color: MangroveTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color:
                        MangroveTheme.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: 16,
                        color: MangroveTheme.primaryGreenDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        weightChange,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: MangroveTheme.primaryGreenDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: _CircularGaugePainter(
                  percentage: percentage,
                  progressColor: isReadyToHarvest
                      ? MangroveTheme.primaryGreen
                      : MangroveTheme.oliveGreen,
                  backgroundColor: MangroveTheme.lightGrey,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _device.weight.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: MangroveTheme.textPrimary,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        'kg',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: MangroveTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isReadyToHarvest)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MangroveTheme.primaryGreen.withValues(alpha: 0.15),
                      MangroveTheme.primaryGreen.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MangroveTheme.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: MangroveTheme.primaryGreenDark,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Siap Panen!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: MangroveTheme.primaryGreenDark,
                      ),
                    ),
                  ],
                ),
              ),
            if (!isReadyToHarvest)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${((1 - percentage) * target).toStringAsFixed(1)} kg lagi untuk panen',
                  style: TextStyle(
                    fontSize: 12,
                    color: MangroveTheme.textHint,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: MangroveTheme.textHint,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: MangroveTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TARGET PANEN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: MangroveTheme.textHint,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${target.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: MangroveTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentGrid(
      BuildContext context, CalibrationSettings calibration) {
    final tempStatus =
        calibration.getTemperatureStatus(_device.temperature);
    final humStatus = calibration.getHumidityStatus(_device.humidity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              icon: Icons.thermostat_outlined,
              iconBgColor: _getTempIconBgColor(tempStatus),
              iconColor: _getTempIconColor(tempStatus),
              label: 'Temperature',
              value: _device.temperature.toStringAsFixed(1),
              unit: '°C',
              status: tempStatus,
              statusLabel: _getTempStatusLabel(tempStatus),
              thresholdInfo:
                  '${calibration.temperatureMin.toInt()}° - ${calibration.temperatureMax.toInt()}°C',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              icon: Icons.water_drop_outlined,
              iconBgColor: _getHumIconBgColor(humStatus),
              iconColor: _getHumIconColor(humStatus),
              label: 'Humidity',
              value: _device.humidity.toStringAsFixed(0),
              unit: '%',
              status: humStatus,
              statusLabel: _getHumStatusLabel(humStatus),
              thresholdInfo:
                  '${calibration.humidityMin.toInt()}% - ${calibration.humidityMax.toInt()}%',
            ),
          ),
        ],
      ),
    );
  }

  Color _getTempIconBgColor(String status) {
    switch (status) {
      case 'high':
        return Colors.red.shade50;
      case 'low':
        return Colors.blue.shade50;
      default:
        return Colors.orange.shade50;
    }
  }

  Color _getTempIconColor(String status) {
    switch (status) {
      case 'high':
        return Colors.red.shade500;
      case 'low':
        return Colors.blue.shade500;
      default:
        return Colors.orange.shade500;
    }
  }

  String _getTempStatusLabel(String status) {
    switch (status) {
      case 'high':
        return 'Terlalu Panas!';
      case 'low':
        return 'Terlalu Dingin!';
      default:
        return 'Normal';
    }
  }

  Color _getHumIconBgColor(String status) {
    switch (status) {
      case 'high':
        return Colors.blue.shade50;
      case 'low':
        return Colors.amber.shade50;
      default:
        return Colors.green.shade50;
    }
  }

  Color _getHumIconColor(String status) {
    switch (status) {
      case 'high':
        return Colors.blue.shade600;
      case 'low':
        return Colors.amber.shade600;
      default:
        return Colors.green.shade500;
    }
  }

  String _getHumStatusLabel(String status) {
    switch (status) {
      case 'high':
        return 'Terlalu Lembap!';
      case 'low':
        return 'Terlalu Kering!';
      default:
        return 'Normal';
    }
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
    required String status,
    required String statusLabel,
    required String thresholdInfo,
  }) {
    final isNormal = status == 'normal';

    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isNormal
              ? Colors.black.withValues(alpha: 0.05)
              : iconColor.withValues(alpha: 0.4),
          width: isNormal ? 1 : 2,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isNormal
                      ? MangroveTheme.success.withValues(alpha: 0.15)
                      : iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isNormal ? MangroveTheme.success : iconColor,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: MangroveTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color:
                          isNormal ? MangroveTheme.textPrimary : iconColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: MangroveTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            'Range: $thresholdInfo',
            style: TextStyle(
              fontSize: 10,
              color: MangroveTheme.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStatus(BuildContext context) {
    final batteryPct = (_batteryPercent * 100).toStringAsFixed(0);
    final voltageStr = _device.batteryVoltage.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'DEVICE STATUS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: MangroveTheme.textHint,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            _buildBatteryStatus(context, batteryPct, voltageStr),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryStatus(
      BuildContext context, String pct, String voltage) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _batteryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_batteryIcon, size: 18, color: _batteryColor),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Battery',
              style: TextStyle(
                fontSize: 11,
                color: MangroveTheme.textHint,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _batteryColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${voltage}V',
                  style: TextStyle(
                    fontSize: 12,
                    color: MangroveTheme.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        // Mini progress bar
        SizedBox(
          width: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _batteryPercent,
              minHeight: 8,
              backgroundColor: MangroveTheme.lightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(_batteryColor),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class _CircularGaugePainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;

  _CircularGaugePainter({
    required this.percentage,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 12.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = progressColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * percentage;

    canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.progressColor != progressColor;
  }
}
