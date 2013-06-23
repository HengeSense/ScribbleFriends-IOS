//
//  ZoomButton.m
//  huadufu
//
//  Created by Tianhu Yang on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZoomButton.h"

@implementation ZoomButton

@synthesize canUnhighlighted=_canUnhighlighted;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _canUnhighlighted=YES;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        _canUnhighlighted=YES;
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

- (void)setHighlighted:(BOOL)highlighted
{
    if (!highlighted) {
        if (_canUnhighlighted) {
            super.highlighted=highlighted;
        }        
    }
    else {
        super.highlighted=highlighted;
    }
}

- (void) setCanUnhighlighted:(BOOL)canUnhighlighted
{
    _canUnhighlighted=canUnhighlighted;
    if (canUnhighlighted) {
        self.highlighted=NO;
    }
}
@end
