# Architecture

## Overview
The system uses a Star network topology where the Mobile App acts as the master controller, connecting to either a Python receiver (for testing/PC integration) or an ESP32 (for hardware control).

## Mobile App
- **Clean Architecture**: Separation of UI, State (Provider), and Services.
- **Debouncing**: Sliders do not flood the network. They debounce changes (50ms).
- **WebSockets**: Real-time bidirectional communication.

## Python Server
- Async `websockets` implementation.
- In-memory ring buffer for cache (100 commands), persisted to disk.

## ESP32
- WebSockets server.
- JSON parsing with `ArduinoJson`.
- Non-blocking loop.
