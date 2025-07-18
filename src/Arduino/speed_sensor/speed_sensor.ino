volatile int pulseCount = 0;

void setup() {
  Serial.begin(9600);
  pinMode(3, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(3), countPulse, CHANGE);
}

void loop() {
  static unsigned long lastTime = 0;
  unsigned long now = millis();

  if (now - lastTime >= 500) {
    Serial.print("펄스 수: ");
    Serial.println(pulseCount);
    pulseCount = 0;
    lastTime = now;
  }
}

void countPulse() {
  pulseCount++;
}
