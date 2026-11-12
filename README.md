# 🌡️ IoT Alert – ESP32 Temperature & Humidity Monitoring

**Système IoT de surveillance de température et d'humidité avec alertes automatiques par e-mail.**

Ce projet utilise un ESP32 associé à un capteur DHT11 pour mesurer les conditions environnementales. Les données sont transmises en JSON via USB série vers une machine Linux (Ubuntu), qui analyse les mesures et déclenche une notification par e-mail lorsque les seuils configurés sont dépassés.

**Technologies :** ESP32 · C++ / Arduino · Linux · Bash · UART · JSON · Postfix · SMTP

---

## 1. Architecture du système

```text
┌──────────┐
│  DHT11   │
└────┬─────┘
     │ Temperature / Humidity
     ▼
┌──────────┐
│  ESP32   │
└────┬─────┘
     │ USB Serial (JSON)
     ▼
┌──────────┐
│ read.sh  │
└────┬─────┘
     │
     ▼
┌──────────┐
│ last.json│
└────┬─────┘
     │
     ▼
┌──────────┐
│ alert.sh │
└────┬─────┘
     │ Threshold exceeded
     ▼
┌──────────┐
│ Postfix  │
└────┬─────┘
     │ SMTP Gmail
     ▼
  📧 Email
```

### Fonctionnement

1. **ESP32:** mesure la température et l'humidité toutes les 3 secondes.
2. **Communication série:** transmet les mesures au format JSON à 115200 bauds.
3. **read.sh:** récupère les données série et actualise `last.json`.
4. **alert.sh:** compare les mesures aux seuils `TEMP_MAX` et `HUM_MAX`.
5. **Postfix:** assure l'envoi des alertes par e-mail via SMTP Gmail.

Exemple de données :

```json
{
  "device": "esp32-usb",
  "timestamp": "t+473s",
  "temp": 17.1,
  "hum": 74.0
}
```

---

## 2. Hardware

- ESP32 development board
- DHT11 temperature and humidity sensor
- USB cable

### Wiring

| DHT11 | ESP32 |
|---|---|
| VCC | 3V3 |
| GND | GND |
| DATA | GPIO 4 |

![ESP32 and DHT11 wiring diagram](docs/images/schema-cablage.svg)

---

## 3. Software and dependencies

**Embedded side**
- Arduino IDE 1.8.x
- ESP32 board support package
- DHT sensor library

**Linux side**
- Ubuntu
- Bash
- Postfix
- libsasl2-modules
- mailutils

---

## 4. Installation and configuration

### Step 1 – ESP32 firmware

Open:

`firmware/esp32_dht11/esp32_dht11.ino`

Select the ESP32 board and the correct serial port, then upload the firmware.

Open the Serial Monitor at **115200 baud**.

### Step 2 – Linux scripts

```bash
sudo mkdir -p /opt/iot-alert
sudo cp scripts/*.sh /opt/iot-alert/
sudo chmod +x /opt/iot-alert/*.sh
```

### Step 3 – Configuration

Configure the serial port in `read.sh`:

```bash
SERIAL_PORT="/dev/ttyUSB0"
```

Configure the alert thresholds and recipient in `alert.sh`:

```bash
TEMP_MAX=...
HUM_MAX=...
EMAIL_TO="your-email@example.com"
```

Replace these example values with your actual configuration.

### Step 4 – Email configuration

Configure Postfix to use Gmail SMTP.

See: [Postfix Gmail configuration](docs/postfix-gmail.md).

### Step 5 – Run the system

Start serial data acquisition:

```bash
/opt/iot-alert/read.sh &
```

Run periodic threshold monitoring:

```bash
watch -n 60 /opt/iot-alert/alert.sh
```

---

## 5. Demonstration and results

### Serial monitoring

![ESP32 serial monitor](docs/images/moniteur-serie.png)

### Email alert notification

![Temperature threshold exceeded email](docs/images/email-alerte-depassement.jpg)

### Email alerts history

![Email alerts list](docs/images/emails-alertes-liste.jpg)

---

## 6. Repository structure

```text
iot-alert/
│
├── firmware/
│   └── esp32_dht11/
│       └── esp32_dht11.ino
│
├── scripts/
│   ├── read.sh
│   └── alert.sh
│
├── docs/
│   ├── images/
│   └── postfix-gmail.md
│
├── examples/
│   └── last.example.json
│
├── .gitignore
├── LICENSE
└── README.md
```

---

## 7. Skills and technologies

- Embedded C++ programming
- ESP32 microcontroller
- DHT11 sensor interfacing
- UART serial communication
- JSON data handling
- Linux system administration
- Bash scripting
- Postfix and SMTP email configuration
- IoT monitoring and alerting

---

## 8. Future improvements

- Use `jq` for robust JSON parsing.
- Prevent repeated email notifications using an alert cooldown.
- Deploy scripts as Linux `systemd` services.
- Replace USB serial communication with Wi-Fi and MQTT.

---

## Author

**Eya Sabri**  
Embedded Systems Engineering Student

[GitHub Profile](https://github.com/eya-sabri)

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).