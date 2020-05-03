#include <SoftwareSerial.h>

SoftwareSerial btSerial(2, 3);

int sensorPin = 0;
int pulseRX = 0;
int pulseTX = 0;

void setup()
{
  Serial.begin(9600);
  btSerial.begin(9600);
}

void loop()
{
  pulseRX = analogRead(sensorPin);
  pulseTX = map(pulseRX, 0, 1023, 0, 220);

  Serial.println(pulseTX);
  btSerial.println(pulseTX);

  delay(500);
}
