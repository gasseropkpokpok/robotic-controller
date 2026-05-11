# 🤖 Robotic Controller Server

This Python server acts as the central hub for the Robotic Controller system. It handles real-time WebSocket communication from the mobile app and provides a discovery mechanism and command history access.

## 🚀 Quick Start

1. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

2. **Run the server**:
   ```bash
   python server.py
   ```

## 🛠 Features

- **Real-time Control**: Receives joint values and commands via WebSockets (Port 8765).
- **Auto-Discovery**: Broadcasts a UDP beacon (Port 8766) so the mobile app can find the server automatically.
- **Accessible Cache**: View the command history directly in your browser:
  - URL: `http://<server-ip>:8767/cache`
- **Command Logging**: All interactions are saved to `cache/commands.json`.

## 📡 Protocol

- **Joint Data**: Sent as a flat JSON map (e.g., `{"J1": 45, "J2": -10}`).
- **Commands**: Sent as plain text strings (e.g., `set`, `user one`).
