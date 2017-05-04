#pragma once
#ifndef _INTRODUCTION_
#define _INTRODUCTION_

class Introduction : public Program{
	byte page;
public: 
	Introduction(GPULib *GPU, InputLib *Input) : Program(GPU, Input, "Introduction"), page(0) {
	};
	void start();
	void tick(unsigned long ctime);
	void stop();
	void reset();
};

#endif