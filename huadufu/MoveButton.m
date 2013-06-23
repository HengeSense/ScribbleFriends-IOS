//
//  UIButton+Move.m
//  huadufu
//
//  Created by Tianhu Yang on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoveButton.h"
#import "QuartzCore/QuartzCore.h"

static MoveButton *lastSeletedButton;
@interface MoveButton()
{
    UIColor *highlightedColor,*selectedColor;
    BOOL bSelected;
}
@end
@implementation MoveButton
@synthesize  isMoved;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}
- (void) initialize
{
    self.layer.cornerRadius=4.0f;
    self.layer.borderColor=[UIColor clearColor].CGColor;
    self.layer.borderWidth=1.0f;
    //self.lr.borderColor;
    highlightedColor=[UIColor colorWithRed:1.0f green:204/255.0f blue:102/255.0f alpha:1.0f];
    selectedColor=[UIColor colorWithRed:204/255.0f green:104/255.0f blue:255/255.0f alpha:1.0f];
}
- (void) setHighlighted:(BOOL)highlighted
{
    super.highlighted=highlighted;
    [self stateChanged];
}

- (void) stateChanged
{
    if (self.highlighted
        ) {
        self.backgroundColor=highlightedColor;
    }
    else if(self.selected) {
        self.backgroundColor=selectedColor;
    }
    else {
        self.backgroundColor=[UIColor clearColor];
    }
}


-(void) setSelected:(BOOL)selected
{
    if (selected&&lastSeletedButton!=self) {
        lastSeletedButton.selected=NO;
        lastSeletedButton=self;
    }
    super.selected=selected;
    [self stateChanged];
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch=[[event touchesForView:self] anyObject];
    CGPoint first=[touch previousLocationInView:self];
    CGPoint second=[touch locationInView:self]; 
    CGRect rect=self.superview.frame;
    float width=self.superview.superview.bounds.size.width-rect.size.width;
    rect.origin.x+=second.x-first.x;
    if (rect.origin.x>0) {
        rect.origin.x=0;
    }
    else if (rect.origin.x<width) {
        rect.origin.x=width;
    }
    self.superview.frame=rect;
    isMoved=YES;
}
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    isMoved=NO;
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    isMoved=NO;
}
@end
