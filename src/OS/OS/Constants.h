#pragma once
#ifndef _CONSTANTS_
#define _CONSTANTS_
#define MAX_NUM_INSTR_PACKETS 6
#define MAX_QUEUE_SIZE 100
#define INT_READY_PIN 2
#define MAX_PROGRAM_NAME_LENGTH 14 //reserve one byte for the null byte
#define XMAX 159
#define YMAX 119
#define SPRITESPART1 120
#define SPRITESPART2 152
#define SPRITESPART3 272
#define SPRITESPART4 304
#define MAXSPRITELENGTH 54 //6-bit bytes so 54 addresses in the GPU
#define MAXSPRITEWIDTH XMAX //8-bit width
#define KEYBOARDDATAPIN 4
#define KEYBOARDCLOCKPIN 3
#define NUM_PROGRAMS 4
#define MENU_Y_OFFSET 6
#define PIN_BLB 9
#define PIN_BLS 10
#define PIN_BRS 11
#define PIN_BRB 12
#define INPUT_TIMEOUT 250
#define INPUT_TIMEOUT_INGAME 50
#endif