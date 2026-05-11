# ⚡ ESP32 Robotic Firmware

Arduino-compatible firmware for controlling robot joints using an ESP32 microcontroller.

## 🔌 Hardware Setup

- **Joint A (J1)**: GPIO 13
- **Joint B (J2)**: GPIO 12
- **Joint C (J3)**: GPIO 14
- **Joint D (J4)**: GPIO 27
- **Joint E (J5)**: GPIO 26

## ⚙️ Installation

1. Open `esp32_controller.ino` in the **Arduino IDE**.
2. Install the **ArduinoJson** and **WebSockets** (by Markus Sattler) libraries.
3. Update `ap_ssid` and `ap_password` if desired (Default: `FirstTeamRobot` / `password123`).
4. Select "ESP32 Dev Module" and flash to your device.

## 📱 Connecting your Phone

1. Open your phone's WiFi settings.
2. Connect to **"FirstTeamRobot"** (Password: `password123`).
3. Open the **First Team RC** app.
4. It should automatically find the robot at `192.168.4.1`.

## 🔍 How it Works

1. **Discovery**: Every 2 seconds, the ESP32 sends a UDP broadcast. The mobile app hears this and shows the ESP32 in the "Available Devices" list.
2. **Control**: The app opens a WebSocket connection. When you move a slider, the ESP32 receives a JSON map and updates the PWM signals on the corresponding pins.
