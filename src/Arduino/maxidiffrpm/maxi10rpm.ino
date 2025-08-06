#include <SPI.h>
#include "mcp2515_can.h"  // MCP2515 library

volatile int pulseCount = 0;
unsigned long lastTime = 0;
int rpm = 0;
int filteredRpm = 0;  // prev_data

const int SPI_CS_PIN = 9;
mcp2515_can CAN(SPI_CS_PIN);

void countPulse() {
  pulseCount++;
}

void setup() {
  Serial.begin(9600);

  while (CAN.begin(CAN_500KBPS) != CAN_OK) {
    Serial.println("CAN retry...");
    delay(100);
  }
  Serial.println("CAN init success");

  pinMode(3, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(3), countPulse, FALLING);
}

void loop() {
  unsigned long currentTime = millis();

  if (currentTime - lastTime >= 100) { // 0.1
    noInterrupts();
    int count = pulseCount;
    pulseCount = 0;
    interrupts();

    rpm = count * 60 * 10;  // 0.1sec

    
    int delta = rpm - filteredRpm; //filter
    int diff  = 20 ;
    if (delta > diff) {
      filteredRpm += diff;
    } else if (delta < -diff) {
      filteredRpm -= diff;
    } else {
      filteredRpm = rpm;
    }

    if (rpm ==0) {
      filteredRpm  = 0;
    }

    Serial.print("RPM (raw): ");
    Serial.print(rpm);
    Serial.print(" | RPM (smoothed): ");
    Serial.println(filteredRpm);

    // CAN 
    byte rpmBytes[2];
    rpmBytes[0] = (filteredRpm >> 8) & 0xFF;
    rpmBytes[1] = filteredRpm & 0xFF;

    byte sendResult = CAN.sendMsgBuf(0x100, 0, 2, rpmBytes);
    if (sendResult == CAN_OK) {
      Serial.println("CAN message success");
    } else {
      Serial.println("CAN message fail");
    }

    lastTime = currentTime;
  }
}

