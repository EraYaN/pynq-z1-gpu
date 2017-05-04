#include "SPI.h"
void drawReady();
unsigned long lastDrawReady;
bool running;
bool b_helper = true;
bool done = false;
bool first = true;
bool readyfornext = false;
unsigned long lastFrame;
unsigned long currentFrame;
unsigned long frameTime;
unsigned long lastBlinkTime = 0;
unsigned int count = 0;
unsigned int x = 0;
unsigned int y = 0;
bool new_frame = false;
bool fill_first = true;
void setup()
{
  //attachInterrupt(2, drawReady, RISING);	
  SPI.setBitOrder(MSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV64);
  SPI.setDataMode(SPI_MODE0);
  SPI.begin();
  Serial.begin(115200);
  running = true;
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.println("Setup Complete!");	
  randomSeed(analogRead(0));	
}

void loop()
{
  if (running)
  {    
    if(digitalRead(2)==HIGH){
      if(new_frame){
        delayMicroseconds(500);
        SPI.transfer((byte)0);
        new_frame = false;
        //Serial.println("New Frame!");
         delayMicroseconds(20000);
      } else if(fill_first){
        delayMicroseconds(500);
        SPI.transfer((byte)1);
        delayMicroseconds(500);
        SPI.transfer(B110000);
        fill_first = false;
        ////Serial.println("Fill!");
        delayMicroseconds(20000);
      } else {
        SPI.transfer((byte)2);
        SPI.transfer(B001100);
        x++;
        if(x>159){
          x=0;
          y++;
          if(y>119){
          y=0;          
            new_frame=true;
            fill_first=true;
          }
        }
        SPI.transfer((byte)x);
        SPI.transfer((byte)y);
        //Serial.print("Draw pixel: ");
        //Serial.print(x);
        //Serial.print("; ");      
        //Serial.println(y);
        //delay(500);		
      }	
    }
    
    if(lastBlinkTime+250<millis()){
      b_helper = !b_helper;
      digitalWrite(LED_BUILTIN, b_helper);
      //delay(100);	
      lastBlinkTime = millis();     
      //Serial.println("Ready for next!");
    }
    
   } else {
    b_helper = !b_helper;
    digitalWrite(LED_BUILTIN, b_helper);
    delay(1000);	
  }
}



