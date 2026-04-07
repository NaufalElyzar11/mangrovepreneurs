# 🐝 Mangrovepreneurs

A Flutter mobile application for **real-time IoT monitoring of Kelulut (Stingless Bee) hives** in mangrove ecosystems. Built by the Mangrovepreneurs team in collaboration with the NRN Project Team.

---

## 📱 About

**Mangrovepreneurs** is a smart beekeeping companion app that connects to IoT sensor devices installed on Kelulut (*Trigona sp.*) hives. It provides beekeepers with live data, historical analytics, and automated alerts — enabling data-driven, sustainable beekeeping practices in mangrove forest environments.

---

## ✨ Features

- **📊 Live Dashboard** — View all connected hives at a glance with real-time sensor readings
- **🌡️ Sensor Monitoring** — Track temperature, humidity, and hive weight per device
- **🔋 Battery Status** — Visual battery indicator with voltage display for each IoT node
- **📈 Statistics & Charts** — Historical sensor data visualized with interactive charts
- **🔔 Smart Alerts** — Background service sends OS-level push notifications when readings are out of range
- **⚙️ Device Settings** — Configure sensor thresholds and calibration per hive
- **👥 Team Profile** — About page showcasing the Mangrovepreneurs and NRN Project teams

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Backend / Database | Firebase Realtime Database |
| Charts | fl_chart |
| Notifications | flutter_local_notifications |
| Background Service | flutter_background_service |
| State Persistence | shared_preferences |
| Splash Screen | flutter_native_splash |

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point & bottom nav scaffold
├── firebase_options.dart        # Firebase configuration
├── core/
│   └── theme/
│       └── mangrove_theme.dart  # App-wide color palette & typography
├── data/
│   ├── models/
│   │   ├── device.dart          # Device, SensorDataPoint, DeviceHistory models
│   │   └── calibration_settings.dart
│   └── services/
│       ├── firebase_service.dart     # Firebase Realtime DB listener & seeding
│       ├── alert_service.dart        # Threshold checking & alert logic
│       ├── notification_service.dart # Local push notification setup
│       ├── background_service.dart   # Keeps Firebase listener alive in background
│       └── mock_data_service.dart    # Mock data for development/testing
├── pages/
│   ├── dashboard_page.dart      # Home screen — list of hive device cards
│   ├── device_detail_page.dart  # Per-device sensor charts and controls
│   ├── statistics_page.dart     # Aggregate statistics view
│   ├── settings_page.dart       # Per-device threshold & calibration settings
│   └── profile_page.dart        # About page — project info & team members
└── widgets/
    ├── device_card.dart         # Hive summary card with sensor readings
    ├── sensor_card.dart         # Individual sensor display widget
    └── team_member_card.dart    # Team member profile card
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `^3.10.7`
- A Firebase project with **Realtime Database** enabled
- Android Studio / VS Code with Flutter & Dart extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/NaufalElyzar11/mangrovepreneurs.git
   cd mangrovepreneurs_v2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective platform directories, then update `lib/firebase_options.dart` with your project configuration.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 🔥 Firebase Data Structure

The app reads from the following Firebase Realtime Database schema:

```
/devices/
  {deviceId}/
    id: string
    name: string
    temperature: number   # °C
    humidity: number      # %
    weight: number        # kg
    batteryVoltage: number # V (3.0–4.2V range)
    lastUpdated: string   # ISO 8601 timestamp
    history/
      temperature/[ { timestamp, value } ]
      humidity/  [ { timestamp, value } ]
      weight/    [ { timestamp, value } ]
```

---

## 👥 Team

### Mangrovepreneurs Team
| Name | Role |
|---|---|
| M. Baihaqi | Team Leader |
| Luthfi Nor Anshori | Bee Specialist |
| Rezky Amalia | Field Researcher |

### NRN Project Team (IoT & Software)
| Name | Role |
|---|---|
| Siti Fathimah Azzahra | IoT Engineer |
| Nanda Ikbar | Electrical & Mechanical Engineer |
| Naufal Elyzar | Software Engineer |

---

## 🪲 About Kelulut

**Kelulut** (*Trigona sp.*), also known as stingless bees, are native to Southeast Asia and are vital pollinators in mangrove ecosystems. Their honey has distinctive medicinal properties. This app helps beekeepers monitor hive health without disturbing the colony, supporting sustainable and data-driven kelulut farming.

---

## 📄 License

This project is private and not published to pub.dev.

---

*Mangrovepreneurs App v1.0.0*
