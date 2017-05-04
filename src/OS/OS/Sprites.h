#pragma once
#ifndef _SPRITES_
#define _SPRITES_
struct Sprite{
public:
	int address;
	byte width; //width in pixels
	byte height; //height in pixels
	byte size; // size in 6-bit bytes
	const prog_uchar *data;
	Sprite(int address, byte width, byte height, byte size,const prog_uchar *data) : address(address), width(width), height(height), size(size), data(data) {};
};
#endif