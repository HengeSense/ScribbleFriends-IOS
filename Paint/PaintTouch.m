//
//  PaintViewTouch.m
//  GLPaint
//
//  Created by Tianhu Yang on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaintTouch.h"
#import "PaintView.h"
#import "PaintDraw.h"
#import "Brush.h"
#import "UndoManager.h"
@interface PaintTouch()
{
    PaintView *paintView;
    PaintDraw *paintDraw;
    Boolean	firstTouch;  
    CGPoint first,second,third;
}
@property(nonatomic, assign) CGPoint location;
@property(nonatomic, assign) CGPoint previousLocation;
@end
@implementation PaintTouch
@synthesize location;
@synthesize previousLocation;

- (id) initWith:(PaintView*)aPaintView
{
    paintView=aPaintView;
    paintDraw=paintView.paintDraw;
    return self;
}
// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch*	touch = [[event touchesForView:paintView] anyObject];
	firstTouch = YES;
    previousLocation = [touch locationInView:paintView];
    
    //first = [touch previousLocationInView:paintView];  
    //second = [touch previousLocationInView:paintView];  
    //third = [touch locationInView:paintView];
    switch (paintDraw.drawMode) {
        case DRAWMODEDRAW:
            [paintView.brush drawBegan:previousLocation];
            break;
        case DRAWMODEABSORB:
            paintView.absorbView.hidden=NO;
            [paintView.absorbView update:previousLocation];
            break;
        default:
            break;
    }
	
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  
    
	UITouch* touch = [[event touchesForView:paintView] anyObject];
	if (firstTouch) {
		firstTouch = NO;
		 location= [touch locationInView:paintView];
	}
    else {
        location = [touch locationInView:paintView];
        previousLocation =[touch previousLocationInView:paintView];
    }
    
    //first = second;  
    //second = [touch previousLocationInView:paintView];  
    //third = [touch locationInView:paintView];
    
    switch (paintDraw.drawMode) {
        case DRAWMODEDRAW:
            // Render the stroke
            [paintView.brush drawFrom:previousLocation to:location];
            //[paintView.brush bezier:first second:second third:third];
            break;
        case DRAWMODEZOOM:
            [paintDraw move:previousLocation second:location];
            break;
        case DRAWMODEABSORB:
            [paintView.absorbView update:location];
            break; 
        default:
            break;
    }    
	
}



// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesFinished:touches withEvent:event];
}

// Handles the end of a touch event.
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	// If appropriate, add code necessary to save the state of the application.
	// This application is not saving state.
    [self touchesFinished:touches withEvent:event];
}

- (void) touchesFinished:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch*	touch = [[event touchesForView:paintView] anyObject];
	if (firstTouch) {
		firstTouch = NO;
		location = [touch previousLocationInView:paintView];
        if (paintDraw.drawMode==DRAWMODEDRAW)
        {
            //[paintView.brush drawDot:location]; 
            //[paintView.brush bezier:first second:second third:third];
        }		
	}
    switch (paintDraw.drawMode) {
        case DRAWMODEDRAW:
            [paintView.brush drawEnded:location];
            break;
        case DRAWMODEABSORB:
            paintView.absorbView.hidden=YES;
            paintView.brush.color=paintView.absorbView.absorbedColor;
            break;    
        default:
            break;
    }
}
@end
