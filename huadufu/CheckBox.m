//
//  CheckBox.m
//  iKeybox
//
//  Created by Tianhu Yang on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CheckBox.h"
static UIImage *checkedImage,*uncheckedImage;

@implementation CheckBox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)onClick: (id)sender { 
    self.selected=!self.selected;
}

- (void) initialize
{
    if (checkedImage==nil) {
        checkedImage=[UIImage imageNamed:@"checked.png"];
    }
    if (uncheckedImage==nil) {
        uncheckedImage=[UIImage imageNamed:@"unchecked.png"];
    }
    [self setBackgroundImage:uncheckedImage
                        forState:UIControlStateNormal];
    [self setBackgroundImage:checkedImage
                        forState:UIControlStateSelected];
    [self setBackgroundImage:checkedImage
                    forState:UIControlStateHighlighted];
    //[self setBackgroundImage:checkedImage forState:UIControlStateHighlighted];
    self.adjustsImageWhenHighlighted=NO;
    //[self removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside]; 
    [self addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
