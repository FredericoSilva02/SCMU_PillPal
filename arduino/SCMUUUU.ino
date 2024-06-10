#include <SPI.h>
#include <MFRC522.h>

#define RST_PIN         5          // Configurable, see typical pin layout above
#define SS_PIN          21         // Configurable, see typical pin layout above

#define SERVO_PIN1      25         // Updated to GPIO 25
#define SERVO_PIN2      26         // Updated to GPIO 26
#define SERVO_PIN3      27         // Updated to GPIO 27

#define LED_PIN1        12         // LED for Servo 1
#define LED_PIN2        13         // LED for Servo 2
#define LED_PIN3        14         // LED for Servo 3

#define IR_PIN          15         // IR Sensor pin

MFRC522 mfrc522(SS_PIN, RST_PIN);  // Create MFRC522 instance

const byte rfid1[] = {0xF3, 0x99, 0x2D, 0x0D}; // Example RFID tag UID
const byte rfid2[] = {0x23, 0xB5, 0xC9, 0x27}; // Another example RFID tag UID

void setup() {
  Serial.begin(115200);   // Initialize serial communications with the PC
  SPI.begin();          // Init SPI bus
  mfrc522.PCD_Init();   // Init MFRC522 card
  Serial.println(F("Scan RFID card"));

  // Setup servos
  ledcSetup(0, 50, 16); // Channel 0, 50 Hz, 16-bit resolution
  ledcAttachPin(SERVO_PIN1, 0); // Attach pin 25 to channel 0
  ledcSetup(1, 50, 16); // Channel 1, 50 Hz, 16-bit resolution
  ledcAttachPin(SERVO_PIN2, 1); // Attach pin 26 to channel 1
  ledcSetup(2, 50, 16); // Channel 2, 50 Hz, 16-bit resolution
  ledcAttachPin(SERVO_PIN3, 2); // Attach pin 27 to channel 2

  // Setup LEDs
  pinMode(LED_PIN1, OUTPUT);
  pinMode(LED_PIN2, OUTPUT);
  pinMode(LED_PIN3, OUTPUT);

  // Setup IR sensor
  pinMode(IR_PIN, INPUT);
}

void loop() {
  // Look for new cards
  if (!mfrc522.PICC_IsNewCardPresent()) {
    return;
  }

  // Select one of the cards
  if (!mfrc522.PICC_ReadCardSerial()) {
    return;
  }

  // Show some details of the PICC (that is: the tag/card)
  Serial.print(F("Card UID:"));
  for (byte i = 0; i < mfrc522.uid.size; i++) {
    Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
    Serial.print(mfrc522.uid.uidByte[i], HEX);
  }
  Serial.println();

  if (compareUID(rfid1, mfrc522.uid.uidByte)) {
    Serial.println(F("RFID 1 recognized."));
    rotateServo(0, LED_PIN1, "Tube 1"); // Rotate servo on channel 0 (SERVO_PIN1) and turn on LED1
    rotateServo(2, LED_PIN3, "Tube 1"); // Rotate servo on channel 0 (SERVO_PIN1) and turn on LED1

  } else if (compareUID(rfid2, mfrc522.uid.uidByte)) {
    Serial.println(F("RFID 2 recognized."));
    rotateServo(1, LED_PIN2, "Tube 2"); // Rotate servo on channel 1 (SERVO_PIN2) and turn on LED2
  } else {
    Serial.println(F("Unknown RFID."));
    printUID(mfrc522.uid.uidByte, mfrc522.uid.size);
  }

  // Halt PICC
  mfrc522.PICC_HaltA();
  // Stop encryption on PCD
  mfrc522.PCD_StopCrypto1();
}

bool compareUID(const byte *tag, byte *uid) {
  for (byte i = 0; i < 4; i++) {
    if (tag[i] != uid[i]) {
      return false;
    }
  }
  return true;
}

void rotateServo(int channel, int ledPin, const char* tubeName) {
    Serial.print("Channel: ");
  Serial.println(channel);
  Serial.print("Led: ");
  Serial.println(ledPin);

  digitalWrite(ledPin, HIGH); // Turn on the LED
  for (int pos = 0; pos <= 180; pos += 1) {
    int dutyCycle = map(pos, 0, 180, 500, 2400);
    int dutyCycle16Bit = dutyCycle * 65536 / 20000;
    ledcWrite(channel, dutyCycle16Bit);
    delay(10);
  }
  for (int pos = 180; pos >= 0; pos -= 1) {
    int dutyCycle = map(pos, 0, 180, 500, 2400);
    int dutyCycle16Bit = dutyCycle * 65536 / 20000;
    ledcWrite(channel, dutyCycle16Bit);
    delay(10);
  }
  digitalWrite(ledPin, LOW); // Turn off the LED

  // Check stock after rotation
  if (!checkStock()) {
    Serial.print(tubeName);
    Serial.println(" is out of stock!");
  }
}

bool checkStock() {
  Serial.println("Checking stock...");
  unsigned long startTime = millis();
  while (millis() - startTime < 500) { // Check for 500 milliseconds
    if (digitalRead(IR_PIN) == LOW) { // Assuming LOW means detection
      Serial.println("DETETOIII");
      return true; // Stock available
    }
  }

  Serial.println("NUM DJITETOOUUU");
  return false; // No stock detected within the time frame
}

void printUID(byte *uid, byte length) {
  Serial.print(F("UID:"));
  for (byte i = 0; i < length; i++) {
    Serial.print(uid[i] < 0x10 ? " 0" : " ");
    Serial.print(uid[i], HEX);
  }
  Serial.println();
}
