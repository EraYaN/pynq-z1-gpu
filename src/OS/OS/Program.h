#pragma once
#ifndef _PROGRAM_
#define _PROGRAM_
class Program {
protected:
	GPULib *GPU;
	InputLib *Input;
	ProgramState state;
public:
	const char* name;	
	Program(GPULib *GPU, InputLib *Input, const char* programName) : GPU(GPU),Input(Input),name(programName) {};
	Program(GPULib *GPU, InputLib *Input):GPU(GPU),Input(Input),name() {};
	virtual void start();
	virtual void tick(unsigned long ctime);
	virtual bool isRunning();
	virtual void stop();
	virtual void reset();
};
#endif