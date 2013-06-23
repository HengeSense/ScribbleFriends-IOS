//
//  UIGridViewCell.m
//  foodling2
//
//  Created by Tanin Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIGridViewCell.h"
#import "QuartzCore/QuartzCore.h"

static UIGridViewCell *selectedCell;

@implementation UIGridViewCell

@synthesize rowIndex;
@synthesize colIndex;
@synthesize view;

- (id) initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    self.showsTouchWhenHighlighted=YES;
    self.layer.cornerRadius = 4.0;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor orangeColor].CGColor;
    self.layer.borderWidth = 1.0;
    return self;
}

- (void) addSubview:(UIView *)v
{
	[super addSubview:v];
	v.exclusiveTouch = NO;
	v.userInteractionEnabled = NO;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self touchDone];
}

-(void) touchDone
{
    if (selectedCell!=self) {
        selectedCell.selected=NO;
        self.selected=YES;
        selectedCell=self;
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self touchDone];
}

- (void) setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor=[UIColor orangeColor];
    }
    else {
        self.backgroundColor=nil;
    }
}


@end
