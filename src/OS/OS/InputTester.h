#pragma once
#ifndef _INPUTTESTER_
#define _INPUTTESTER_

class InputTester : public Program{	
public: 
	InputTester(GPULib *GPU, InputLib *Input) : Program(GPU,Input,"InputTester") {
		
	};
	void start();
	void tick(unsigned long ctime);
	void stop();
	void reset();
};

#endif