#include "SPI.h"
#include "Util.h"

GPULib *GPU;
InputLib *Input;
unsigned long lastDrawReady;
bool running;
bool b_helper = true;
bool done = false;
bool first = true;
bool readyfornext = false;
Program *currentProgram; 
Program *pDemo;
Program *pInputTester;
Program *pPong;
Program *pIntroduction;
Program **programs[NUM_PROGRAMS] = {&pDemo, &pInputTester, &pPong, &pIntroduction};
Program *pMenu;
unsigned long lastFrame;
unsigned long currentFrame;
unsigned long frameTime;
unsigned long lastBlinkTime = 0;

void setup()
{
	GPU = new GPULib();
	Input = new InputLib();
	SPI.setBitOrder(MSBFIRST);
	SPI.setClockDivider(SPI_CLOCK_DIV16);
	SPI.setDataMode(SPI_MODE0);
	SPI.begin();
	Serial.begin(115200);
	running = true;
	pinMode(LED_BUILTIN, OUTPUT);

	pinMode(INT_READY_PIN,INPUT);
	
	randomSeed(analogRead(0));

	pInputTester = new InputTester(GPU, Input);
	pDemo = new Demo(GPU, Input);
	pPong = new Pong(GPU, Input);
	pIntroduction = new Introduction(GPU, Input);
	pMenu = new Menu(GPU, Input, &currentProgram, programs);
	
	currentProgram = pMenu;

	Serial.println("Setup Complete!");
}

void loop()
{	
	if (running)
	{
		readyfornext = digitalRead(INT_READY_PIN)==HIGH;
		if(first && readyfornext){	
			GPU->cleanUp();
			GPU->loadSprites(sprites_font6x8_set,95,&readyfornext);
			first = false;
		}

		if(!first){			
			if(readyfornext && GPU->queueHead != NULL && !GPU->sending){
				readyfornext = false;
				GPU->sendNextInstruction();			
			}		
			if(done || GPU->queueHead == NULL){
				//Serial.println(freeMemory());
				if(Input->areAllButtonsPressed()){
					currentProgram->reset();
					currentProgram->stop();
					currentProgram = pMenu;
				}
				currentFrame = micros();
				frameTime = currentFrame-lastFrame;			
				lastFrame = currentFrame;
				//delayMicroseconds(10);
				currentProgram->tick(frameTime);
				done = false;			
			}
			if(currentProgram == pIntroduction || currentProgram == pMenu){
				Input->tick(INPUT_TIMEOUT);
			} else {
				Input->tick(INPUT_TIMEOUT_INGAME);
			}
			if(lastBlinkTime+250<millis()){
				b_helper = !b_helper;
				digitalWrite(LED_BUILTIN, b_helper);
				//delay(100);	
				lastBlinkTime = millis();
			}
		}		
	} else {
		b_helper = !b_helper;
		digitalWrite(LED_BUILTIN, b_helper);
		delay(1000);	
	}
}
