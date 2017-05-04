#pragma once
#ifndef _DEMO_
#define _DEMO_
struct Point{
public:
	int x;
	int y;
	int dx;
	int dy;
	byte color;
	Point(int x, int y, int dx, int dy, byte color) : x(x), y(y), dx(dx), dy(dy), color(color) {};
};
class Demo : public Program{
	Point **points;
	int numPoints;
	int count;
	byte xs[4];
	byte ys[4];
public: 
	Demo(GPULib *GPU, InputLib *Input) : Program(GPU, Input, "Demo"), count(0), numPoints(64) {
		xs[0] = 80;
		xs[1] = 40;
		xs[2] = 80;
		xs[3] = 120;
		ys[0] = 20;
		ys[1] = 60;
		ys[2] = 100;
		ys[3] = 60;			
	};
	void start();
	void tick(unsigned long ctime);
	void stop();
	void reset();
};

#endif