#pragma once
#ifndef _GAME_
#define _GAME_

struct Control {
	String name;
	byte key;
};

class Game : public Program {

public:
	Game(GPULib *GPU, InputLib *Input, const char* programName)
		: Program(GPU,Input,programName){};
	Game(GPULib *GPU, InputLib *Input): Program(GPU, Input) {};
	void start();
	void tick(unsigned long ctime);
	void stop();
	void reset();
};
#endif