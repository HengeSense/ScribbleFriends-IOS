//
//  Brush.h
//  GLPaint
//
//  Created by Tianhu Yang on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

@class PaintView;
extern const int BRUSH_PENCIL;
extern const int BRUSH_BRUSH;
extern const int BRUSH_ERASER;

@interface Brush : NSObject
{
    @private
    GLuint	brushTexture;
    PaintView *paintView;
}
@property(assign, nonatomic) GLfloat opacity;
@property(assign, nonatomic) GLfloat pixelStep;
@property(assign, nonatomic) GLfloat brushScale;
@property(assign, nonatomic) int textureIndex;
@property(assign, nonatomic) int brushMode;
@property(strong, nonatomic) UIColor *brushColor,*color;


- (void) drawFrom:(CGPoint)from to:(CGPoint)to;
-(id) initWith:(PaintView *)pv;
- (void) drawBegan:(CGPoint)loc;
- (void) drawEnded:(CGPoint)loc;
- (void) drawDot:(CGPoint)loc;
- (void) prepare;
@end
