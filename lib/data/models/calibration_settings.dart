/// Calibration settings model for sensor thresholds
/// Stores min/max values for temperature, humidity, and harvest weight target
library;

class CalibrationSettings {
  final double temperatureMin;
  final double temperatureMax;
  final double humidityMin;
  final double humidityMax;
  final double harvestWeight;
  
  const CalibrationSettings({
    this.temperatureMin = 25.0,
    this.temperatureMax = 35.0,
    this.humidityMin = 60.0,
    this.humidityMax = 85.0,
    this.harvestWeight = 6.0,
  });
  
  CalibrationSettings copyWith({
    double? temperatureMin,
    double? temperatureMax,
    double? humidityMin,
    double? humidityMax,
    double? harvestWeight,
  }) {
    return CalibrationSettings(
      temperatureMin: temperatureMin ?? this.temperatureMin,
      temperatureMax: temperatureMax ?? this.temperatureMax,
      humidityMin: humidityMin ?? this.humidityMin,
      humidityMax: humidityMax ?? this.humidityMax,
      harvestWeight: harvestWeight ?? this.harvestWeight,
    );
  }
  
  /// Check temperature status
  /// Returns: 'normal', 'high', or 'low'
  String getTemperatureStatus(double temperature) {
    if (temperature > temperatureMax) return 'high';
    if (temperature < temperatureMin) return 'low';
    return 'normal';
  }
  
  /// Check humidity status
  /// Returns: 'normal', 'high', or 'low'
  String getHumidityStatus(double humidity) {
    if (humidity > humidityMax) return 'high';
    if (humidity < humidityMin) return 'low';
    return 'normal';
  }
  
  /// Check if honey is ready for harvest
  bool isReadyForHarvest(double weight) {
    return weight >= harvestWeight;
  }
  
  /// Get harvest progress percentage
  double getHarvestProgress(double weight) {
    return (weight / harvestWeight).clamp(0.0, 1.0);
  }
}

/// Singleton service to manage calibration settings
/// In future: persist to SharedPreferences or API
class CalibrationService {
  static final CalibrationService _instance = CalibrationService._internal();
  factory CalibrationService() => _instance;
  CalibrationService._internal();
  
  CalibrationSettings _settings = const CalibrationSettings();
  
  CalibrationSettings get settings => _settings;
  
  void updateSettings(CalibrationSettings newSettings) {
    _settings = newSettings;
  }
  
  void resetToDefaults() {
    _settings = const CalibrationSettings();
  }
}
