//
//  AbsorbView.m
//  GLPaint
//
//  Created by Tianhu Yang on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AbsorbView.h"
#import "PaintDraw.h"
#import "PaintView.h"
static const float outerWidth=100,innerWidth=60;
static float black[4]={0,0,0,1};
static const float clear[4]={0,0,0,0};
@interface AbsorbView()
{
    float color[4];
}
@end

@implementation AbsorbView

@synthesize absorbedColor;

- (id)initWithFrame:(CGRect)frame
{
    frame.size.width=frame.size.width=outerWidth+4;
    frame.size.height=frame.size.width=outerWidth+4;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code 
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    rect.origin.x=rect.origin.y=2;
    rect.size.width=rect.size.height=outerWidth;
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetFillColor(ctx, color);    
    rect.size.width=rect.size.height=innerWidth;
    rect.origin.x+=(outerWidth-innerWidth)/2.0;
    rect.origin.y+=(outerWidth-innerWidth)/2.0;
    CGContextAddEllipseInRect(ctx, rect);
    CGContextEOFillPath(ctx);
    
    CGContextAddEllipseInRect(ctx, rect);
    CGContextSetStrokeColor(ctx, black);
    
    rect.size.width=rect.size.height=outerWidth;
    rect.origin.x=rect.origin.y=2;
    CGContextAddEllipseInRect(ctx, rect);
    CGContextStrokePath(ctx);
    
}

- (UIColor*) absorbedColor
{
    return [UIColor colorWithRed:color[0] green:color[1] blue:color[2] alpha:color[3]];
}

-(void) use
{
    PaintDraw *paintDraw=((PaintView *)self.superview).paintDraw;
    float factor=0.0f,*backColor=paintDraw.backColor;
    for (int i=0; i<3; ++i) {
        factor+=backColor[i];
    }
    if (factor>1.5f) {
        black[0]=0;
        black[1]=0;
        black[2]=0;        
    }
    else {
        black[0]=1;
        black[1]=1;
        black[2]=1;
    }
}

- (void) update:(CGPoint)loc
{
    PaintDraw *paintDraw=((PaintView *)self.superview).paintDraw;
    memcpy(color,[paintDraw getColor:loc],4*sizeof(float));
    color[3]=1.0f;
    self.center=loc;
    [self setNeedsDisplay];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{    
    UITouch *touch=[[event touchesForView:self] anyObject];
    CGPoint first=[touch previousLocationInView:self];
    CGPoint second=[touch locationInView:self];     
    CGPoint point=self.center;
    point.x+=second.x-first.x;
    point.y+=second.y-first.y;
    self.center=point;
    
    PaintDraw *paintDraw=((PaintView *)self.superview).paintDraw;
    memcpy(color,[paintDraw getColor:[touch locationInView:self.superview]],4*sizeof(float));
    [self setNeedsDisplay];
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
@end
