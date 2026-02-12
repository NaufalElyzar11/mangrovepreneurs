import 'package:flutter/material.dart';
import '../core/theme/mangrove_theme.dart';
import '../data/models/calibration_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _calibrationService = CalibrationService();
  
  late TextEditingController _tempMinController;
  late TextEditingController _tempMaxController;
  
  late TextEditingController _humidityMinController;
  late TextEditingController _humidityMaxController;
  
  late TextEditingController _harvestWeightController;
  
  @override
  void initState() {
    super.initState();
    final settings = _calibrationService.settings;
    _tempMinController = TextEditingController(text: settings.temperatureMin.toString());
    _tempMaxController = TextEditingController(text: settings.temperatureMax.toString());
    _humidityMinController = TextEditingController(text: settings.humidityMin.toString());
    _humidityMaxController = TextEditingController(text: settings.humidityMax.toString());
    _harvestWeightController = TextEditingController(text: settings.harvestWeight.toString());
  }
  
  @override
  void dispose() {
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _humidityMinController.dispose();
    _humidityMaxController.dispose();
    _harvestWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Sensor Thresholds',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Set min/max limits for alerts and indicators',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildThresholdCard(
              context,
              title: 'Temperature Limits',
              icon: Icons.thermostat_outlined,
              iconColor: Colors.orange.shade500,
              description: 'Set the acceptable temperature range. Values outside this range will trigger alerts.',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _tempMinController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Minimum',
                          suffixText: '°C',
                          prefixIcon: Icon(Icons.arrow_downward, color: Colors.blue.shade400, size: 20),
                        ),
                        validator: (value) => _validateNumber(value, 'minimum temperature', 0, 50),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _tempMaxController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Maximum',
                          suffixText: '°C',
                          prefixIcon: Icon(Icons.arrow_upward, color: Colors.red.shade400, size: 20),
                        ),
                        validator: (value) => _validateNumber(value, 'maximum temperature', 0, 50),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildIndicatorLegend(
                  items: [
                    ('Below min', Colors.blue.shade400, Icons.ac_unit),
                    ('Normal', MangroveTheme.success, Icons.check_circle_outline),
                    ('Above max', Colors.red.shade400, Icons.local_fire_department),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildThresholdCard(
              context,
              title: 'Humidity Limits',
              icon: Icons.water_drop_outlined,
              iconColor: Colors.blue.shade500,
              description: 'Set the acceptable humidity range for optimal hive conditions.',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _humidityMinController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Minimum',
                          suffixText: '%',
                          prefixIcon: Icon(Icons.arrow_downward, color: Colors.amber.shade600, size: 20),
                        ),
                        validator: (value) => _validateNumber(value, 'minimum humidity', 0, 100),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _humidityMaxController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Maximum',
                          suffixText: '%',
                          prefixIcon: Icon(Icons.arrow_upward, color: Colors.blue.shade600, size: 20),
                        ),
                        validator: (value) => _validateNumber(value, 'maximum humidity', 0, 100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildIndicatorLegend(
                  items: [
                    ('Too dry', Colors.amber.shade600, Icons.wb_sunny),
                    ('Normal', MangroveTheme.success, Icons.check_circle_outline),
                    ('Too humid', Colors.blue.shade600, Icons.cloud),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildThresholdCard(
              context,
              title: 'Harvest Weight Target',
              icon: Icons.scale_outlined,
              iconColor: MangroveTheme.mutedBrown,
              description: 'Set the weight threshold to indicate when honey is ready for harvest.',
              children: [
                TextFormField(
                  controller: _harvestWeightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Target Weight for Harvest',
                    suffixText: 'kg',
                    prefixIcon: Icon(Icons.hive_outlined, size: 20),
                  ),
                  validator: (value) => _validateNumber(value, 'harvest weight', 0.1, 50),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MangroveTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: MangroveTheme.primaryGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: MangroveTheme.primaryGreenDark,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'When hive weight reaches this target, a "Ready to Harvest" indicator will appear.',
                          style: TextStyle(
                            fontSize: 12,
                            color: MangroveTheme.primaryGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Settings'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton.icon(
                onPressed: _resetToDefaults,
                icon: const Icon(Icons.restore_outlined),
                label: const Text('Reset to Defaults'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: MangroveTheme.textSecondary,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildThresholdCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required String description,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: MangroveTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
  
  Widget _buildIndicatorLegend({
    required List<(String label, Color color, IconData icon)> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: MangroveTheme.lightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.$3, size: 14, color: item.$2),
            const SizedBox(width: 4),
            Text(
              item.$1,
              style: TextStyle(
                fontSize: 11,
                color: item.$2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }
  
  String? _validateNumber(String? value, String fieldName, double min, double max) {
    if (value == null || value.isEmpty) {
      return 'Please enter a $fieldName';
    }
    final num = double.tryParse(value);
    if (num == null) {
      return 'Please enter a valid number';
    }
    if (num < min || num > max) {
      return 'Must be between $min and $max';
    }
    return null;
  }
  
  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final tempMin = double.parse(_tempMinController.text);
      final tempMax = double.parse(_tempMaxController.text);
      final humMin = double.parse(_humidityMinController.text);
      final humMax = double.parse(_humidityMaxController.text);
      
      if (tempMin >= tempMax) {
        _showError('Temperature minimum must be less than maximum');
        return;
      }
      if (humMin >= humMax) {
        _showError('Humidity minimum must be less than maximum');
        return;
      }
      
      final newSettings = CalibrationSettings(
        temperatureMin: tempMin,
        temperatureMax: tempMax,
        humidityMin: humMin,
        humidityMax: humMax,
        harvestWeight: double.parse(_harvestWeightController.text),
      );
      
      _calibrationService.updateSettings(newSettings);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved successfully!'),
          backgroundColor: MangroveTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: MangroveTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  void _resetToDefaults() {
    _calibrationService.resetToDefaults();
    final settings = _calibrationService.settings;
    
    setState(() {
      _tempMinController.text = settings.temperatureMin.toString();
      _tempMaxController.text = settings.temperatureMax.toString();
      _humidityMinController.text = settings.humidityMin.toString();
      _humidityMaxController.text = settings.humidityMax.toString();
      _harvestWeightController.text = settings.harvestWeight.toString();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings reset to defaults'),
        backgroundColor: MangroveTheme.oliveGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
