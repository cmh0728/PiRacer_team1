#include <SPI.h>
#include <mcp_can.h>

// -----------------------------
// 전역 변수 및 상수
// -----------------------------
volatile int pulseCount = 0;           // 펄스 카운터
unsigned long lastTime = 0;            // 마지막 측정 시간
int rpm = 0;

const int SPI_CS_PIN = 9;               
MCP_CAN CAN(SPI_CS_PIN);                


void countPulse() {
  pulseCount++;
}




void setup() {
  Serial.begin(9600);
  
  while (CAN_OK != CAN.begin(MCP_STDEXT, CAN_500KBPS, MCP_8MHZ)) {
    Serial.println("CAN retry..");
    delay(100);
  }
  Serial.println("CAN success");

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
      Serial.println("CAN  message success");
    } else {
      Serial.println("CAN message fail");
    }

    lastTime = currentTime;
  }
}
