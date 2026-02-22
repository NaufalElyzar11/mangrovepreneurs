#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BME280.h>
#include "HX711.h"

#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// 2. CREDENTIALS
#define WIFI_SSID "Zzz"
#define WIFI_PASSWORD "kandangan"

// Dari google-services.json
#define API_KEY "AIzaSyBJwst2FOrRC0iHOh9OA4GpwdiMs8OfKto"
#define DATABASE_URL "https://mangrovepreneurs-default-rtdb.asia-southeast1.firebasedatabase.app"

// 3. OBJECTS & PINS
// ========= PIN (ESP32) =========
#define SDA_PIN 21
#define SCL_PIN 22
#define HX_DT   26
#define HX_SCK  27
#define BAT_PIN 34   // ADC pin untuk monitoring baterai (GPIO34)

// ========= KALIBRASI =========
#define CAL_FACTOR  -22734.2500   // <<< HASIL KALIBRASI (PER KG)

Adafruit_BME280 bme;
HX711 scale;

// Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
bool signupOK = false;
unsigned long sendDataPrevMillis = 0;
const long interval = 5000; // Kirim setiap 5 detik

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("\n=== KELULUT IoT START ===");

  // ===== WiFi Setup =====
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());

  // ===== Firebase Setup =====
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  
  // Sign up anonim agar bisa akses database
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase Auth Success");
    signupOK = true;
  } else {
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  config.token_status_callback = tokenStatusCallback;
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // ===== BME280 =====
  Wire.begin(SDA_PIN, SCL_PIN);
  if (!bme.begin(0x76)) {
    Serial.println("BME280 ERROR - Check wiring!");
    // while (1); // Jangan stop total agar masih bisa debug auth
  }

  // ===== HX711 =====
  scale.begin(HX_DT, HX_SCK);
  scale.set_scale(CAL_FACTOR);
  scale.tare();

  Serial.println("System READY 🚀");
}

void loop() {
  // Hanya proses jika sudah waktunya (non-blocking delay)
  if (millis() - sendDataPrevMillis > interval || sendDataPrevMillis == 0) {
    sendDataPrevMillis = millis();

    // 1. Baca Sensor
    float temp = bme.readTemperature();
    float hum = bme.readHumidity();
    float pres = bme.readPressure() / 100.0F; // hPa
    float weightKg = scale.get_units(10); // Average 10 readings

    // Baca tegangan baterai
    int adcValue = analogRead(BAT_PIN);
    float batteryVoltage = (adcValue / 4095.0) * 3.3 * 2; // Voltage divider 1:1

    // Debug Serial
    Serial.print("Temp: "); Serial.print(temp); Serial.print(" C, ");
    Serial.print("Hum: "); Serial.print(hum); Serial.print(" %, ");
    Serial.print("Weight: "); Serial.print(weightKg); Serial.print(" kg, ");
    Serial.print("Battery: "); Serial.print(batteryVoltage); Serial.println(" V");

    // 2. Kirim ke Firebase
    if (Firebase.ready() && signupOK) {
      
      // Buat JSON object
      FirebaseJson json;
      json.set("id", "device_001");           // ID Device tetap
      json.set("name", "Sensor Kelulut 1");   // Nama Device
      json.set("temperature", temp);
      json.set("humidity", hum);
      json.set("weight", weightKg);
      json.set("batteryVoltage", batteryVoltage);
      // Kirim server timestamp (integer ms)
      json.set("lastUpdated/.sv", "timestamp");

      // Set data ke path: /devices/device_001
      // Ini akan membuat struktur data yang sesuai dengan aplikasi Flutter
      if (Firebase.RTDB.setJSON(&fbdo, "/devices/device_001", &json)) {
        Serial.println("Data sent to Firebase! ✅");
      } else {
        Serial.print("FAILED: ");
        Serial.println(fbdo.errorReason());
      }
    }
  }
}
