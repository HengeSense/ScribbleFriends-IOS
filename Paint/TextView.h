//
//  TextView.h
//  GLPaint
//
//  Created by Tianhu Yang on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextView : UIView
@property(nonatomic,strong) UILabel *label;
@property(nonatomic,assign) BOOL focus;
- (void) drawImage;
- (void) setText:(NSString *)text font:(NSString*)fontName;
- (void) begin;
- (void) end;
@end
