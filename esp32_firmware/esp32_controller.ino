#include <WiFi.h>
#include <WebSocketsServer.h>
#include <ArduinoJson.h>

const char* ssid = "YOUR_SSID";
const char* password = "YOUR_PASSWORD";

// Start WebSocket server on port 8765
WebSocketsServer webSocket = WebSocketsServer(8765);

// PWM Pins for 5 LEDs (future servos)
const int ledPins[5] = {13, 12, 14, 27, 26};

void setup() {
  Serial.begin(115200);
  
  // Initialize PWM channels
  // For ESP32, ledc setup is recommended but analogWrite works on modern ESP32 cores
  for(int i = 0; i < 5; i++) {
    pinMode(ledPins[i], OUTPUT);
    analogWrite(ledPins[i], 0);
  }

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
  Serial.println(WiFi.localIP());

  webSocket.begin();
  webSocket.onEvent(webSocketEvent);
}

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_DISCONNECTED:
      Serial.printf("[%u] Disconnected!\n", num);
      break;
    case WStype_CONNECTED:
      {
        IPAddress ip = webSocket.remoteIP(num);
        Serial.printf("[%u] Connected from %d.%d.%d.%d\n", num, ip[0], ip[1], ip[2], ip[3]);
      }
      break;
    case WStype_TEXT:
      {
        // Parse JSON
        StaticJsonDocument<200> doc;
        DeserializationError error = deserializeJson(doc, payload);
        if (error) {
          Serial.print("deserializeJson() failed: ");
          Serial.println(error.c_str());
          return;
        }

        const char* msgType = doc["type"];
        if (msgType != nullptr) {
          if (strcmp(msgType, "slider") == 0) {
            int id = doc["id"];
            int value = doc["value"]; // -90 to 90
            
            if (id >= 1 && id <= 5) {
              // Map -90..90 to 0..255 for LED brightness
              int pwmValue = map(value, -90, 90, 0, 255);
              pwmValue = constrain(pwmValue, 0, 255);
              analogWrite(ledPins[id - 1], pwmValue);
            }
          } else if (strcmp(msgType, "command") == 0) {
            const char* val = doc["value"];
            Serial.printf("Command received: %s\n", val);
          } else if (strcmp(msgType, "text") == 0) {
            const char* val = doc["value"];
            Serial.printf("Text received: %s\n", val);
          }
        }
      }
      break;
  }
}

void loop() {
  webSocket.loop();
}
