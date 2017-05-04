#include "Util.h"
void Pong::tick(unsigned long ctime){
	//Game logic
	
	if(running){
		x+=dx;
		y+=dy;
		if (Input->isButtonRightBPressed())
		{
			if(posP1>10)
				posP1-=3;
		}
		if (Input->isButtonRightSPressed())
		{
			if(posP1<YMAX-10)
				posP1+=3;
		}
		if (Input->isButtonLeftBPressed())
		{
			if(posP2>10)
				posP2-=3;
		}
		if (Input->isButtonLeftSPressed())
		{
			if(posP2<YMAX-10)
				posP2+=3;
		}	
		if(x>XMAX-3){
			//on P2 side
			if(y<posP2-10||y>posP2+10){
				//P2 died
				scoreP1++;
				x = XMAX-10;
				y = YMAX/2;
				dx = -1;
				dy = 0;
			} else {
				//bounced
				dx = -dx;
				if(y>posP2){
					if(dy>=0){
						dy+=0.2;
					} else {
						dy-=0.2;
					}
				}
				if(y<posP2){
					if(dy>=0){
						dy-=0.2;
					} else {
						dy+=0.2;
					}
				}
			}
		}
		if(x<3){
			//one P1 side
			if(y<posP1-10||y>posP1+10){
				//P1 died
				scoreP2++;
				x = 10;
				y = YMAX/2;
				dx = 1;
				dy = 0;
			} else {
				//bounced
				dx = -dx;
				if(y>posP1){
					if(dy>=0){
						dy+=0.2;
					} else {
						dy-=0.2;
					}
				}
				if(y<posP1){
					if(dy>=0){
						dy-=0.2;
					} else {
						dy+=0.2;
					}
				}
			}
		}
		if(y<2 || y>YMAX-2){
			//reached top or bottom
			dy = -dy;
		}
	}
	if(scoreP1>=5 || scoreP2>=5){		
		running = false;
	}
	//Drawing
	GPU->cleanUp();	
	GPU->drawFill(B0);

	for(int i =0; i < 2; i++){
		if(running){
			GPU->drawFilledRect(round(x)-1,round(y)-1,round(x)+1,round(y)+1,B111111);
			GPU->drawFilledRect(0,posP1-10,2,posP1+10,B111111);
			GPU->drawFilledRect(XMAX-2,posP2-10,XMAX,posP2+10,B111111);
			GPU->drawChar6x8(scoreP1+48,4,YMAX-12,B111111);
			GPU->drawChar6x8(scoreP2+48,XMAX-10,YMAX-12,B111111);
		} else {
			if(scoreP1>=5){		
				GPU->drawString6x8("P1 won",4,YMAX-12,B111111);
			}
			if(scoreP2>=5){		
				GPU->drawString6x8("P2 won",XMAX-44,YMAX-12,B111111);
			}
		}
	}
	GPU->switchScreenBuffer();			
}
void Pong::start(){
	posP1 = YMAX/2;
	posP2 = YMAX/2;
	scoreP1 = 0;
	scoreP2 = 0;
	y= YMAX/2;
	x=XMAX/2;
	dx=1;
	dy= 0;
}
void Pong::stop(){
	
}
void Pong::reset(){
	
}