//
//  TouchButton.m
//  huadufu
//
//  Created by Tianhu Yang on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TouchButton.h"
#import "QuartzCore/QuartzCore.h"

@implementation TouchButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    self.layer.cornerRadius=4.0f;
    self.layer.borderColor=[UIColor clearColor].CGColor;
    self.layer.borderWidth=1.0f;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void) setHighlighted:(BOOL)highlighted
{
    super.highlighted=highlighted;
    if (highlighted) {
        self.backgroundColor=[UIColor colorWithRed:1.0f green:204/255.0f blue:102/255.0f alpha:1.0f];
    }
    else {
        self.backgroundColor=[UIColor clearColor];
    }
}

@end
