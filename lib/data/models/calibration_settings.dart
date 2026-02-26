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
  
  String getTemperatureStatus(double temperature) {
    if (temperature > temperatureMax) return 'high';
    if (temperature < temperatureMin) return 'low';
    return 'normal';
  }
  
  String getHumidityStatus(double humidity) {
    if (humidity > humidityMax) return 'high';
    if (humidity < humidityMin) return 'low';
    return 'normal';
  }
  
  bool isReadyForHarvest(double weight) {
    return weight >= harvestWeight;
  }
  
  double getHarvestProgress(double weight) {
    return (weight / harvestWeight).clamp(0.0, 1.0);
  }
}

class CalibrationService {
  static final CalibrationService _instance = CalibrationService._internal();
  factory CalibrationService() => _instance;
  CalibrationService._internal();
  
  // Store settings per device ID
  final Map<String, CalibrationSettings> _settings = {};
  
  CalibrationSettings getSettings(String deviceId) {
    if (!_settings.containsKey(deviceId)) {
      _settings[deviceId] = const CalibrationSettings();
    }
    return _settings[deviceId]!;
  }
  
  void updateSettings(String deviceId, CalibrationSettings newSettings) {
    _settings[deviceId] = newSettings;
  }
  
  void resetToDefaults(String deviceId) {
    _settings[deviceId] = const CalibrationSettings();
  }
  
  // Keep this for backwards compatibility where deviceId isn't available yet,
  // or default to a "default" string.
  CalibrationSettings get settings => getSettings("default");
}
