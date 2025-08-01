#include <SPI.h>
#include "mcp2515_can.h"  // MCP2515 library

volatile int pulseCount = 0;
unsigned long lastTime = 0;
int rpm = 0;
int filteredRpm = 0;  // 이전값 저장

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

    rpm = count * 60 * 10;  // 0.1초

    // 🌟 최대 변화량 제한 방식 적용
    int delta = rpm - filteredRpm;
    int diff  = 30 ;
    if (delta > diff) {
      filteredRpm += diff;
    } else if (delta < -diff) {
      filteredRpm -= diff;
    } else {
      filteredRpm = rpm;
    }

    Serial.print("RPM (raw): ");
    Serial.print(rpm);
    Serial.print(" | RPM (smoothed): ");
    Serial.println(filteredRpm);

    // CAN 메시지 전송
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
