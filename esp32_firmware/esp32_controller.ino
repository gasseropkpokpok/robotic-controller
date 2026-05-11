#include <WiFi.h>
#include <WiFiUdp.h>
#include <WebSocketsServer.h>
#include <ArduinoJson.h>

// WiFi Configuration
const char* ssid = "YOUR_SSID";
const char* password = "YOUR_PASSWORD";

// Ports
const int WS_PORT = 8765;
const int UDP_PORT = 8766;

// WebSockets Server
WebSocketsServer webSocket = WebSocketsServer(WS_PORT);

// UDP for Discovery
WiFiUDP udp;
IPAddress broadcastIP(255, 255, 255, 255);
unsigned long lastBroadcast = 0;

// Hardware Configuration (Joint Pins)
const int jointPins[5] = {13, 12, 14, 27, 26};

void setup() {
  Serial.begin(115200);
  
  // Initialize Joint Pins (PWM)
  for(int i = 0; i < 5; i++) {
    pinMode(jointPins[i], OUTPUT);
    analogWrite(jointPins[i], 0);
  }

  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Start WebSocket Server
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);

  Serial.println("Robotic Controller ESP32 Started.");
}

void loop() {
  webSocket.loop();

  // UDP Discovery Broadcast (every 2 seconds)
  if (millis() - lastBroadcast > 2000) {
    lastBroadcast = millis();
    String payload = "ROBOT_CTRL:" + WiFi.localIP().toString() + ":" + String(WS_PORT);
    udp.beginPacket(broadcastIP, UDP_PORT);
    udp.print(payload);
    udp.endPacket();
  }
}

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_CONNECTED:
      Serial.printf("[%u] Client Connected\n", num);
      break;
      
    case WStype_DISCONNECTED:
      Serial.printf("[%u] Client Disconnected\n", num);
      break;
      
    case WStype_TEXT:
      {
        String msg = String((char*)payload);
        StaticJsonDocument<512> doc;
        DeserializationError error = deserializeJson(doc, msg);

        if (!error) {
          // It's a JSON message (Joint Values)
          // Expected: {"J1": 45, "J2": -10, ...}
          for (int i = 0; i < 5; i++) {
            String key = "J" + String(i + 1);
            if (doc.containsKey(key)) {
              int angle = doc[key];
              // Map -90..90 to 0..255 PWM
              int pwm = map(angle, -90, 90, 0, 255);
              pwm = constrain(pwm, 0, 255);
              analogWrite(jointPins[i], pwm);
              Serial.printf("%s: %d ", key.c_str(), angle);
            }
          }
          Serial.println();
          webSocket.sendTXT(num, "ack");
        } 
        else {
          // It's plain text (Command)
          Serial.printf("Command: %s\n", msg.c_str());
          webSocket.sendTXT(num, "ack");
        }
      }
      break;
  }
}
