//
//  SketchView.m
//  GLPaint
//
//  Created by Tianhu Yang on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SketchView.h"
#import "PaintDraw.h"
#import "PaintView.h"

@interface SketchView()
{
    GLuint viewFramebuffer,viewRenderbuffer,depthRenderbuffer;
    float innerColorf[4];
    float outerColorf[4];
    GLint backingWidth,backingHeight;
}

@end

@implementation SketchView
@synthesize  viewFramebuffer,viewRenderbuffer;
@synthesize outerColor,innerColor;

- (void) setOuterColor:(UIColor*) clr
{
    outerColor=clr;
    CGColorRef colorRef=clr.CGColor;
    const float *comp=CGColorGetComponents(colorRef);
    memcpy(outerColorf,comp,4*sizeof(float));
    outerColorf[3]=1;
}
- (void) setInnerColor:(UIColor*) clr
{
    innerColor=clr;
    CGColorRef colorRef=clr.CGColor;
    const float *comp=CGColorGetComponents(colorRef);
    memcpy(innerColorf,comp,4*sizeof(float));
    innerColorf[3]=.5;
}

- (void) use
{
    PaintDraw *paintDraw=((PaintView*)self.superview).paintDraw;
    float *color=paintDraw.backColor;
    if (color[0] + color[1] + color[2] < 1.5f) {
        outerColorf[0]=1;
        outerColorf[1]=1;
        outerColorf[2]=1;        
    } else {
        outerColorf[0]=0;
        outerColorf[1]=0;
        outerColorf[2]=0; 
    }    
    innerColorf[0]=color[0];
    innerColorf[1]=color[1];
    innerColorf[2]=color[2];
    for (int i = 0; i < 3; ++i) {
        if (innerColorf[i] < .5f)
            innerColorf[i] += .5f;
        else
            innerColorf[i] -= .5f;
    }
    [self update];
}

- (id)initWithFrame:(CGRect)frame
{    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.contentScaleFactor = 1.0;
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;		
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:                                         kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        self.userInteractionEnabled=YES;
        //[NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,  
        innerColorf[3]=1;
        outerColorf[3]=1;
    }
    return self;
}

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self destroyFramebuffer];
    [self createFramebuffer];
    
}

- (void) update
{    
    PaintDraw *paintDraw=((PaintView*)self.superview).paintDraw;
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    CGSize size=CGSizeMake(backingWidth, backingHeight);
    glMatrixMode(GL_PROJECTION); 
    glLoadIdentity();
    glOrthof(0, size.width, 0, size.height, -1, 1);
    glViewport(0, 0, size.width, size.height);
    glMatrixMode(GL_MODELVIEW);
    glDisable(GL_BLEND);
    //whole image
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glBindTexture(GL_TEXTURE_2D, paintDraw.texture);
    size.width-=1;
    size.height-=1;
    GLfloat vertices[] = {
        1, size.height,
        size.width, size.height,
        1,  1,
        size.width,  1,
    };
    CGPoint ratio=[paintDraw getRatio];
    float  textureCoords[] = {
        0, 0,
        ratio.x, 0,
        0, ratio.y,
        ratio.x, ratio.y
    };
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);        
    GLfloat color[4];
    glGetFloatv(GL_CURRENT_COLOR,color);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);        
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);    
    /*** frame start ***/
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_TEXTURE_2D);    
    glColor4f(innerColorf[0], innerColorf[1], innerColorf[2], innerColorf[3]);
    size=self.superview.bounds.size;
    GLfloat vertices1[] = {
        0,  0,        
        size.width,  0,
        size.width, size.height,
        0, size.height,
        0,  0       
    }; 
    size=CGSizeMake(backingWidth, backingHeight);
    size.height-=3.0f;
    size.width-=3.0f;
    CGPoint *points=(CGPoint*)vertices1;
    for (int i=0; i<5; ++i) {
        points[i]=[paintDraw convertRatio:points[i]];        
        points[i].x*=size.width;
        points[i].y=(1-points[i].y)*size.height; 
        points[i].x+=1;
        points[i].y+=1;
    }
    glVertexPointer(2, GL_FLOAT, 0, vertices1);
    glDrawArrays(GL_LINE_STRIP, 0, 5);
    /*** frame end ***/
    /*** bounds start ***/
    glColor4f(outerColorf[0], outerColorf[1], outerColorf[2], outerColorf[3]);
    size=CGSizeMake(backingWidth, backingHeight);
    GLfloat vertices2[] = {
        0,  0,        
        size.width,  0,
        size.width, size.height,
        0, size.height,
        0,  0       
    }; 
    glVertexPointer(2, GL_FLOAT, 0, vertices2);
    glDrawArrays(GL_LINE_STRIP, 0, 5);
    /*** bounds end ***/
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [paintDraw.context presentRenderbuffer:GL_RENDERBUFFER_OES];
    glColor4f(color[0], color[1], color[2], color[3]);
    glEnable(GL_BLEND);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
}


- (BOOL)createFramebuffer
{	// Generate IDs for a framebuffer object and a color renderbuffer
    
    PaintDraw *paintDraw=((PaintView*)self.superview).paintDraw;
	glGenFramebuffersOES(1, &viewFramebuffer);
	glGenRenderbuffersOES(1, &viewRenderbuffer);	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    //glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	[paintDraw.context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)self.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	glGenRenderbuffersOES(1, &depthRenderbuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}   
    
	
	return YES;
}

// Clean up any buffers we have allocated.
- (void)destroyFramebuffer
{
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
    glDeleteRenderbuffersOES(1, &depthRenderbuffer);
    depthRenderbuffer = 0;
}

@end
