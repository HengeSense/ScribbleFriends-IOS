//
//  Text.h
//  GLPaint
//
//  Created by Tianhu Yang on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
@class PaintView;
@interface ImageKit : NSObject 
-(id) initWith:(PaintView *)pv;
@end
