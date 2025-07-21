#include <SPI.h>
#include "mcp2515_can.h"  // MCP2515 library


volatile int pulseCount = 0;           // pulse
unsigned long lastTime = 0;            
int rpm = 0;

const int SPI_CS_PIN = 9;
mcp2515_can CAN(SPI_CS_PIN);  

void countPulse() {
  pulseCount++;
}

void setup() {
  Serial.begin(9600);

  // MCP2515  () 500kbps + 16MHz)
  while (CAN.begin(CAN_500KBPS) != CAN_OK) {
    Serial.println("CAN retry...");
    delay(100);
  }
  Serial.println("CAN init success");

  pinMode(3, INPUT_PULLUP); // D3 pin
  attachInterrupt(digitalPinToInterrupt(3), countPulse, FALLING);
}

void loop() {
  unsigned long currentTime = millis();

  if (currentTime - lastTime >= 1000) {
    noInterrupts();
    int count = pulseCount;
    pulseCount = 0;
    interrupts();

    rpm = count * 60;

    Serial.print("RPM: ");
    Serial.println(rpm);

    byte rpmBytes[2];
    rpmBytes[0] = (rpm >> 8) & 0xFF;
    rpmBytes[1] = rpm & 0xFF;

    byte sendResult = CAN.sendMsgBuf(0x100, 0, 2, rpmBytes);
    if (sendResult == CAN_OK) {
      Serial.println("CAN message success");
    } else {
      Serial.println("CAN message fail");
    }

    lastTime = currentTime;
  }
}
