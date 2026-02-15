#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>
#include <ESP32Servo.h>
#include <ArduinoJson.h>

#define POT_PIN 34
#define DHT_PIN 15
#define RELAY_PIN 2
#define SERVO_PIN 18

const char* ssid = "Wokwi-GUEST";
const char* password = "";
const char* mqtt_server = "broker.emqx.io"; // Public broker

WiFiClient espClient;
PubSubClient client(espClient);
DHT dht(DHT_PIN, DHT22);
Servo valveServo;

void setup() {
  Serial.begin(115200);
  pinMode(RELAY_PIN, OUTPUT);
  valveServo.attach(SERVO_PIN);
  dht.begin();
  
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) delay(500);
  
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

void callback(char* topic, byte* payload, unsigned int length) {
  StaticJsonDocument<256> doc;
  deserializeJson(doc, payload, length);
  
  bool shouldIrrigate = doc["irrigate"];
  int angle = doc["angle"];
  int durationMs = doc["duration_ms"];
  const char* status = doc["status"];

  Serial.print("System Status: ");
  Serial.println(status);

  if (shouldIrrigate && strcmp(status, "Normal") == 0) {
    digitalWrite(RELAY_PIN, HIGH);
    valveServo.write(angle);
    
    // Non-blocking wait (simplified for example)
    delay(durationMs); 
    
    // Auto-close after duration
    digitalWrite(RELAY_PIN, LOW);
    valveServo.write(0);
  } else if (strcmp(status, "LEAK_DETECTED") == 0) {
    // Safety: Shut everything down if a leak is suspected
    digitalWrite(RELAY_PIN, LOW);
    valveServo.write(0);
    Serial.println("EMERGENCY SHUTDOWN: LEAK");
  }
}

void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  // Send data every 10 seconds
  static unsigned long lastMsg = 0;
  if (millis() - lastMsg > 10000) {
    lastMsg = millis();
    int moisture = map(analogRead(POT_PIN), 0, 4095, 0, 100);
    float t = dht.readTemperature();
    
    StaticJsonDocument<200> doc;
    doc["moisture"] = moisture;
    doc["temp"] = t;
    client.publish("garden/sensors", "{\"moisture\":25, \"temp\":30}"); // Example JSON
  }
}

void reconnect() {
  while (!client.connected()) {
    if (client.connect("ESP32_Irrigator")) {
      client.subscribe("garden/command");
    } else {
      delay(5000);
    }
  }
}