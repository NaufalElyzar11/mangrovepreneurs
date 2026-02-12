import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/services/firebase_service.dart';
import '../data/models/device.dart';
import '../core/theme/mangrove_theme.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final List<SensorDataPoint> _tempHistory = [];
  final List<SensorDataPoint> _humHistory = [];
  final List<SensorDataPoint> _weightHistory = [];
  
  StreamSubscription<List<Device>>? _subscription;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _subscription = _firebaseService.getDevicesStream().listen((devices) {
      if (devices.isNotEmpty && mounted) {
        final device = devices.first;
        final now = DateTime.now();

        setState(() {
          _tempHistory.add(SensorDataPoint(timestamp: now, value: device.temperature));
          _humHistory.add(SensorDataPoint(timestamp: now, value: device.humidity));
          _weightHistory.add(SensorDataPoint(timestamp: now, value: device.weight));
          if (_tempHistory.length > 30) _tempHistory.removeAt(0);
          if (_humHistory.length > 30) _humHistory.removeAt(0);
          if (_weightHistory.length > 30) _weightHistory.removeAt(0);
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tempHistory.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Live Monitor')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Waiting for incoming data...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Ensure Arduino is ON and connected to WiFi',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear History',
            onPressed: () {
              setState(() {
                _tempHistory.clear();
                _humHistory.clear();
                _weightHistory.clear();
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          _buildChartCard(
            context,
            title: 'Temperature',
            subtitle: 'Live Sensor Data',
            unit: '°C',
            data: _tempHistory,
            color: MangroveTheme.warning,
            minY: 20,
            maxY: 45,
          ),
          
          const SizedBox(height: 16),
          
          _buildChartCard(
            context,
            title: 'Humidity',
            subtitle: 'Live Sensor Data',
            unit: '%',
            data: _humHistory,
            color: MangroveTheme.primaryGreen,
            minY: 0,
            maxY: 100,
          ),
          
          const SizedBox(height: 16),
          
          _buildChartCard(
            context,
            title: 'Weight',
            subtitle: 'Live Load Cell Data',
            unit: 'kg',
            data: _weightHistory,
            color: MangroveTheme.mutedBrown,
            minY: 0, 
            maxY: 10, 
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildChartCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String unit,
    required List<SensorDataPoint> data,
    required Color color,
    required double minY,
    required double maxY,
  }) {
    double dataMin = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    double dataMax = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    double displayMin = (dataMin < minY) ? dataMin - 1 : minY;
    double displayMax = (dataMax > maxY) ? dataMax + 1 : maxY;

    return Card(
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
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getIconForTitle(title),
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          data.isNotEmpty 
                            ? '${data.last.value.toStringAsFixed(1)} $unit' 
                            : subtitle,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: color, fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10, 
                          color: Colors.red, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
                    
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (displayMax - displayMin) / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: MangroveTheme.lightGrey.withValues(alpha: 0.5),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (displayMax - displayMin) / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)}$unit',
                            style: const TextStyle(
                              fontSize: 10,
                              color: MangroveTheme.textHint,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                             if (index % 5 == 0 || index == data.length - 1) {
                               return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _formatTimeLabel(data[index].timestamp),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: MangroveTheme.textHint,
                                    ),
                                  ),
                                );
                             }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: displayMin,
                  maxY: displayMax,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.value,
                        );
                      }).toList(),
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          if (idx >= 0 && idx < data.length) {
                             final point = data[idx];
                             return LineTooltipItem(
                                '${point.value.toStringAsFixed(2)}$unit\n${_formatFullTime(point.timestamp)}',
                                TextStyle(color: color, fontWeight: FontWeight.bold),
                             );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'temperature':
        return Icons.thermostat_outlined;
      case 'humidity':
        return Icons.water_drop_outlined;
      case 'weight':
        return Icons.scale_outlined;
      default:
        return Icons.show_chart;
    }
  }
  
  String _formatTimeLabel(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  String _formatFullTime(DateTime date) {
    return '${_formatTimeLabel(date)}';
  }
}
