//
//  FBNewsTableCell.m
//  ScribbleFriends
//
//  Created by Tianhu Yang on 1/28/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FBNewsTableCell.h"

@interface FBNewsTableCell()
{
    UIColor *selectedColor;
    UIColor *textColor;
    UIColor *textBlue;
    UIColor *timeColor;
}

@end

@implementation FBNewsTableCell
@synthesize backView;
@synthesize headView;
@synthesize msgView;
@synthesize picView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(int)height
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
         selectedColor=[UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1.0f];
        textColor=[UIColor colorWithRed:0x7c/255.0f green:0x7f/255.0f  blue:0x86/255.0f alpha:0x1];//#7C7F86
        textBlue=[UIColor colorWithRed:0x63/255.0f green:0x76/255.0f  blue:0x9c/255.0f alpha:0x1];//#63769C
        timeColor=[UIColor colorWithRed:0xab/255.0f green:0xae/255.0f  blue:0xb1/255.0f alpha:0x1];//#ABAEB1
        [[NSBundle mainBundle] loadNibNamed:@"FBNewsTableCell" owner:self options:nil];
        CGRect frame=self.frame;
        frame.origin.x=10;
        frame.origin.y=10;
        frame.size.width-=2*frame.origin.x;
        frame.size.height=height-frame.origin.y;
        backView.frame=frame;
        [self.contentView addSubview:backView];
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:@"<b>bold</b> and <i>italic</i> style"];
        [attString addAttribute:(NSString *)kCTForegroundColorAttributeName  
                            value:(id)textColor.CGColor   
                            range:NSMakeRange(4, attString.length-4)]; 
        [attString addAttribute:(NSString *)kCTForegroundColorAttributeName  
                          value:(id)([UIColor redColor].CGColor)  
                          range:NSMakeRange(0, 4)]; 
        UIFont *font=[UIFont boldSystemFontOfSize:msgView.font.lineHeight];
        [attString addAttribute:(NSString *)kCTFontAttributeName  
                            value:(__bridge id)CTFontCreateWithName((__bridge CFStringRef)font.fontName,
                                                           font.lineHeight,   
                                                           NULL)  
                            range:NSMakeRange(0, 4)];
        [msgView setAttributedText:attString];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(selected==NO){
        backView.backgroundColor=[UIColor whiteColor];
    }
    else {
        backView.backgroundColor=selectedColor;
    }
    
    // Configure the view for the selected state
}

@end
