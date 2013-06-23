//
//  ShapeView.m
//  huadufu
//
//  Created by Tianhu Yang on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShapeView.h"
@interface ShapeView()
{
    float color[4];
}
@end

@implementation ShapeView
@synthesize shapeSize,shapeOpacity;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        //color[1]=1.f;
        color[0]=1.f;
        color[3]=.5f;
    }
    return self;
}

-(void) setShapeOpacity:(float)aShapeOpacity
{
    shapeOpacity=color[3]=aShapeOpacity;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGRect frame=self.bounds;
    frame.origin.y=(frame.size.height-shapeSize)/2.0f;
    frame.size.height=shapeSize;
    CGContextSetFillColor(ctx, color);
    //CGContextAddRect(ctx, frame);
    CGContextFillRect(ctx, frame);
}


@end
