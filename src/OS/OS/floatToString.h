#pragma once
#ifndef _FLOATTOSTRING_
#define _FLOATTOSTRING_
char * floatToString(char * outstr, float value, int places, int minwidth=0, bool rightjustify=false);
#endif