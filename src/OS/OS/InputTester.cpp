#include "Util.h"
void InputTester::tick(unsigned long ctime){
	GPU->cleanUp();	
	GPU->drawFill(B000000);	
	//for(int i =0; i < 2; i++){
		GPU->drawString6x8("Inputs Detected: ",2,2,B111111);
		if (Input->isButtonRightBPressed())
		{
			GPU->drawString6x8("[BRB]",2,10,B110000);
		}
		if (Input->isButtonRightSPressed())
		{
			GPU->drawString6x8("[BRS]",2,18,B001100);
		}
		if (Input->isButtonLeftBPressed())
		{
			GPU->drawString6x8("[BLB]",2,26,B000011);
		}
		if (Input->isButtonLeftSPressed())
		{
			GPU->drawString6x8("[BLS]",2,34,B001111);
		}		
	//}
	GPU->switchScreenBuffer();	
}
void InputTester::start(){
	
}
void InputTester::stop(){
	
}
void InputTester::reset(){
	
}