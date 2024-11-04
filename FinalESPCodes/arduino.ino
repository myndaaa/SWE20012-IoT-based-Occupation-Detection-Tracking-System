#include <FastLED.h>
#include <WiFi.h>
#include <SPI.h>
#include <MFRC522.h>
#include <PubSubClient.h>

// WiFi credentials
const char* ssid = "airbus";
const char* password = "hihelloobye";

// MQTT server details
const char* mqtt_server = "192.168.0.101";
const int mqtt_port = 1883;

#define NUM_LEDS 144
#define BUZZER_PIN 4 
#define LED_PIN   22
#define RST_PIN   21  
#define SS_PIN     5  
#define MISO_PIN  19 
#define MOSI_PIN  23 
#define SCK_PIN   18 

MFRC522 mfrc522(SS_PIN, RST_PIN);

WiFiClient espClient;
PubSubClient client(espClient);

CRGB leds[NUM_LEDS];
bool blinkMode = false;
bool l_occupied = false;
bool l_rfidscanned = false;
CRGB neoColor = CRGB::Black;  // Default color from Neocolor topic

// Function to convert hex color to RGB
CRGB hexToRgb(const String &hex) {
  long number = strtol(hex.substring(1).c_str(), NULL, 16);
  int r = (number >> 16) & 0xFF;
  int g = (number >> 8) & 0xFF;
  int b = number & 0xFF;
  return CRGB(r, g, b);
}

// Function to change the LED strip to a specified color
void setStripColor(CRGB color) {
  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i] = color;
  }
  FastLED.show();
}

// Blink the LEDs in the current neoColor
void blinkStrip() {
  setStripColor(neoColor);
  tone(BUZZER_PIN, 1000);
  delay(500);

  setStripColor(CRGB::Black);
  noTone(BUZZER_PIN);
  delay(500);
}

// MQTT callback function to handle incoming messages
void callback(char* topic, byte* payload, unsigned int length) {
  String message = "";
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("]: ");
  Serial.println(message);

  if (String(topic) == "occupied") {
    if (message == "Yes") {
      setStripColor(CRGB::Red);
      l_occupied = true;
    }
  } else if (String(topic) == "booking") {
    if (message == "Yes") {
      setStripColor(CRGB::Yellow);
    }
  } else if (String(topic) == "Neocolor" && message.charAt(0) == '#' && message.length() == 7) {
    neoColor = hexToRgb(message);
    setStripColor(neoColor);
  } else if (String(topic) == "Blynk") {
    if (message == "Yes") {
      blinkMode = true;
    } else if (message == "No") {
      blinkMode = false;
      setStripColor(neoColor);  // Stop blinking and show NeoColor
    }
  } else if (String(topic) == "buzzer") {
    if (message == "No") {
      noTone(BUZZER_PIN);
    }
  }
}

// Function to publish a message to an MQTT topic
void publishToTopic(const char* topic, const char* message) {
  client.publish(topic, message);
  Serial.print("Published to topic ");
  Serial.print(topic);
  Serial.print(": ");
  Serial.println(message);
}

void setup() {
  Serial.begin(115200);
  while (!Serial);

  WiFi.begin(ssid, password);
  SPI.begin(SCK_PIN, MISO_PIN, MOSI_PIN);
  mfrc522.PCD_Init();

  // Wait for WiFi connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);

  FastLED.addLeds<NEOPIXEL, LED_PIN>(leds, NUM_LEDS).setRgbw(RgbwDefault());
  FastLED.setBrightness(128);
  delay(2000);
}

void loop() {
  if (!client.connected()) {
    while (!client.connected()) {
      if (client.connect("ESP32Client")) {
        client.subscribe("occupied");
        client.subscribe("booking");
        client.subscribe("Neocolor");
        client.subscribe("Blynk");
        client.subscribe("buzzer");
      } else {
        delay(5000);
      }
    }
  }

  client.loop();

  if (blinkMode) {
    blinkStrip();
  }

  if (mfrc522.PICC_IsNewCardPresent() && mfrc522.PICC_ReadCardSerial()) {
    String uidString = "";
    for (byte i = 0; i < mfrc522.uid.size; i++) {
      uidString += String(mfrc522.uid.uidByte[i], HEX);
    }

    setStripColor(CRGB::Green);
    publishToTopic("rfidScanned", "Yes");
    l_rfidscanned = true;

    mfrc522.PICC_HaltA();
  }

  if (!l_rfidscanned && l_occupied) {
    tone(BUZZER_PIN, 1000);
    publishToTopic("buzzer", "Yes");
  }

  if (l_rfidscanned) {
    noTone(BUZZER_PIN);
  }
}
