#pragma once
#ifndef _PONG_
#define _PONG_
class Pong : public Game{
	byte posP1,posP2;
	float x, y, dx, dy;
	byte scoreP1, scoreP2;
	byte running;
public: 
	Pong(GPULib *GPU, InputLib *Input) : Game(GPU, Input, "Pong"), posP1(YMAX/2), posP2(YMAX/2), scoreP1(0), scoreP2(0), y(YMAX/2), x(XMAX/2), dx(1), dy(0), running(true) {		
	};
	void start();
	void tick(unsigned long ctime);
	void stop();
	void reset();
};

#endif