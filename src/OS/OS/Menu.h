#pragma once
#ifndef _MENU_
#define _MENU_
class Menu : public Program{
	int selectedProgram;
	Program **currentProgram;
	Program ***programs;
public: 
	Menu(GPULib *GPU, InputLib *Input, Program ** currentProgram, Program ***programs) : Program(GPU, Input, "Menu"), currentProgram(currentProgram), programs(programs) {
		selectedProgram = 0;
	};
	void start();
	void tick(unsigned long ctime);
	void stop();
	void reset();
};
#endif