#include <FastLED.h>
#include <WiFi.h>
#include <SPI.h>
#include <MFRC522.h>
#include <PubSubClient.h>

const char *ssid = "Hi";
const char *password = "Hello123";
#define NUM_LEDS 144
#define BUZZER_PIN 4 
#define LED_PIN   22
#define RST_PIN   21  
#define SS_PIN     5  
#define MISO_PIN  19 
#define MOSI_PIN  23 
#define SCK_PIN   18 

MFRC522 mfrc522(SS_PIN, RST_PIN);

const char* mqtt_server = "broker.hivemq.com";  // You can use any public broker or your own
const int mqtt_port = 1883;

WiFiClient espClient;
PubSubClient client(espClient);

CRGB leds[NUM_LEDS];
bool blinkMode = false;  // Global flag to enable/disable blink mode

// Function to convert hex color to RGB
CRGB hexToRgb(const String &hex) {
  long number = strtol(hex.substring(1).c_str(), NULL, 16);  // Convert hex string to long integer
  int r = (number >> 16) & 0xFF;  // Extract red component
  int g = (number >> 8) & 0xFF;   // Extract green component
  int b = number & 0xFF;          // Extract blue component
  return CRGB(r, g, b);           // Return CRGB object with RGB values
}


// Blink the LEDs red
void blinkRed() {
  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i] = CRGB::Red;  // Set all LEDs to red
  }
  FastLED.show();
  tone(BUZZER_PIN, 1000);
  delay(500);

  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i] = CRGB::Black;  // Turn off all LEDs
  }
  FastLED.show();
  noTone(BUZZER_PIN);
  delay(500);
}

// MQTT callback function to handle incoming messages
void callback(char* topic, byte* payload, unsigned int length) {
  String message = "";

  // Convert the payload into a string
  for (int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  // Print the received message
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("]: ");
  Serial.println(message);

  // Check if the message is "blink"
  if (message == "blink") {
    blinkMode = true;  // Enable blink mode
  } 
  // If it's a hex color code, change the LED color
  else if (message.charAt(0) == '#' && message.length() == 7) {  // #RRGGBB format
    blinkMode = false;  // Disable blink mode if a new color is received
    CRGB color = hexToRgb(message);  // Convert hex to RGB
    for (int i = 0; i < NUM_LEDS; i++) {
      leds[i] = color;  // Set all LEDs to the received color
    }
    FastLED.show();  // Display the new color on the LED strip
  } else {
    Serial.println("Invalid message. Expected #RRGGBB or 'blink'.");
  }
}

// Function to publish the UID as a string to an MQTT topic
void publishUID(String uidString) {
  const char* topic = "rfid/uid";  // Define the MQTT topic for the UID
  client.publish(topic, uidString.c_str());  // Publish the UID string to the topic
  Serial.print("Published UID: ");
  Serial.println(uidString);
}

void setup() {
  Serial.begin(115200);
  while (!Serial);

  WiFi.begin(ssid, password);
  SPI.begin(SCK_PIN, MISO_PIN, MOSI_PIN);  // Init SPI bus
  mfrc522.PCD_Init();

  // Wait for WiFi connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);  // Set the MQTT callback function

  FastLED.addLeds<NEOPIXEL, LED_PIN>(leds, NUM_LEDS).setRgbw(RgbwDefault());
  FastLED.setBrightness(128);  // Set brightness to 50%
  delay(2000);  // Small delay before we start
}

void loop() {
  // Ensure we're connected to the MQTT broker
  if (!client.connected()) {
    while (!client.connected()) {
      if (client.connect("ESP32Client")) {
        client.subscribe("led/color");  // Subscribe to a topic for color updates
      } else {
        delay(5000);  // Try again every 5 seconds if connection fails
      }
    }
  }

  client.loop();  // Process incoming MQTT messages

  // Handle blinking if blinkMode is enabled
  if (blinkMode) {
    blinkRed();
  }

  // Check if a new RFID card is present
  if (mfrc522.PICC_IsNewCardPresent() && mfrc522.PICC_ReadCardSerial()) {
    // Convert the UID to a string
    String uidString = "";
    for (byte i = 0; i < mfrc522.uid.size; i++) {
      uidString += String(mfrc522.uid.uidByte[i], HEX);  // Convert each byte to HEX and append to string
    }
    
    // Publish the UID to the MQTT topic
    publishUID(uidString);

    // Halt the card (prevents multiple reads from the same card)
    mfrc522.PICC_HaltA();
  }
}
