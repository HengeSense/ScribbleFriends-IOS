//
//  SketchView.h
//  GLPaint
//
//  Created by Tianhu Yang on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SketchView : UIView
@property(nonatomic, assign,readonly) unsigned viewFramebuffer,viewRenderbuffer;
@property(nonatomic,assign) UIColor *outerColor,*innerColor;
- (void) update;
- (void) use;
@end
