#include "DHT.h"

// ===== CONFIGURATION CAPTEUR =====
#define DHTPIN 4       // Broche DATA du DHT11
#define DHTTYPE DHT11  // Type de capteur

DHT dht(DHTPIN, DHTTYPE);

// ===== INITIALISATION =====
void setup() {
  Serial.begin(115200);   // Communication USB vers le terminal
  dht.begin();            // Démarrage du capteur
  delay(5000);            // Laisse le bootloader finir
  Serial.println("{\"info\":\"ESP32 DHT11 ready\"}");
}

// ===== FONCTION HORODATAGE SIMPLE =====
String getTimeStamp() {
  unsigned long seconds = millis() / 1000;
  return String("t+") + String(seconds) + "s";
}

// ===== BOUCLE PRINCIPALE =====
void loop() {
  float humidite = dht.readHumidity();
  float temperature = dht.readTemperature(); // en °C

  // Vérification si la lecture est valide
  if (isnan(humidite) || isnan(temperature)) {
    Serial.println("{\"error\":\"dht-read-failed\"}");
  } else {
    // Construction du JSON complet
    String json = "{";
    json += "\"device\":\"esp32-usb\",";
    json += "\"timestamp\":\"" + getTimeStamp() + "\",";
    json += "\"temp\":" + String(temperature, 1) + ",";
    json += "\"hum\":" + String(humidite, 1);
    json += "}";

    // Envoi vers le terminal série
    Serial.println(json); // UNE SEULE LIGNE JSON
  }

  delay(3000);  // Une mesure toutes les 3 secondes
}
