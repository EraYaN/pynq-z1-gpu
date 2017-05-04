#include "Util.h"
void Demo::tick(unsigned long ctime){
	GPU->cleanUp();	
	GPU->drawFill(B000000);
	
	//for(int i =0; i < 2; i++){	
		GPU->drawRect(19, 19, 21+count%120, 61, B111111);
	
		GPU->drawLine(
			byte(55*cos(count/50.0))+80,
			byte(55*sin(count/50.0))+60,
			byte(-55*cos(count/50.0))+80,
			byte(-55*sin(count/50.0))+60,
			B001100
		);
		GPU->drawFilledRect(20, 20, 20+count%120, 60, B110000);
		for(int p = 0; p<numPoints; p++){
			if(points[p]){
				points[p]->x+=(points[p]->dx);
				if(points[p]->x>=XMAX-1){
					points[p]->dx=-points[p]->dx;
					points[p]->x=XMAX-1;
				} else if (points[p]->x<=1){
					points[p]->dx=-points[p]->dx;
					points[p]->x=1;
				}
				points[p]->y+=(points[p]->dy);
				if(points[p]->y>=YMAX-1){
					points[p]->dy=-points[p]->dy;
					points[p]->y=YMAX-1;
				} else if (points[p]->y<=1){
					points[p]->dy=-points[p]->dy;
					points[p]->y=1;
				}
				GPU->drawPixel(points[p]->x,points[p]->y,points[p]->color);
			}
		}
		GPU->drawRect(count%(XMAX+1),0,count%(XMAX+1),YMAX,B001100);
		GPU->drawTriangle(2,4,30,100,60,90,B011010);
		GPU->drawString6x8("The quick brown fox",2,8,B111100);
		GPU->drawString6x8("jumps over the lazy dog",2,16,B111100);
		GPU->drawPoly(xs,ys,4,B000011);
	//}
	count++;
	GPU->switchScreenBuffer();			
}
void Demo::start(){
	points = (Point**)malloc(sizeof(Point*)*numPoints);
	for(int p = 0; p<numPoints;  p++){
		int dx = 0;
		while(dx==0){
			dx = random(-3,3);
		}
		int dy = 0;
		while(dy==0){
			dy = random(-3,3);
		}
		int x = random(1,XMAX-1);
		int y = random(1,YMAX-1);
		points[p] = new Point(x,y,dx,dy,random(8,64));
	}
}
void Demo::stop(){
	for(int p = 0; p<numPoints;  p++){
		delete points[p];
	}
	free(points);
}
void Demo::reset(){
	
}