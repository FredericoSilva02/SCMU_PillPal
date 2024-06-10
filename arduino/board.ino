#include <SPI.h>
#include <MFRC522.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include "time.h"

#define WIFI_SSID "SSID"
#define WIFI_PASSWORD "PASS"

#define API_KEY "AIzaSyCKsPgOPz5ux_BTfzvSCcQQS2SneWHIw90"

#define USER_EMAIL "fred@gmail.com"
#define USER_PASSWORD "admin123"

// Firebase configuration
#define FIREBASE_HOST "pillpal-e782d.firebaseio.com"
#define FIREBASE_AUTH "iM4rf9FmpEqLojtsrunC4mh5ozX0IGM6w4aD9cTw"

// Define RealTime DB URL
#define DATABASE_URL "https://pillpal-e782d-default-rtdb.europe-west1.firebasedatabase.app/"

#define RST_PIN         5          // Configurable, see typical pin layout above
#define SS_PIN          21         // Configurable, see typical pin layout above

#define SERVO_PIN1      25         // Updated to GPIO 25
#define SERVO_PIN2      26         // Updated to GPIO 26
#define SERVO_PIN3      27         // Updated to GPIO 27

#define LED_PIN1        12         // LED for Servo 1
#define LED_PIN2        13         // LED for Servo 2
#define LED_PIN3        14         // LED for Servo 3

#define IR_PIN          15         // IR Sensor pin

FirebaseConfig config;
FirebaseData data;
FirebaseAuth auth;
FirebaseJson json;
String uid;

String medicationPath = "/medication";

MFRC522 mfrc522(SS_PIN, RST_PIN);  // Create MFRC522 instance

const byte rfid1[] = {0xF3, 0x99, 0x2D, 0x0D}; // Example RFID tag UID
const byte rfid2[] = {0x23, 0xB5, 0xC9, 0x27}; // Another example RFID tag UID

void initWifi() {
  Serial.println("Trying to connect to the wifi!");
  Wifi.begin (WIFI_SSID, WIFI_PASSWORD);
  while (Wifi.status() != WL_CONNECTED) {
    Serial.println("Waiting");
    delay(1000);
  }
  Serial.Println("Connected successfully to: " + Wifi.localIP());
}

String getLocalTimeString() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time");
    return "";
  }
  char timeStringBuff[6]; // HH:MM
  strftime(timeStringBuff, sizeof(timeStringBuff), "%H:%M", &timeinfo);
  return String(timeStringBuff);
}

int getLocalDayOfWeek() {
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time");
    return -1;
  }
  return timeinfo.tm_wday; // Sunday = 0, Monday = 1, ..., Saturday = 6
}

String getDocumentIdByTube(String tube) {
  String documentId = "";
  String fieldPath = "Tube";
  
  if (Firebase.Firestore.getDocumentsByWhereClause(firebaseData, medicationPath, fieldPath + "==", tube)) {
    FirebaseJson &payload = firebaseData.jsonObject();
    size_t len = payload.iteratorBegin();
    FirebaseJson::IteratorValue value;
    for (size_t i = 0; i < len; i++) {
      value = payload.iteratorGet(i);
      if (value.type == FirebaseJson::JSON_OBJECT) {
        documentId = value.key;
        break; // Assuming we want the first matching document
      }
    }
    payload.iteratorEnd();
  } else {
    Serial.println("Failed to get documents");
    Serial.println(firebaseData.errorReason());
  }
  
  return "/" + documentId;
}

void setup() {
  Serial.begin(115200);   // Initialize serial communications with the PC
  SPI.begin();          // Init SPI bus
  mfrc522.PCD_Init();   // Init MFRC522 card
  Serial.println(F("Scan RFID card"));

  initWifi();

  configTime(0, 0, "pool.ntp.org");

  // Initialize Firebase
  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);

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

  //Setup Firebase DB
  config.api_key = API_KEY;
  Firebase.reconnectWiFi(true);
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  config.database_url = DATABASE_URL;
  config.max_token_generation_retry = 3;
  Firebase.begin(&config, &auth);

  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }
  uid = auth.token.uid;
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

  // Check which RFID was scanned and respond accordingly
  if (compareUID(rfid1, mfrc522.uid.uidByte)) {
    Serial.println(F("RFID 1 recognized."));
    checkAndDispense("A", 0, LED_PIN1);
    checkAndDispense("B", 1, LED_PIN2);
    checkAndDispense("C", 2, LED_PIN3);
  } else if (compareUID(rfid2, mfrc522.uid.uidByte)) {
    Serial.println(F("RFID 2 recognized."));
    checkAndDispense("A", 0, LED_PIN1);
    checkAndDispense("B", 1, LED_PIN2);
    checkAndDispense("C", 2, LED_PIN3);
  } else {
    Serial.println(F("Unknown RFID."));
    printUID(mfrc522.uid.uidByte, mfrc522.uid.size);
  }

  // Halt PICC
  mfrc522.PICC_HaltA();
  // Stop encryption on PCD
  mfrc522.PCD_StopCrypto1();
}

void checkAndDispense(String tube, int servoChannel, int ledPin) {
  String documentPath = medicationPath + getDocumentIdByTube(tube);
  
  // Check if there's a pill to dispense for the current tube
  if (getHasStock(tube)) {
    Serial.println("Pill available in Tube " + tube);

    // Rotate servo to dispense pill
    rotateServo(servoChannel, ledPin, tube);

    // Check if the pill has dropped
    if (!hasPillDropped(servoChannel)) {
      Serial.println("Pill not dropped from Tube " + tube);
      setHasStock(false, documentPath);
    } else {
      Serial.println("Pill successfully dispensed from Tube " + tube);
    }
  } else {
    Serial.println("No pill available in Tube " + tube);
  }
}

bool getHasStock(String tube) {
  if (Firebase.getBool(firebaseData, medicationPath + getDocumentIdByTube(tube) + "/HasStock")) {
    if (firebaseData.dataType() == "boolean") {
      return firebaseData.boolData();
    }
  } else {
    Serial.println("Failed to get HasStock");
    Serial.println(firebaseData.errorReason());
  }
  return false;
}

void setHasStock(bool hasStock, string path) {
  if (Firebase.setBool(firebaseData, path + "/HasStock", hasStock)) {
    Serial.println("HasStock value set successfully");
  } else {
    Serial.println("Failed to set HasStock");
    Serial.println(firebaseData.errorReason());
  }
}

void getSchedule(String tube) {
  if (Firebase.getBool(firebaseData, medicationPath + getDocumentIdByTube(tube) + "/HasStock")) {
    if (firebaseData.dataType() == "boolean") {
      return firebaseData.boolData();
    }
  } else {
    Serial.println("Failed to get HasStock");
    Serial.println(firebaseData.errorReason());
  }
  return false;
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
    Serial.println("is out of stock!");
  }
}

bool checkStock() {
  Serial.println("Checking stock...");
  unsigned long startTime = millis();
  while (millis() - startTime < 500) { // Check for 500 milliseconds
    if (digitalRead(IR_PIN) == LOW) { // Assuming LOW means detection
      Serial.println("DETECTED");
      return true; // Stock available
    }
  }

  Serial.println("DIDNT DETECT");
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

bool isWithinTimeWindow(String currentTime, String reminderTime, int windowMinutes = 30) {
  int currentHour = currentTime.substring(0, 2).toInt();
  int currentMinute = currentTime.substring(3, 5).toInt();
  int reminderHour = reminderTime.substring(0, 2).toInt();
  int reminderMinute = reminderTime.substring(3, 5).toInt();

  int currentTotalMinutes = currentHour * 60 + currentMinute;
  int reminderTotalMinutes = reminderHour * 60 + reminderMinute;

  return abs(currentTotalMinutes - reminderTotalMinutes) <= windowMinutes;
}

bool hasPillToTakeNow(String documentPath) {
  if (Firebase.getDocument(firebaseData, documentPath)) {
    FirebaseJson &json = firebaseData.jsonObject();
    String reminders, days;
    
    // Get Reminders
    if (json.get(reminders, "Reminders")) {
      FirebaseJsonArray reminderArray;
      reminders.to<FirebaseJsonArray>(reminderArray);
      
      // Get Days
      if (json.get(days, "Days")) {
        FirebaseJsonArray daysArray;
        days.to<FirebaseJsonArray>(daysArray);
        
        // Get current time and day
        String currentTime = getLocalTimeString();
        int currentDay = getLocalDayOfWeek();
        
        // Check if current day is in Days list
        for (size_t i = 0; i < daysArray.size(); i++) {
          int day;
          daysArray.get(i, day);
          if (day == currentDay) {
            // Check if current time is within the window of any Reminders
            for (size_t j = 0; j < reminderArray.size(); j++) {
              String reminderTime;
              reminderArray.get(j, reminderTime);
              if (isWithinTimeWindow(currentTime, reminderTime)) {
                return true;
              }
            }
          }
        }
      }
    }
  } else {
    Serial.println("Failed to get document");
    Serial.println(firebaseData.errorReason());
  }
  return false;
}
