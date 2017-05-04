#include "Util.h"


bool Program::isRunning(){
	return state==Running;
}

void Program::tick(unsigned long ctime){
	if(state==Running)
		return;
}
