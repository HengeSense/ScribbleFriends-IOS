//
//  PaintDraw.m
//  GLPaint
//
//  Created by Tianhu Yang on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaintDraw.h"
#import "PaintView.h"
#import "SketchView.h"
#import "Brush.h"

static float const textCoords[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f
};

static int measure[2][2];
enum FROM{
    FROM_COLOR,FROM_IMAGE
};
@interface PaintDraw()
{
    PaintView *paintView;
	GLint backingWidth;
	GLint backingHeight;	
	CGPoint scaleStart;   
	GLuint depthRenderBuffer,textureDepthBuffer,undoDepthBuffer;
    GLuint sampleColorRenderbuffer, sampleDepthRenderbuffer;
    float backColorf[4];
    unsigned drawViewDataLength;
    void *drawViewData;
    CGColorSpaceRef colorspace;
    CGSize drawViewRatio;
    enum FROM from;   
    BOOL rotated;
    CGRect clipRect;
    
}

@end

@implementation PaintDraw

@synthesize paintDelegate;
@synthesize maxScale;
@synthesize drawMode;
@synthesize scale;
@synthesize context;
@synthesize viewFrameBuffer,texture,viewRenderBuffer;
@synthesize space;//image size and otho size
@synthesize textureSize;
@synthesize textureFrameBuffer,undoTexture,undoFrameBuffer, sampleFramebuffer;
@synthesize backColor;

-(id) initWith:(PaintView *)aPaintView
{
    paintView=aPaintView;
    return [self initialize];
}
- (id) initialize
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)paintView.layer;
	int factor = eaglLayer.contentsScale;
    factor = 2.0f;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,nil];		
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];		
    if (!context || ![EAGLContext setCurrentContext:context]) {
        return nil;
    }  
    scaleStart.x=scaleStart.y=0.0f;
    memcpy(backColorf,globalKit.initBackColor,4*sizeof(float));
    self.drawMode=DRAWMODEDRAW;
    from=FROM_COLOR;
    
    colorspace=CGColorSpaceCreateDeviceRGB();
    
    glDisable(GL_DITHER);		
    glEnableClientState(GL_VERTEX_ARRAY);        
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);	
    //
    glClearDepthf(0.0f);
    glDepthFunc(GL_NOTEQUAL);
    //
    //glEnable(GL_POINT_SPRITE_OES);
    //glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);		
    glHint (GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);   
    
    [self initBuffers];
    return self;
}

- (float*) backColor
{
    return backColorf;
}
- (void) setBackColor:(float *)aBackColor
{
    memcpy(backColorf, aBackColor, sizeof(float)*3U);
    if (paintView.brush.brushMode==BRUSH_ERASER) {
        glColor4f(backColorf[0], backColorf[1], backColorf[2], backColorf[3]);
    }
}
- (void) zoomIn:(BOOL)yesOrNO
{
    float dummy=1/self.scale;
    if (yesOrNO) {
        dummy-=.25f;
        
    }
    else {
        dummy+=.25f;
        
    }
    if (dummy>maxScale||dummy<1.0f) {
        return;
    }
    self.scale=1/dummy;
    if (yesOrNO) {
        [paintDelegate canZoomOut:YES];
        if (dummy-.25f<=1.0f) {
            [paintDelegate canZoomIn:NO];
        }
    }
    else {
        [paintDelegate canZoomIn:YES];
        if (dummy+.25f>=maxScale) {
            [paintDelegate canZoomOut:NO];
        }
    }
}

- (void) initBuffers
{    
    [self refreshTextureSize];
    //[self destroyFrameBuffer];
	[self createFrameBuffer];
    //[self destroyTexture];
    [self createTexture];
    [self createSampleBuffer];
    [self presentTexture];
    drawViewRatio.width=backingWidth/textureSize.width;
    drawViewRatio.height=backingHeight/textureSize.height;
}

-(void) clear:(UIImage *)image
{
    GLuint width=space.width,height=space.height;
    unsigned length=width*height*4;
    void *data=malloc(length);
    if (data) {
        TextureData textureData;
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, textureFrameBuffer);
        
        glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
        textureData.x=0;
        textureData.y=0;
        textureData.width=width;
        textureData.height=height;
        textureData.data=data;
        [paintView.undoManager beforeDo:&textureData];
        //
        if (image==nil) {
            glClearColor(backColorf[0], backColorf[1], backColorf[2], backColorf[3]);
            glClear(GL_COLOR_BUFFER_BIT);
            from=FROM_COLOR;  
            clipRect.size=space;
            clipRect.origin.x=clipRect.origin.y=0;
        }
        else {
            glClearColor(0x66/255.f, 0x66/255.f, 0x66/255.f, 1.0f);
            glClear(GL_COLOR_BUFFER_BIT);
            from=FROM_IMAGE;
            [self drawImage:image];
            float comp[4]={1.0f,1.0f,1.0f,1.0f};
            backColor=comp;
        }
        
        //
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, textureFrameBuffer);
        glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
        [paintView.undoManager afterDo:&textureData];
        free(data);
    }  
    
}

- (void) setScale:(float)aScale
{
    scale=aScale;
    [self verifyBounds];
}
//verify whether out of bounds
- (void) verifyBounds
{
    CGSize size=CGSizeMake(backingWidth, backingHeight);
    size.width=space.width-size.width/scale;
    size.height=space.height-size.height/scale;
    scaleStart.x=scaleStart.x>size.width?size.width:scaleStart.x;
    scaleStart.y=scaleStart.y>size.height?size.height:scaleStart.y;
}
- (void) switchMode:(unsigned)mode
{
    CGSize size=CGSizeMake(backingWidth, backingHeight);
    float ratio=scale*maxScale;
    glDisable(GL_SCISSOR_TEST);
    switch (mode) {
        case 0://present
            glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFrameBuffer);        
            glMatrixMode(GL_PROJECTION); 
            glLoadIdentity();
            glOrthof(0, size.width, 0, size.height, -1, 1);
            glViewport(0, 0, size.width, size.height);
            glMatrixMode(GL_MODELVIEW);
            break;
//        case 1://texture
//            glBindFramebufferOES(GL_FRAMEBUFFER_OES, textureFrameBuffer);
//            glMatrixMode(GL_PROJECTION); 
//            glLoadIdentity();
//            glOrthof(0, size.width, 0, size.height, -1, 1);
//            glViewport(scaleStart.x, scaleStart.y, space.width/ratio, space.height/ratio);         
//            glMatrixMode(GL_MODELVIEW);
//            if(from==FROM_IMAGE)
//                glEnable(GL_SCISSOR_TEST);
//            break;
//        case 2://texture full space
//            glBindFramebufferOES(GL_FRAMEBUFFER_OES, textureFrameBuffer);
//            glMatrixMode(GL_PROJECTION); 
//            glLoadIdentity();
//            glOrthof(0, space.width, 0, space.height, -1, 1);
//            glViewport(0, 0, space.width, space.height);         
//            glMatrixMode(GL_MODELVIEW);
//            break;
        case 3://undotexture
            glBindFramebufferOES(GL_FRAMEBUFFER_OES, undoFrameBuffer);
            glMatrixMode(GL_PROJECTION); 
            glLoadIdentity();
            glOrthof(0, size.width, 0, size.height, -1, 1);
            glViewport(scaleStart.x, scaleStart.y, space.width/ratio, space.height/ratio);         
            glMatrixMode(GL_MODELVIEW);
            break;
        case 4://swap to undoTexture
            glBindFramebufferOES(GL_FRAMEBUFFER_OES, undoFrameBuffer);
            glMatrixMode(GL_PROJECTION); 
            glLoadIdentity();
            glOrthof(0, textureSize.width, 0, textureSize.height, -1, 1);
            glViewport(0, 0, textureSize.width, textureSize.height);         
            glMatrixMode(GL_MODELVIEW);
            break;
        case 5://swap to sampleFramebuffer
            glBindFramebufferOES(GL_FRAMEBUFFER_OES, sampleFramebuffer);
            glMatrixMode(GL_PROJECTION);
            glLoadIdentity();
            glOrthof(0, textureSize.width, 0, textureSize.height, -1, 1);
            glViewport(0, 0, textureSize.width, textureSize.height);
            glMatrixMode(GL_MODELVIEW);
            break;
        case 1://texture
            glBindFramebufferOES(GL_FRAMEBUFFER_OES, sampleFramebuffer);
            glMatrixMode(GL_PROJECTION);
            glLoadIdentity();
            glOrthof(0, size.width, 0, size.height, -1, 1);
            glViewport(scaleStart.x, scaleStart.y, space.width/ratio, space.height/ratio);
            glMatrixMode(GL_MODELVIEW);
            if(from==FROM_IMAGE)
                glEnable(GL_SCISSOR_TEST);
            break;
        case 2://texture full space
            glBindFramebufferOES(GL_FRAMEBUFFER_OES, sampleFramebuffer);
            glMatrixMode(GL_PROJECTION);
            glLoadIdentity();
            glOrthof(0, space.width, 0, space.height, -1, 1);
            glViewport(0, 0, space.width, space.height);
            glMatrixMode(GL_MODELVIEW);
            break;
        default:
            break;
    }
    
}

- (void) presentTexture
{
    [self switchMode:NO];    
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glBindTexture(GL_TEXTURE_2D, texture); 
    glDisable(GL_BLEND);         
    
    CGSize size=CGSizeMake(backingWidth, backingHeight);
    GLfloat vertices[] = {
        0, size.height,
        size.width, size.height,
        0,  0,
        size.width,  0,
    };
    CGSize ratio;
    ratio.width=space.width/textureSize.width;
    ratio.height=space.height/textureSize.height;
    CGRect rect=CGRectMake(scaleStart.x/textureSize.width, scaleStart.y/textureSize.height, ratio.width/(maxScale*scale), ratio.height/(maxScale*scale));
    float  textureCoords[] = {
        rect.origin.x, rect.origin.y,
        rect.origin.x+rect.size.width, rect.origin.y,
        rect.origin.x, rect.origin.y+rect.size.height,
        rect.origin.x+rect.size.width, rect.origin.y+rect.size.height
    };
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);        
    GLfloat color[4];
    glGetFloatv(GL_CURRENT_COLOR,color);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);    
    glColor4f(color[0], color[1], color[2], color[3]);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_BLEND);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderBuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (void) resolveSample
{
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, textureFrameBuffer);
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, sampleFramebuffer);
    glResolveMultisampleFramebufferAPPLE();
}

- (void) swapToSample
{
    [self switchMode:5u];
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    CGSize size=textureSize;
    GLfloat vertices[] = {
        0, size.height,
        size.width, size.height,
        0,  0,
        size.width,  0,
    };
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textCoords);
    GLfloat color[4];
    glGetFloatv(GL_CURRENT_COLOR,color);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glColor4f(color[0], color[1], color[2], color[3]);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_BLEND);
}

- (void) swap
{
    [self switchMode:4u];    
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_BLEND);
    glBindTexture(GL_TEXTURE_2D, texture); 
    
    CGSize size=textureSize;
    GLfloat vertices[] = {
        0, size.height,
        size.width, size.height,
        0,  0,
        size.width,  0,
    };
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textCoords);        
    GLfloat color[4];
    glGetFloatv(GL_CURRENT_COLOR,color);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);    
    glColor4f(color[0], color[1], color[2], color[3]);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_BLEND);
}

- (void) refreshTextureSize
{
    CGSize size=paintView.bounds.size;
    size.width*=paintView.contentScaleFactor;
    size.height*=paintView.contentScaleFactor;
    float ratio=size.width/size.height;
    if (globalKit.maxTetureSize.width/globalKit.maxTetureSize.height>ratio) {
        textureSize.height=space.height=globalKit.maxTetureSize.height;
        space.width=ratio*space.height;
        textureSize.width=pow(2.00, ceil(log(ratio*space.height) / log(2.00)));
        maxScale=space.height/size.height;
    }
    else {
        textureSize.width=space.width=globalKit.maxTetureSize.width;
        space.height=space.width/ratio;
        textureSize.height=pow(2.00, ceil(log(space.width/ratio) / log(2.00)));
        maxScale=space.width/size.width;
    }
    scale=1.0/maxScale;    
    clipRect.size=space;
}

- (void) createTexture
{       
    glGenFramebuffersOES(1, &textureFrameBuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, textureFrameBuffer);
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, texture, 0);
    glGenRenderbuffersOES(1, &textureDepthBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, textureDepthBuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, textureSize.width, textureSize.height);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, textureDepthBuffer);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
	}
    
    glClearColor(backColorf[0], backColorf[1], backColorf[2], backColorf[3]);
    glClear(GL_COLOR_BUFFER_BIT);
    
    //undoTexture
    glGenTextures(1, &undoTexture);
    glBindTexture(GL_TEXTURE_2D, undoTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    //glBindFramebufferOES(GL_FRAMEBUFFER_OES, textureFrameBuffer);
    //glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, textureSize.width, textureSize.height, 0);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,  textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glGenFramebuffersOES(1, &undoFrameBuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, undoFrameBuffer);
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, undoTexture, 0);
    glGenRenderbuffersOES(1, &undoDepthBuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, undoDepthBuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, textureSize.width, textureSize.height);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, undoDepthBuffer);
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
    }    

}

- (BOOL)createFrameBuffer
{
	// Generate IDs for a framebuffer object and a color renderbuffer
	glGenFramebuffersOES(1, &viewFrameBuffer);
	glGenRenderbuffersOES(1, &viewRenderBuffer);	
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFrameBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderBuffer);
   // glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(id<EAGLDrawable>)paintView.layer];
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderBuffer);
	
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
	
	glGenRenderbuffersOES(1, &depthRenderBuffer);
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderBuffer);
	glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
	glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderBuffer);
	
	if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
	{
		NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
		return NO;
	}    
	return YES;
}
- (void) createSampleBuffer
{
    glGenFramebuffers(1, &sampleFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, sampleFramebuffer);
    
    glGenRenderbuffers(1, &sampleColorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, sampleColorRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, textureSize.width, textureSize.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, sampleColorRenderbuffer);
    
    glGenRenderbuffers(1, &sampleDepthRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, sampleDepthRenderbuffer);
    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, textureSize.width, textureSize.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, sampleDepthRenderbuffer);
    
    glClearColor(backColorf[0], backColorf[1], backColorf[2], backColorf[3]);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
        
}

// Clean up any buffers we have allocated.
- (void)destroyFrameBuffer
{
	glDeleteFramebuffersOES(1, &viewFrameBuffer);
	viewFrameBuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderBuffer);
	viewRenderBuffer = 0;
	glDeleteRenderbuffersOES(1, &depthRenderBuffer);
    depthRenderBuffer = 0;	
}
- (void) destroyTexture
{
    glDeleteFramebuffersOES(1, &textureFrameBuffer);
	textureFrameBuffer = 0;
	glDeleteRenderbuffersOES(1, &textureDepthBuffer);
    textureDepthBuffer = 0;	
    glDeleteTextures(1, &texture);
    texture=0;
    
    glDeleteFramebuffersOES(1, &undoFrameBuffer);
	undoFrameBuffer = 0;
	glDeleteRenderbuffersOES(1, &undoDepthBuffer);
    undoDepthBuffer = 0;	
    glDeleteTextures(1, &undoTexture);
    undoTexture=0;
    
}

- (void) destroySampleBuffer
{
    glDeleteFramebuffersOES(1, &sampleFramebuffer);
	viewFrameBuffer = 0;
	glDeleteRenderbuffersOES(1, &sampleColorRenderbuffer);
	viewRenderBuffer = 0;
	glDeleteRenderbuffersOES(1, &sampleDepthRenderbuffer);
    depthRenderBuffer = 0;
}

#pragma mark - draw image

-(CGSize) scaleSize:(CGSize) size
{
    float ratio;
    size.width*=paintView.contentScaleFactor;
    size.height*=paintView.contentScaleFactor;
    if ((ratio=size.width/size.height)>textureSize.width/textureSize.height) {
        size.width/=scale;
        size.width=size.width>textureSize.width?textureSize.width:size.width;
        size.height=size.width/ratio;
    }
    else {
        size.height/=scale;
        size.height=size.height>textureSize.height?textureSize.height:size.height;
        size.width=size.height*ratio;
    }
    return size;
}

-(CGSize) logSize:(CGSize)size
{
    size.width=pow(2.00, ceil(log(size.width) / log(2.00)));    
    size.height=pow(2.00, ceil(log(size.height) / log(2.00)));
    size.width=size.width>textureSize.width?textureSize.width:size.width;
    size.height=size.height>textureSize.height?textureSize.height:size.height;
    return size;
}

//read full space
- (TextureData)readImage
{
    TextureData textureData;
    textureData.x=textureData.y=.0f;
    textureData.width=space.width;
    textureData.height=space.height;
    size_t dataLength=textureData.width*textureData.height*4;
    void *newdata=malloc(dataLength);
    if (newdata) {
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, textureFrameBuffer);
        glReadPixels(textureData.x, textureData.y, textureData.width, textureData.height, GL_RGBA, GL_UNSIGNED_BYTE, newdata);
        textureData.data=newdata;
        
    } 
    return textureData;
}

//rect must be  parallel to the x axis
- (TextureData)readImage:(CGRect) rect
{
    TextureData textureData;
    rect.origin=[self transformPoint:rect.origin];
    textureData.x=floorf(rect.origin.x);
    textureData.y=floorf(rect.origin.y);
    if (textureData.x>space.width) {
        textureData.x=space.width;
    }
    if (textureData.y>space.height) {
        textureData.y=space.height;
    }
    textureData.width=ceilf(rect.size.width*(space.width/paintView.bounds.size.width)/(scale*maxScale));
    textureData.height=ceilf(rect.size.height*(space.height/paintView.bounds.size.height)/(scale*maxScale));
    if(textureData.x+textureData.width>space.width)
        textureData.width=space.width-textureData.x;
    if(textureData.y+textureData.height>space.height)
        textureData.height=space.height-textureData.y;
    size_t dataLength=textureData.width*textureData.height*4;
    void *newdata=malloc(dataLength);
    if (newdata) {
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, textureFrameBuffer);
        glReadPixels(textureData.x, textureData.y, textureData.width, textureData.height, GL_RGBA, GL_UNSIGNED_BYTE, newdata);
        textureData.data=newdata;
             
    } 
    return textureData;
}

- (void) writeImage:(TextureData *)textureData
{
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexSubImage2D(GL_TEXTURE_2D, 0,textureData->x, textureData->y, textureData->width, textureData->height, GL_RGBA, GL_UNSIGNED_BYTE, textureData->data);
    [self presentTexture];
}



- (void) drawImage:(UIView*)view points:(CGPoint[4]) points
{
    CGRect rect=view.bounds;
    CGSize size=[self logSize:rect.size];
    //CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, (size_t)size.width, (size_t)size.height, 8, (size_t)size.width * 4, colorspace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    //CGColorSpaceRelease(colorspace);
    if (ctx) {
        [view.layer renderInContext:ctx];
        void *data=CGBitmapContextGetData(ctx);
        [self draw:data size:size points:points mode:1u];
        CGContextRelease(ctx);  
    }
}

- (void) drawImage:(UIImage*)image
{
    CGPoint points[4];
    float width,height;    
    rotated=NO;
    CGSize size=image.size;
    if (size.height<size.width) {
        float temp=size.height;
        size.height=size.width;
        size.width=temp;
        rotated=YES;
    }
    if(size.width/size.height>space.width/space.height)
    {
        width=space.width;
        height=size.height/size.width*width;
    }
    else{
        height=space.height;
        width=size.width/size.height*height;
    }
    points[2].x=(space.width-width)/2,points[2].y=(space.height-height)/2;
    points[3].x=space.width-points[2].x, points[3].y=points[2].y;
    points[0].x=points[2].x, points[0].y=space.height-points[2].y;
    points[1].x=points[3].x, points[1].y=points[0].y; 
    glScissor(points[2].x, points[2].y, width, height);
    clipRect.origin.x=points[2].x;
    clipRect.origin.y=points[2].y;
    clipRect.size.width=width;
    clipRect.size.height=height;
    size=[self logSize:size];
    
    //CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, (size_t)size.width, (size_t)size.height, 8, (size_t)size.width * 4, colorspace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    //CGColorSpaceRelease(colorspace);
    if (ctx) { //CGContextr 
        if(rotated)
        {            
            CGContextTranslateCTM(ctx, 0, size.width);
            CGContextRotateCTM(ctx, -M_PI/2);
        }
        CGContextDrawImage(ctx, CGRectMake(0, 0, size.width, size.height), image.CGImage);
        void *data=CGBitmapContextGetData(ctx);
        [self draw:data size:size points:points mode:2u];
        CGContextRelease(ctx);  
    }
}

- (void) draw:(void *)data size:(CGSize)size points:(CGPoint[4])points mode:(unsigned)mode
{
    GLuint aTexture;
    [self swapToSample];
    [self switchMode:mode];
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glGenTextures(1, &aTexture);
    glBindTexture(GL_TEXTURE_2D, aTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (size_t)size.width, (size_t)size.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    if (mode!=2u) {
        for (int i=0;i<4; ++i) {
            points[i].x*=paintView.contentScaleFactor;
            points[i].y*=paintView.contentScaleFactor;
        }
    }
    
    // left up, right up, left bottom, right bottom 
    GLfloat vertices[] = {
        points[0].x, points[0].y,
        points[1].x, points[1].y,
        points[2].x, points[2].y,
        points[3].x, points[3].y
    };
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textCoords);        
    GLfloat color[4];
    glGetFloatv(GL_CURRENT_COLOR,color);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);   
    glColor4f(color[0], color[1], color[2], color[3]);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDeleteTextures(1, &aTexture);
    
    [self resolveSample];
    
}

#pragma mark - snapshot


- (UIImage*) snapshot:(CGSize)size
{
    UIImage *image=nil;
    CGSize originSize=size;
    if (from==FROM_IMAGE&&rotated) {
        float temp=size.width;
        size.width=size.height;
        size.height=temp;
    }
    GLint width=size.width,height=size.height;
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, undoFrameBuffer);
    //render
    glMatrixMode(GL_PROJECTION); 
    glLoadIdentity();
    glOrthof(0, width, 0, height, -1, 1);
    glViewport(0, 0, width, height);
    glMatrixMode(GL_MODELVIEW);
    //
    glDisable(GL_SCISSOR_TEST);
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glBindTexture(GL_TEXTURE_2D, texture);
    GLfloat vertices[] = {
        0, size.height,
        size.width, size.height,
        0,  0,
        size.width,  0,
    };
    CGSize ratio;
    ratio.width=clipRect.size.width/textureSize.width;
    ratio.height=clipRect.size.height/textureSize.height;
    CGRect rect=CGRectMake(clipRect.origin.x/textureSize.width, clipRect.origin.y/textureSize.height, ratio.width, ratio.height);
    float  textureCoords[] = {
        rect.origin.x, rect.origin.y,
        rect.origin.x+rect.size.width, rect.origin.y,
        rect.origin.x, rect.origin.y+rect.size.height,
        rect.origin.x+rect.size.width, rect.origin.y+rect.size.height
    };   
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);        
    GLfloat color[4];
    glGetFloatv(GL_CURRENT_COLOR,color);
    glColor4f(1.0, 1.0, 1.0, 1.0);
    glDisable(GL_BLEND);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glEnable(GL_BLEND);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glColor4f(color[0],color[1],color[2],color[3]);
    //create image
    size_t dataLength=width*height*4u;
    void *data=malloc(dataLength);
    if (data) {
        glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
        CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data,dataLength , NULL);
        //CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();kCGBitmapByteOrder32Big
        CGImageRef iref = CGImageCreate(width, height, 8u, 32u, width * 4u, colorspace, kCGBitmapByteOrderDefault,
                                        ref, NULL, true, kCGRenderingIntentDefault);
        //CGColorSpaceRelease(colorspace);
        CGDataProviderRelease(ref);
        if (iref) {
            UIGraphicsBeginImageContext(originSize);
            CGContextRef ctx=UIGraphicsGetCurrentContext();
            if (from==FROM_IMAGE&&rotated) {
                CGContextTranslateCTM(ctx, 0, width);
                CGContextRotateCTM(ctx, -M_PI/2);
            }
            CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), iref);
            CGImageRelease(iref);
            image=UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();            
            //data=NULL;
        } 
        free(data);
        
    } 
    return image;
}


- (const float *) getColor:(CGPoint)point
{
    static float components[4];
    static GLubyte data[4];
    point=[self transformPoint:point];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, textureFrameBuffer);
    glReadPixels(point.x, point.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, data);
    for(int i=0;i<4;++i)
    {
        components[i]=data[i]/255.0;
    }
    return components;
}

#pragma mark - transfrom points
- (void) move:(CGPoint)first second:(CGPoint)second
{
    first=[self transformPoint:first];
    second=[self transformPoint:second];
    scaleStart.x-=(second.x-first.x);
    scaleStart.y-=(second.y-first.y);
    scaleStart.x=scaleStart.x<0?0:scaleStart.x;
    scaleStart.y=scaleStart.y<0?0:scaleStart.y;
    [self verifyBounds];
    [self presentTexture];
}
// transform from points in PaintView to space points
- (CGPoint) transformPoint:(CGPoint)point
{
    point.x=scaleStart.x+point.x/scale*paintView.contentScaleFactor;
    point.y=scaleStart.y+point.y/scale*paintView.contentScaleFactor;
    return point;
}
// transform from points in PaintView to texture ratio
-(CGPoint) convertRatio:(CGPoint)point
{
    point=[self transformPoint:point];
    point.x/=space.width;
    point.y/=space.height;
    return point;
}
// get ratio of space to texture
-(CGPoint) getRatio
{
    CGPoint point;
    point.x=space.width/textureSize.width;
    point.y=space.height/textureSize.height;
    return point;
}

//for save

- (int (*)[2]) getMeasure
{
    measure[1][0]=clipRect.size.width;
    measure[1][1]=clipRect.size.height;
    if (from==FROM_IMAGE&&rotated) {
        int temp=measure[1][0];
        measure[1][0]=measure[1][1];
        measure[1][1]=temp;
    }
    measure[0][0]=measure[1][0]/2;
    measure[0][1]=measure[1][1]/2;
    return measure;
}
//for brush adjustment
- (CGPoint)convertPoint:(CGPoint)point size:(float)size lower:(BOOL)lower
{
    size/=scale;
    if (lower) {
        point.x=floorf(point.x-size);
        point.y=floorf(point.y-size);
    }
    else {
        point.x=ceilf(point.x+size);
        point.y=ceilf(point.y+size);
    }
    //
    if (point.x<0) {
        point.x=0;
    }else if(point.x>space.width) {
        point.x=space.width;
    }
    if (point.y<0) {
        point.y=0;
    }else if(point.y>space.height) {
        point.y=space.height;
    }
    
    return point;
}

- (void) dealloc
{
    if([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    
    //[context release];
    //[super dealloc];
}

- (UIImage*) resizeImage:(UIImage*)img
{
    UIImage *image=img;    
    if (img.size.width>space.width||img.size.height>space.height) {
        float ratio;
        CGSize size=img.size;
        if ((ratio=size.width/size.height)>space.width/space.height) {
            size.width=space.width;
            size.height=size.width/ratio;
        }
        else {
            size.height=space.height;
            size.width=size.height*ratio;
        }
        UIGraphicsBeginImageContext(size);
        CGContextRef ctx=UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(ctx, 0.0f, size.height);
        CGContextScaleCTM(ctx, 1.0f, -1.0f);
        CGContextDrawImage(ctx, CGRectMake(0, 0, size.width, size.height), img.CGImage);
        image=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    return image;
}

@end
