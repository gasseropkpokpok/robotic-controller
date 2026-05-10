# Setup Guide

## 1. Flutter App
Navigate to the Flutter project and generate platforms:
```bash
cd flutter_app
flutter create .
flutter pub get
flutter run
```

## 2. Python Server
```bash
cd python_receiver
pip install -r requirements.txt
python server.py
```

## 3. ESP32
- Open `esp32_firmware/esp32_controller.ino` in Arduino IDE.
- Install `WebSockets` by Markus Sattler and `ArduinoJson` by Benoit Blanchon.
- Change `YOUR_SSID` and `YOUR_PASSWORD`.
- Flash to ESP32.
