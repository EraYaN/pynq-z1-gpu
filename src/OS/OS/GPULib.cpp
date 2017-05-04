// Class for controlling a SoG-based GPU chip
// EPO3-1 - TU Delft

#include "Util.h"

GPULib::GPULib()
{
	queueHead = NULL;
	queueTail = NULL;
	sending = false;
	nextSpriteID = 0;
}

GPULib::~GPULib()
{
	cleanUp();
}

void GPULib::clearQueue()
{
	while(queueHead != NULL)
		shiftQueue();

	queueHead = NULL;
	queueTail = NULL;
}

void GPULib::cleanUp()
{
	clearQueue();
}

void GPULib::transferQueue()
{
	if (queueHead != NULL)
		sendNextInstruction();
}

void GPULib::sendNextInstruction()
{
	if (queueHead == NULL) return;
	sending = true;
	/*unsigned long time = micros();
	while(micros()<time+500){
		//wait
	}*/
	for (int j=0; j<(queueHead->numPackets); j++)
	{	
		/*Serial.print("Sent byte: ");
		Serial.print(queueHead->packets[j],BIN);
		Serial.print("; ");
		Serial.print(j+1);
		Serial.print(" of ");
		Serial.print(queueHead->numPackets);
		Serial.print(" @ 0x");
		Serial.println((unsigned int)queueHead, HEX);
		Serial.flush();*/
		SPI.transfer(queueHead->packets[j]);		
	}
	shiftQueue();
	sending = false;
}

void GPULib::appendInstructionToQueue(Instruction *instruction)
{
	queueTail->nextInstruction = instruction;
	queueTail = instruction;
	queueTail->nextInstruction = NULL;

	if (queueHead == NULL)
		queueHead = instruction;
}

void GPULib::shiftQueue()
{
	Instruction *tmp = queueHead;
	queueHead = queueHead->nextInstruction;
	delete tmp;
}

void GPULib::switchScreenBuffer()
{
	Instruction *instr = new Instruction(1);
	instr->packets[0] = 0;
	appendInstructionToQueue(instr);
}

void GPULib::drawFill(byte color)
{
	Instruction *instr = new Instruction(2);
	instr->packets[0] = 1;
	instr->packets[1] = color;
	appendInstructionToQueue(instr);
	//drawFilledRect(0, 0, XMAX, YMAX, color);	
}

void GPULib::drawPixel(byte x, byte y, byte color)
{
	Instruction *instr = new Instruction(4);
	instr->packets[0] = 2;
	instr->packets[1] = color;
	instr->packets[2] = clamp(x,0,XMAX);
	instr->packets[3] = clamp(y,0,YMAX);
	appendInstructionToQueue(instr);
}

void GPULib::drawRect(byte x0, byte y0, byte x1, byte y1, byte color)
{
	Instruction *instr = new Instruction(6);
	instr->packets[0] = 3;
	instr->packets[1] = color;
	instr->packets[2] = clamp(x0,0,XMAX);
	instr->packets[3] = clamp(y0,0,YMAX);
	instr->packets[4] = clamp(x1,0,XMAX);
	instr->packets[5] = clamp(y1,0,YMAX);
	appendInstructionToQueue(instr);
}

void GPULib::drawFilledRect(byte x0, byte y0, byte x1, byte y1, byte color)
{
	Instruction *instr = new Instruction(6);
	instr->packets[0] = 4;
	instr->packets[1] = color;
	instr->packets[2] = clamp(x0,0,XMAX);
	instr->packets[3] = clamp(y0,0,YMAX);
	instr->packets[4] = clamp(x1,0,XMAX);
	instr->packets[5] = clamp(y1,0,YMAX);
	appendInstructionToQueue(instr);
}

void GPULib::drawLine(byte x0, byte y0, byte x1, byte y1, byte color)
{
	Instruction *instr = new Instruction(6);
	instr->packets[0] = 5;
	instr->packets[1] = color;
	instr->packets[2] = clamp(x0,0,XMAX);
	instr->packets[3] = clamp(y0,0,YMAX);
	instr->packets[4] = clamp(x1,0,XMAX);
	instr->packets[5] = clamp(y1,0,YMAX);
	appendInstructionToQueue(instr);
}

void GPULib::drawSprite(Sprite* sprite, byte x, byte y, byte color)
{
	drawSprite(sprite->address, x, y, sprite->width, sprite->size, color);
}

void GPULib::drawSprite(int address, byte x, byte y, byte w, byte l, byte color)
{
	Instruction *instr = new Instruction(7);
	instr->packets[0] = 6;
	instr->packets[1] = color;
	instr->packets[2] = clamp(x,0,XMAX);
	instr->packets[3] = clamp(y,0,YMAX);
	instr->packets[4] = clamp(w,0,MAXSPRITEWIDTH);
	instr->packets[5] = ((l << 2) & B11111100) | ((address>>8) & B11);
	instr->packets[6] = (address & 0xFF);
	appendInstructionToQueue(instr);
}

void GPULib::drawTriangle(byte x0, byte y0, byte x1, byte y1, byte x2, byte y2, byte color){
	drawLine(x0,x0,x1,y1, color);
	drawLine(x1,y1,x2,y2, color);
	drawLine(x2,y2,x0,y0, color);
}

void GPULib::drawPoly(byte* x, byte* y, byte size, byte color){
	if(size<3){
		return;
	}
	for(int i = 0; i<size-1; i++){
		drawLine(x[i],y[i],x[i+1],y[i+1], color);
	}
	drawLine(x[size-1],y[size-1],x[0],y[0], color); //close it
}

void GPULib::drawChar6x8(char c, byte x, byte y, byte color){	
	drawSprite(sprites_font6x8_set[c-32], x, y, color);	
}
void GPULib::drawString6x8(const char* string, byte x, byte y, byte color){
	int i = 0;
	int dx = 0;
	while(string[i]!='\0'){ // string[i]!='\0'
		if(string[i]!=' ')		
			drawChar6x8(string[i],x+dx,y,color);
		i++;
		if(string[i]==' '){
			dx+=4;
		} else {
			dx+=6;
		}
	}
}

void GPULib::drawImage(Sprite* sprite, byte* x, byte* y)
{
	long numpixels = sprite->width*sprite->height;
	for (int i=0; i<numpixels; i++)
	{
		drawPixel(i % sprite->width, i/sprite->width, sprite->data[i]);
	}
}

bool GPULib::loadSprites(Sprite *set[], int size, bool *readyfornext){
	uint16_t address = 0;
	Serial.println("Started Sending!");
	int spriteID = 0;
	for(int i = 0; i<size; i++){
		spriteID=nextSpriteID;
		if(spriteID<SPRITESPART1){ // to the right of screenbuffer #0
			address = 192u+256u*spriteID;
		} else if(spriteID<SPRITESPART2) { // underneath screenbuffer #0
			address = 120u*256u+64u*(spriteID-SPRITESPART1);
		} else if(spriteID<SPRITESPART3) { // to the right of screenbuffer #1
			address = 128u*256u+192u+256u*(spriteID-SPRITESPART2);
		} else if(spriteID<SPRITESPART4){// underneath screenbuffer #1
			address = 248u*256u+64u*(spriteID-SPRITESPART3);
		} else {
			return false;
		}
		set[i]->address = address >> 6;
		sendSprite(set[i]);
		nextSpriteID++;
	}
	Serial.println("Sending Complete!");
	return true;
}
void GPULib::sendSprite(Sprite *sprite){
	Instruction *instr = new Instruction(3);
	instr->packets[0] = 7;
	instr->packets[1] = ((sprite->size << 2) & B11111100) | ((sprite->address>>8) & B11);
	instr->packets[2] = (sprite->address & 0xFF);	
	sending = true;
	for (int j=0; j<(instr->numPackets); j++)
	{
		SPI.transfer(instr->packets[j]);		
	}	
	//send data
	for(int i = 0; i<sprite->size; i++){		
		SPI.transfer(pgm_read_byte(&sprite->data[i]));
	}
	delete instr;
	sending = false;
}