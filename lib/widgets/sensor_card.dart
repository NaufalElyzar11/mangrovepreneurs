import 'package:flutter/material.dart';
import '../core/theme/mangrove_theme.dart';

/// Reusable SensorCard widget for displaying individual sensor data
/// Used on Device Detail page to show detailed sensor information

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color? iconColor;
  final double? progress; // Optional progress value between 0 and 1
  final double? maxValue; // Optional max value for progress calculation
  
  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.iconColor,
    this.progress,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? MangroveTheme.primaryGreen;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Value display
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MangroveTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: MangroveTheme.textSecondary,
                  ),
                ),
              ],
            ),
            
            // Optional progress indicator
            if (progress != null || maxValue != null) ...[
              const SizedBox(height: 16),
              _buildProgressIndicator(context, effectiveIconColor),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicator(BuildContext context, Color color) {
    // Calculate progress - either use provided progress or calculate from maxValue
    final double progressValue;
    if (progress != null) {
      progressValue = progress!.clamp(0.0, 1.0);
    } else if (maxValue != null && maxValue! > 0) {
      final numericValue = double.tryParse(value) ?? 0;
      progressValue = (numericValue / maxValue!).clamp(0.0, 1.0);
    } else {
      progressValue = 0.5;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: MangroveTheme.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 6),
        if (maxValue != null)
          Text(
            'Max: ${maxValue!.toStringAsFixed(1)} $unit',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

/// Section header widget for device detail page
class SensorSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  
  const SensorSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: MangroveTheme.oliveGreen,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: MangroveTheme.oliveGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
