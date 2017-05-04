// Class for processing input for running programs using a SoG-based GPU chip
// EPO3-1 - TU Delft
#pragma once
#ifndef _INPUTLIB_
#define _INPUTLIB_

class InputLib
{
private:
	long timestamp;
	bool BLB,BLS,BRB,BRS;
public:
	InputLib() : timestamp(0),BLB(false),BLS(false),BRB(false),BRS(false) {
		pinMode(PIN_BLB,INPUT_PULLUP);
		pinMode(PIN_BLS,INPUT_PULLUP);
		pinMode(PIN_BRB,INPUT_PULLUP);
		pinMode(PIN_BRS,INPUT_PULLUP);	
	};
	void tick(int timeout);
	bool isButtonLeftBPressed();
	bool isButtonLeftSPressed();
	bool isButtonRightBPressed();
	bool isButtonRightSPressed();
	bool areAllButtonsPressed();
};
#endif