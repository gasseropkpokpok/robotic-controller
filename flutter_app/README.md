# 📱 Robotic Controller Mobile App

A Flutter-based mobile application designed for low-latency robotic control.

## ✨ Features

- **Auto-Discovery**: Automatically finds servers (Python or ESP32) on the local network using UDP beacons.
- **Ultra-Compact UI**: All 5 joint sliders fit on a single screen without scrolling.
- **Batch Updates**: Sends all joint values in a single packet for synchronized movement.
- **Custom Branding**: "First Team RC" branding with futuristic aesthetics.

## 🛠 Development

1. **Install Flutter**: Follow the [official guide](https://docs.flutter.dev/get-started/install).
2. **Get Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run**:
   ```bash
   flutter run
   ```

## 🏗 Build (APK)

The app is automatically built for Android on every push to GitHub. You can download the latest version from the **Actions** tab in the repository.
