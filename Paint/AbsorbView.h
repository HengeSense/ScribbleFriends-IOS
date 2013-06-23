//
//  AbsorbView.h
//  GLPaint
//
//  Created by Tianhu Yang on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AbsorbView : UIView
- (void) update:(CGPoint)loc;
-(void) use;
@property(nonatomic,strong,readonly) UIColor *absorbedColor;
@end
