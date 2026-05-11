# 🦾 First Team Robotic Controller

A complete ecosystem for controlling robotic joints via a mobile app, supporting both PC-based simulation (Python) and ESP32 hardware.

## 📂 Project Structure

- **[`flutter_app`](./flutter_app)**: Cross-platform mobile app (Android/iOS) with auto-discovery and ultra-compact controls.
- **[`python_receiver`](./python_receiver)**: Python-based simulation server with an HTTP-accessible command cache.
- **[`esp32_firmware`](./esp32_firmware)**: Arduino/C++ code for ESP32 hardware control via PWM.

## 📡 Protocol Summary

- **Discovery**: UDP Broadcast on port `8766` (`ROBOT_CTRL:IP:PORT`).
- **Communication**: WebSockets on port `8765`.
- **Data Format**:
  - **Joints**: `{"J1": angle, "J2": angle, ...}`
  - **Commands**: Plain strings (e.g., `"set"`, `"user one"`).

## 🚀 Quick Setup

1. **Mobile**: Build the APK via GitHub Actions or locally using `flutter build apk`.
2. **Server**: Run `python server.py` in the `python_receiver` folder.
3. **ESP32**: Flash `esp32_controller.ino` after updating WiFi credentials.
