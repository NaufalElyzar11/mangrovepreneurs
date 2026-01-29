import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/services/mock_data_service.dart';
import '../data/models/device.dart';
import '../core/theme/mangrove_theme.dart';

/// Statistics Page - Historical data charts
/// Shows line charts for temperature, humidity, and weight over time
/// Uses fl_chart for simple, clean visualizations

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockService = MockDataService();
    final history = mockService.getAggregatedHistory();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        children: [
          // Temperature chart
          _buildChartCard(
            context,
            title: 'Temperature',
            subtitle: 'Average across all hives',
            unit: '°C',
            data: history.temperatureHistory,
            color: MangroveTheme.warning,
            minY: 28,
            maxY: 38,
          ),
          
          const SizedBox(height: 16),
          
          // Humidity chart
          _buildChartCard(
            context,
            title: 'Humidity',
            subtitle: 'Average across all hives',
            unit: '%',
            data: history.humidityHistory,
            color: MangroveTheme.primaryGreen,
            minY: 60,
            maxY: 90,
          ),
          
          const SizedBox(height: 16),
          
          // Weight chart
          _buildChartCard(
            context,
            title: 'Weight',
            subtitle: 'Total hive weight trend',
            unit: 'kg',
            data: history.weightHistory,
            color: MangroveTheme.mutedBrown,
            minY: 10,
            maxY: 18,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Chart
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: MangroveTheme.lightGrey,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: (maxY - minY) / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}$unit',
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
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < data.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _formatDayLabel(data[index].timestamp),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: MangroveTheme.textHint,
                                ),
                              ),
                            );
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
                  maxX: data.length.toDouble() - 1,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.value,
                        );
                      }).toList(),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: color,
                          );
                        },
                      ),
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
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)}$unit',
                            TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 14,
                  color: MangroveTheme.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  'Last 7 days',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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
  
  String _formatDayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}
