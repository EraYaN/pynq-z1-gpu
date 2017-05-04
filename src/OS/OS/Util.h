#pragma once
#ifndef _UTIL_
#define _UTIL_
#define clamp(v,vmin,vmax) max(vmin,min(vmax,v));

#include "Arduino.h"
#include "MemoryFree.h"
#include "SPI.h"
#include "Constants.h"
#include "floatToString.h"
#include "font8x8_basic.h"
#include "Enums.h"
#include "PS2Keyboard.h"
#include "InputLib.h"
#include "Sprites.h"
#include "GPULib.h"
#include "Program.h"
#include "Game.h"
#include "Menu.h"
//Programs and Games

#include "Demo.h"
#include "InputTester.h"
#include "Introduction.h"
#include "Pong.h"

//sprite sets
#include "font4x4_set.h"
#include "font6x8_set.h"
#include "font8x8_set.h"

//#include "bf4_1.h"
#endif
