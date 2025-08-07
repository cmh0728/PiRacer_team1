#include <SPI.h>
#include "mcp2515_can.h"  // MCP2515 library

// Kalman filter
class SimpleKalmanFilter {
private:
  float estimate;
  float errorEstimate;
  float errorMeasure;
  float q;

public:
  SimpleKalmanFilter(float mea_e, float est_e, float q_) {
    errorMeasure = mea_e;
    errorEstimate = est_e;
    q = q_;
    estimate = 0;
  }

  float updateEstimate(float measurement) {
    float kalmanGain = errorEstimate / (errorEstimate + errorMeasure);
    estimate = estimate + kalmanGain * (measurement - estimate);
    errorEstimate = (1.0 - kalmanGain) * errorEstimate + fabs(estimate) * q;
    return estimate;
  }
};

volatile int pulseCount = 0;
unsigned long lastTime = 0;
int rpm = 0;
int zeroCount = 0;  //  

const int SPI_CS_PIN = 9;
mcp2515_can CAN(SPI_CS_PIN);

SimpleKalmanFilter kalman(10, 50, 0.01);

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

  if (currentTime - lastTime >= 100) { // 0.1sec
    noInterrupts();
    int count = pulseCount;
    pulseCount = 0;
    interrupts();

    rpm = count * 3 * 10;  // 0.1sec

    //  0 
    if (rpm == 0) {
      zeroCount++;
    } else {
      zeroCount = 0;
    }

    if (rpm >= 2000){
      rpm = 2000 ;
    }

    // Kalman 
    float filteredRpm = kalman.updateEstimate((float)rpm);

    // 0.3sec
    if (zeroCount >= 3) {  // 0.1sec *5 
      filteredRpm = 0;
    }

    // 안전한 범위 보정
    if (filteredRpm < 20) {
      filteredRpm = 0;

    Serial.print("RPM (raw): ");
    Serial.print(rpm);
    Serial.print(" | RPM (filtered): ");
    Serial.println(filteredRpm);

    // CAN message
    int rpmToSend = (int)filteredRpm;
    byte rpmBytes[2];
    rpmBytes[0] = (rpmToSend >> 8) & 0xFF;
    rpmBytes[1] = rpmToSend & 0xFF;

    byte sendResult = CAN.sendMsgBuf(0x100, 0, 2, rpmBytes);
    if (sendResult == CAN_OK) {
      Serial.println("CAN message success");
    } else {
      Serial.println("CAN message fail");
    }

    lastTime = currentTime;
  }
}
