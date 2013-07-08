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
        //
        NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:@"<b>bold</b> and <i>italic</i> style"];
        [attString addAttribute:(NSString *)kCTForegroundColorAttributeName  
                            value:(id)textColor.CGColor   
                            range:NSMakeRange(4, attString.length-4)]; 
        [attString addAttribute:(NSString *)kCTForegroundColorAttributeName  
                          value:(id)([UIColor redColor].CGColor)  
                          range:NSMakeRange(0, 4)]; 
        
        [msgView setAttributedText:attString];
        
    }
    return self;
}

- (void) setData:(NSDictionary*)dict
{
    NSString *name = [dict objectForKey:@"name"];
    if (name == nil) {
        name = @"";
    }
    NSString *text = [dict objectForKey:@"description"], *msg = [dict objectForKey:
    @"message"];
    if (text == nil)
        text = @"";
    if (msg == nil)
        msg = @"";
    if (text.length > 0 && msg.length > 0)
        text = [NSString stringWithFormat:@"%@\n", text];
    text = [NSString stringWithFormat:@"%@%@", text, msg];
    NSString *time = [dict objectForKey:@"time"];
    if (time == nil) {
        time = @"";
    }
    text = [NSString stringWithFormat:@"%@[%@]", text, time];
    NSRange range = [text rangeOfString:name];
    NSMutableAttributedString *attString;
     UIFont *font = [UIFont boldSystemFontOfSize:msgView.font.lineHeight];
    if (range.length > 0) {
        attString = [[NSMutableAttributedString alloc] initWithString:text];
        [attString addAttribute:(NSString *)kCTForegroundColorAttributeName
                          value:(id)textBlue.CGColor
                          range:range];
       
        [attString addAttribute:(NSString *)kCTFontAttributeName
                          value:(__bridge id)CTFontCreateWithName((__bridge CFStringRef)font.fontName,
                                                                  font.lineHeight,
                                                                  NULL)
                          range:range];
        range.length = text.length - time.length;
        if (range.length > -1)
        {
            [attString addAttribute:(NSString *)kCTForegroundColorAttributeName
                              value:(id)timeColor.CGColor
                              range:NSMakeRange(range.length, time.length)];
        }
    } else {
        attString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@:\n%@", name, text]];
        range.location = 0;
        range.length = name.length;
        [attString addAttribute:(NSString *)kCTForegroundColorAttributeName
                          value:(id)textBlue.CGColor
                          range:range];
        
        [attString addAttribute:(NSString *)kCTFontAttributeName
                          value:(__bridge id)CTFontCreateWithName((__bridge CFStringRef)font.fontName,
                                                                  font.lineHeight,
                                                                  NULL)
                          range:range];
        range.length = text.length - time.length;
        if (range.length > -1)
        {
            [attString addAttribute:(NSString *)kCTForegroundColorAttributeName
                              value:(id)timeColor.CGColor
                              range:NSMakeRange(range.length, time.length)];
        }
    }
    [msgView setAttributedText:attString];
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
