//
//  ImageView.h
//  GLPaint
//
//  Created by Tianhu Yang on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageView : UIView
@property(nonatomic,assign) BOOL propotioal;
@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,assign) BOOL focus;
- (void) drawImage;
- (void) begin;
- (void) end;
@end
