#include <SPI.h>
#include <MFRC522.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include "time.h"

#define WIFI_SSID "OpenFCT"
#define WIFI_PASSWORD ""

#define API_KEY "AIzaSyCKsPgOPz5ux_BTfzvSCcQQS2SneWHIw90"

// Firebase configuration
#define FIREBASE_HOST "pillpal-e782d.firebaseio.com"
#define FIREBASE_AUTH "iM4rf9FmpEqLojtsrunC4mh5ozX0IGM6w4aD9cTw"

// Define RealTime DB URL
#define DATABASE_URL "https://pillpal-e782d-default-rtdb.europe-west1.firebasedatabase.app/"

#define RST_PIN 5
#define SS_PIN 21

#define SERVO_PIN1 27
#define SERVO_PIN2 26
#define SERVO_PIN3 25

#define LED_PIN1 12 // LED for Servo 1
#define LED_PIN2 13 // LED for Servo 2
#define LED_PIN3 14 // LED for Servo 3

#define IR_PIN 15 // IR Sensor pin

FirebaseConfig config;
FirebaseData firebaseData;
FirebaseAuth auth;

bool detect;
String uid;
String usersPath = "/users";
String medicationPath = "/medications";

MFRC522 mfrc522(SS_PIN, RST_PIN);

void setup()
{
  Serial.begin(115200);
  SPI.begin();
  mfrc522.PCD_Init();
  initWifi();

  detect = false;

  configTime(0, 0, "pool.ntp.org");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Setup servos
  ledcSetup(0, 50, 16);
  ledcAttachPin(SERVO_PIN1, 0);
  ledcSetup(1, 50, 16);
  ledcAttachPin(SERVO_PIN2, 1);
  ledcSetup(2, 50, 16);
  ledcAttachPin(SERVO_PIN3, 2);

  // Setup LEDs
  pinMode(LED_PIN1, OUTPUT);
  pinMode(LED_PIN2, OUTPUT);
  pinMode(LED_PIN3, OUTPUT);

  // Setup IR sensor
  pinMode(IR_PIN, INPUT);

  Serial.println(F("Scan RFID card"));
}

void loop()
{
  // Look for new cards
  if (!mfrc522.PICC_IsNewCardPresent())
  {
    return;
  }

  // Select one of the cards
  if (!mfrc522.PICC_ReadCardSerial())
  {
    return;
  }

  // Show some details of the PICC (that is: the tag/card)
  String rfidUid = "";
  for (byte i = 0; i < mfrc522.uid.size; i++)
  {
    rfidUid += String(mfrc522.uid.uidByte[i], HEX);
  }
  rfidUid.toUpperCase();

  Serial.print("Card UID:");
  Serial.println(rfidUid);

  // Check the UID against Firebase users
  if (Firebase.getJSON(firebaseData, usersPath))
  {
    FirebaseJson &usersJson = firebaseData.jsonObject();
    FirebaseJsonData userData;

    size_t userCount = usersJson.iteratorBegin();
    for (size_t i = 0; i < userCount; i++)
    {
      String userKey, userVal;
      int userType;
      usersJson.iteratorGet(i, userType, userKey, userVal);

      usersJson.get(userData, userKey + "/rfid");
      if (userData.stringValue == rfidUid)
      {
        Serial.println("RFID recognized for user: " + userKey);
        dispenseMedication(userKey);
        break;
      }
    }
    usersJson.iteratorEnd();
  }
  else
  {
    Serial.println("Failed to get user data from Firebase");
    Serial.println(firebaseData.errorReason());
  }

  mfrc522.PICC_HaltA();
  mfrc522.PCD_StopCrypto1();
}

void initWifi()
{
  Serial.println("Trying to connect to the WiFi!");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.println("Waiting...");
    delay(1000);
  }
  Serial.println("Connected successfully to: " + WiFi.localIP());
}

String getLocalTimeString()
{
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo))
  {
    Serial.println("Failed to obtain time");
    return "";
  }
  char timeStringBuff[6]; // HH:MM
  strftime(timeStringBuff, sizeof(timeStringBuff), "%H:%M", &timeinfo);
  return String(timeStringBuff);
}

int getLocalDayOfWeek()
{
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo))
  {
    Serial.println("Failed to obtain time");
    return -1;
  }
  // Adjust to make Monday = 0, ..., Sunday = 6
  return (timeinfo.tm_wday + 6) % 7;
}

void dispenseMedication(String userKey)
{
  if (Firebase.getJSON(firebaseData, medicationPath))
  {
    FirebaseJson &medicationsJson = firebaseData.jsonObject();
    FirebaseJsonData medicationData;

    size_t medicationCount = medicationsJson.iteratorBegin();
    for (size_t i = 0; i < medicationCount; i++)
    {
      String medicationKey, medicationVal;
      int medicationType;
      medicationsJson.iteratorGet(i, medicationType, medicationKey, medicationVal);

      medicationsJson.get(medicationData, medicationKey + "/UserId");
      if (medicationData.stringValue == userKey)
      {
        String tube;
        medicationsJson.get(medicationData, medicationKey + "/Tube");
        tube = medicationData.stringValue;
        int servoChannel = getServoChannel(tube);
        if (hasPillToTakeNow(medicationPath + "/" + medicationKey))
        {
          rotateServo(servoChannel, getLEDPin(servoChannel), medicationKey.c_str(), medicationPath + "/" + medicationKey);
        }
      }
    }
    medicationsJson.iteratorEnd();
  }
  else
  {
    Serial.println("Failed to get medication data from Firebase");
    Serial.println(firebaseData.errorReason());
  }
}

int getServoChannel(String tube)
{
  if (tube == "A")
    return 0;
  if (tube == "B")
    return 1;
  if (tube == "C")
    return 2;
  return -1;
}

int getLEDPin(int servoChannel)
{
  switch (servoChannel)
  {
  case 0:
    return LED_PIN1;
  case 1:
    return LED_PIN2;
  case 2:
    return LED_PIN3;
  default:
    return -1;
  }
}

bool getHasStock(String path)
{
  if (Firebase.getBool(firebaseData, path + "/HasStock"))
  {
    if (firebaseData.dataType() == "boolean")
    {
      return firebaseData.boolData();
    }
  }
  else
  {
    Serial.println("Failed to get HasStock");
    Serial.println(firebaseData.errorReason());
  }
  return false;
}

void setHasStock(bool hasStock, String path)
{
  if (Firebase.setBool(firebaseData, path + "/HasStock", hasStock))
  {
    Serial.println("HasStock value set successfully");
  }
  else
  {
    Serial.println("Failed to set HasStock");
    Serial.println(firebaseData.errorReason());
  }
}

void rotateServo(int channel, int ledPin, const char *tubeName, String path)
{
  detect = false;
  digitalWrite(ledPin, HIGH); // Turn on the LED
  unsigned long startTime = millis();
  for (int pos = 0; pos <= 180; pos += 1)
  {
    int dutyCycle = map(pos, 0, 180, 500, 2400);
    int dutyCycle16Bit = dutyCycle * 65536 / 20000;
    ledcWrite(channel, dutyCycle16Bit);
    delay(10);

    // Check stock every step
    if (!checkStockDuringRotation())
    {
      Serial.print(tubeName);
      Serial.println(" is out of stock!");
    }
    else
    {
      detect = true;
      Serial.println("DETECTED");
    }
  }
  for (int pos = 180; pos >= 0; pos -= 1)
  {
    int dutyCycle = map(pos, 0, 180, 500, 2400);
    int dutyCycle16Bit = dutyCycle * 65536 / 20000;
    ledcWrite(channel, dutyCycle16Bit);
    delay(10);

    // Check stock every step
    if (!checkStockDuringRotation())
    {
      Serial.print(tubeName);
      Serial.println(" is out of stock!");
    }
    else
    {
      detect = true;
      Serial.println("DETECTED");
    }
  }
  digitalWrite(ledPin, LOW); // Turn off the LED

  // Ensure there is a delay before the next servo starts rotating
  while (millis() - startTime < 5000)
  {
    delay(10); // Wait for a short interval
  }

  if (!detect)
  {
    setHasStock(false, path);
  }
}

bool checkStockDuringRotation()
{
  if (digitalRead(IR_PIN) == LOW)
  {              // Assuming LOW means detection
    return true; // Stock available
  }
  return false; // No stock detected
}

bool checkStock()
{
  Serial.println("Checking stock...");
  unsigned long startTime = millis();
  while (millis() - startTime < 500)
  { // Check for 500 milliseconds
    if (digitalRead(IR_PIN) == LOW)
    { // Assuming LOW means detection
      Serial.println("Stock detected.");
      return true; // Stock available
    }
  }
  Serial.println("No stock detected.");
  return false; // No stock detected within the time frame
}

void printUID(byte *uid, byte length)
{
  Serial.print(F("UID:"));
  for (byte i = 0; i < length; i++)
  {
    Serial.print(uid[i] < 0x10 ? " 0" : " ");
    Serial.print(uid[i], HEX);
  }
  Serial.println();
}

bool isWithinTimeWindow(String currentTime, String reminderTime, int windowMinutes = 30)
{
  int currentHour = currentTime.substring(0, 2).toInt();
  int currentMinute = currentTime.substring(3, 5).toInt();
  int reminderHour = reminderTime.substring(0, 2).toInt();
  int reminderMinute = reminderTime.substring(3, 5).toInt();

  int currentTotalMinutes = currentHour * 60 + currentMinute;
  int reminderTotalMinutes = reminderHour * 60 + reminderMinute;

  return abs(currentTotalMinutes - reminderTotalMinutes) <= windowMinutes;
}

bool hasPillToTakeNow(String documentPath)
{
  if (Firebase.getJSON(firebaseData, documentPath))
  {
    FirebaseJson &json = firebaseData.jsonObject();
    FirebaseJsonData jsonData;
    FirebaseJsonArray remindersArray;
    FirebaseJsonArray daysArray;

    // Get Reminders
    if (json.get(jsonData, "Reminders"))
    {
      jsonData.getArray(remindersArray);
    }

    // Get Days
    if (json.get(jsonData, "Days"))
    {
      jsonData.getArray(daysArray);
    }

    // Get current time and day
    String currentTime = getLocalTimeString();
    int currentDay = getLocalDayOfWeek();

    // Check if current day is in Days list
    for (size_t i = 0; i < daysArray.size(); i++)
    {
      jsonData.clear();
      daysArray.get(jsonData, i);
      int day = jsonData.intValue;
      if (day == currentDay)
      {
        // Check if current time is within the window of any Reminders
        for (size_t j = 0; j < remindersArray.size(); j++)
        {
          jsonData.clear();
          remindersArray.get(jsonData, j);
          String reminderTime = jsonData.stringValue;
          if (isWithinTimeWindow(currentTime, reminderTime))
          {
            return true;
          }
        }
      }
    }
  }
  else
  {
    Serial.println("Failed to get document");
    Serial.println(firebaseData.errorReason());
  }
  return false;
}
