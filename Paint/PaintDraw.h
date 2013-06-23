//
//  PaintDraw.h
//  GLPaint
//
//  Created by Tianhu Yang on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "PaintDelegate.h"

@class PaintView;
#define DRAWMODENONE 0
#define DRAWMODEDRAW 1
#define DRAWMODEZOOM 2
#define DRAWMODETEXT 3
#define DRAWMODEIMAGE 4
#define DRAWMODEABSORB 5

typedef struct{
    unsigned x;
    unsigned y;
    unsigned width;
    unsigned height;
    void *data;    
} TextureData;

@interface PaintDraw : NSObject
{
    
}
@property(nonatomic,strong) id<PaintDelegate> paintDelegate;
@property(nonatomic, assign) float scale;
@property(nonatomic,assign) int drawMode;
@property(nonatomic, assign) float maxScale;
@property(nonatomic, strong)  EAGLContext *context;
@property(nonatomic, assign,readonly) GLuint viewFrameBuffer,texture,textureFrameBuffer,viewRenderBuffer,undoTexture,undoFrameBuffer;
@property(nonatomic,assign) CGSize space;
@property(nonatomic,assign) CGSize textureSize;
@property(nonatomic,assign) float *backColor;
-(id) initWith:(PaintView *)aPaintView;
-(void) presentTexture;
- (void) switchMode:(unsigned)yes;
- (CGPoint) transformPoint:(CGPoint)point;
- (CGPoint) convertRatio:(CGPoint)point;
-(CGPoint) getRatio;
- (CGPoint)convertPoint:(CGPoint)point size:(float)size lower:(BOOL)lower;
- (void) move:(CGPoint)first second:(CGPoint)second;
- (void) drawImage:(UIView*)view points:(CGPoint[4]) points;
-(CGSize) scaleSize:(CGSize) size;
-(CGSize) logSize:(CGSize)size;
- (const float *) getColor:(CGPoint)point;
- (UIImage *) snapshot:(CGSize)size;
- (TextureData)readImage:(CGRect) rect;
- (TextureData)readImage;
- (void) drawImage:(UIImage*)image;
- (void) clear:(UIImage *)image;
- (void) writeImage:(TextureData *)textureData;
- (void) zoomIn:(BOOL) yesOrNO;
- (UIImage*) resizeImage:(UIImage*)image;
- (void) swap;
- (int (*)[2]) getMeasure;
@end
