//
//  PaintViewTouch.h
//  GLPaint
//
//  Created by Tianhu Yang on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaintView;
@interface PaintTouch : NSObject
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (id) initWith:(PaintView*)aPaintView;
@end
