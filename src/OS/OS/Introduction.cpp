#include "Util.h"
void Introduction::tick(unsigned long ctime){
	GPU->cleanUp();	
	GPU->drawFill(B000000);
	if(Input->isButtonRightSPressed()){
		page=0;
	}
	if(page==0){
		GPU->drawString6x8("Press BLS to begin.",4,10,B111111);
		GPU->drawString6x8("Press BRS to reset.",4,20,B111111);
		if(Input->isButtonLeftSPressed()){
			page++;
		}
	} else if(page==1){
		GPU->drawString6x8("Welcome.",4,10,B111111);
		if(Input->isButtonLeftSPressed()){
			page++;
		}
	}else if(page==2){
		GPU->drawString6x8("I am a GPU.",4,10,B111111);
		if(Input->isButtonLeftSPressed()){
			page++;	
		}
	}else if(page==3){
		GPU->drawString6x8("I can draw pixels!",4,10,B111111);
		GPU->drawPixel(XMAX/2,YMAX/2,B111111);
		if(Input->isButtonLeftSPressed()){
			page++;	
		}
	}else if(page==4){
		GPU->drawString6x8("I can draw rectangles..",4,10,B111111);
		GPU->drawRect(XMAX/2-40,YMAX/2-20,XMAX/2+40,YMAX/2+20,B111111);
		if(Input->isButtonLeftSPressed()){
			page++;
		}
	}else if(page==5){
		GPU->drawString6x8("..and filled ones.",4,10,B111111);
		GPU->drawFilledRect(XMAX/2-40,YMAX/2-20,XMAX/2+40,YMAX/2+20,B111111);
		if(Input->isButtonLeftSPressed()){
			page++;
		}
	}else if(page==6){
		GPU->drawString6x8("I have a line algorithm.",4,10,B111111);
		GPU->drawLine(XMAX/2-40,YMAX/2-20,XMAX/2+40,YMAX/2+20,B111111);
		if(Input->isButtonLeftSPressed()){
			page++;
		}
	}else if(page==7){
		GPU->drawString6x8("And all that in",4,10,B111111); 
		GPU->drawString6x8("64 beautiful colors.",4,20,B111111);
		for(int i = 0; i<64; i++){
			GPU->drawPixel(i+47,YMAX/2,i);
		}
		if(Input->isButtonLeftSPressed()){
			page++;
		}
	}else if(page==8){
		GPU->drawString6x8("This text is made up of ",4,10,B111111); 
		GPU->drawString6x8("soft loaded sprites pushed",4,20,B111111);
		GPU->drawString6x8("to the gpu on startup.",4,30,B111111);
		if(Input->isButtonLeftSPressed()){
			page=0;
		}
	}
	GPU->switchScreenBuffer();			
}
void Introduction::start(){
	page = 0;
}
void Introduction::stop(){
}
void Introduction::reset(){
	
}