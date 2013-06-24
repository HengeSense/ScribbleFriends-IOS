//
//  Brush.m
//  GLPaint
//
//  Created by Tianhu Yang on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Brush.h"
#import "PaintDraw.h"
#import "PaintView.h"
#import "UndoManager.h"
#import "DynamicArray.h"
#define defaultOpacity		0.5f
#define defaultPixelStep		1.0f

const int BRUSH_PENCIL=0;
const int BRUSH_BRUSH=1;
const int BRUSH_ERASER=2;



@interface Brush()
{
    size_t textureWidth;
    PaintDraw *paintDraw;
    float pointSize;
    CGPoint lowerPoint,upperPoint;
    float lineWidth;
    float colorf[4];
}

@end


@implementation Brush

@synthesize opacity;
@synthesize pixelStep;
@synthesize brushScale;
@synthesize textureIndex;
@synthesize brushMode;
@synthesize brushColor,color;

-(id) initWith:(PaintView *)pv
{
    paintView=pv; 
    paintDraw=pv.paintDraw;
    
    //default start
    self.opacity=defaultOpacity;
    self.pixelStep=defaultPixelStep;
    self.brushScale=5.0f;
    //default end
    
    //self.textureIndex=0;
    colorf[3]=0.5;
    self.brushColor=[UIColor redColor];    
    self.brushMode=BRUSH_PENCIL;
    return self;
}

- (void) setOpacity:(GLfloat)aOpacity
{
    colorf[3]=aOpacity;
    if (brushMode==BRUSH_PENCIL) {
        glColor4f(colorf[0]*colorf[3],
                  colorf[1]*colorf[3],
                  colorf[2]*colorf[3],
                  colorf[3]);
    }
    
}

- (float) opacity
{
    return colorf[3];
}

- (void) setBrushScale:(GLfloat)aBrushScale
{    
    brushScale=aBrushScale;
    lineWidth=brushScale;
    pointSize=brushScale;
    glPointSize(pointSize);
}

- (void) setBrushColor:(UIColor *)aBrushColor
{
    CGColorRef colorRef=aBrushColor.CGColor;
    const float *comp=CGColorGetComponents(colorRef);  
    memcpy(colorf, comp, 3U*sizeof(float));
    if (brushMode==BRUSH_PENCIL) {
        glColor4f(colorf[0]*colorf[3], colorf[1]*colorf[3], colorf[2]*colorf[3],colorf[3]);
    }    
    brushColor=aBrushColor;
}
- (void) setColor:(UIColor *)aColor
{
    CGColorRef colorRef=aColor.CGColor;
    const float *comp=CGColorGetComponents(colorRef); 
    memcpy(colorf, comp, 4U*sizeof(float));
    color=aColor;
}

-(void) setBrushMode:(int)aBrushMode
{
    float *backColor=paintDraw.backColor;
    brushMode=aBrushMode;
    switch (brushMode) {
        case BRUSH_PENCIL:
            glColor4f(colorf[0]*colorf[3],
                      colorf[1]*colorf[3],
                      colorf[2]*colorf[3],
                      colorf[3]);
            break;
        case BRUSH_BRUSH:
            //glEnable(GL_TEXTURE_2D);
            break;
        case BRUSH_ERASER:
            glColor4f(backColor[0],
                      backColor[1],
                      backColor[2],
                      backColor[3]);
            break;
        default:
            break;
    }
}

- (void) setTextureIndex:(int)index
{
    
    CGImageRef		brushImage;
	CGContextRef	brushContext;
	GLubyte			*brushData;
	size_t			width, height;
    UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"Particle%d.png",index]];            
    if(image) {
        brushImage = image.CGImage;
        textureWidth= width = CGImageGetWidth(brushImage);
        height = CGImageGetHeight(brushImage); 
        brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
        brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
        CGContextRelease(brushContext);
        glGenTextures(1, &brushTexture);
        glBindTexture(GL_TEXTURE_2D, brushTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        free(brushData);
        textureIndex=index;
    } 
}

- (void) dealloc
{
	if (brushTexture)
	{
		glDeleteTextures(1, &brushTexture);
		brushTexture = 0;
	}
}

// Drawings a line onscreen based on where the user touches
- (void) renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end
{	
	/*[paintDraw switchToTexture:NO];
    CGPoint first=start,second=end;
    float height=paintView.bounds.size.height;
    first.y=height-first.y;
    second.y=height-second.y;
    [self drawSolidLine:first third:second];
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, paintDraw.viewRenderBuffer);
    [paintDraw.context presentRenderbuffer:GL_RENDERBUFFER_OES];*/
    //
    [paintDraw switchMode:1];
    [self updatePoint:start];
    [self updatePoint:end];
    start.x*=paintView.contentScaleFactor;
    start.y*=paintView.contentScaleFactor;
    end.x*=paintView.contentScaleFactor;
    end.y*=paintView.contentScaleFactor;
	[self drawSolidLine:start third:end];
    [paintDraw resolveSample];
    [paintDraw presentTexture];
	
}

- (void) drawBegan:(CGPoint)loc
{
    lowerPoint.x=MAXFLOAT;
    lowerPoint.y=MAXFLOAT;
    upperPoint.x=0;
    upperPoint.y=0;           
    [self prepare];    
}

- (void) prepare
{
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, paintDraw.sampleFramebuffer);
    glClear(GL_DEPTH_BUFFER_BIT);
    [paintDraw swap];
    [paintDraw swapToSample];
}

- (void) drawDot:(CGPoint)loc
{
    glDisable(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);
    [paintDraw switchMode:1];
    [self updatePoint:loc]; 
    float width=lineWidth*paintDraw.maxScale*paintDraw.scale;
    loc.x*=paintView.contentScaleFactor;
    loc.y*=paintView.contentScaleFactor;
    [self drawArc:width*M_PI x:loc.x y:loc.y r:width/2.0f];
    glDisable(GL_DEPTH_TEST);
    [paintDraw resolveSample];
    [paintDraw presentTexture];
}

- (void) drawEnded:(CGPoint)loc
{
    [self drawDot:loc];
    CGPoint lower=lowerPoint,upper=upperPoint; 
    float widthf=lineWidth*paintDraw.maxScale*paintDraw.scale;
    lower=[paintDraw convertPoint:lower size:widthf lower:YES];
    upper=[paintDraw convertPoint:upper size:widthf lower:NO];
    GLuint x=lower.x,y=lower.y;
    GLuint x1=upper.x,y1=upper.y;
    GLuint width=x1-x,height=y1-y;
    unsigned length=width*height*4;
    void *data=malloc(length);
    if (data) {
        TextureData textureData;
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, paintDraw.undoFrameBuffer);
        
        glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
        textureData.x=x;
        textureData.y=y;
        textureData.width=width;
        textureData.height=height;
        textureData.data=data;
        [paintView.undoManager beforeDo:&textureData];
        //
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, paintDraw.textureFrameBuffer);;
        glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
        [paintView.undoManager afterDo:&textureData];
        free(data);
    } 
    
}
- (void) drawFrom:(CGPoint)from to:(CGPoint)to
{
    [self renderLineFromPoint:from toPoint:to];    
    // printf("drawing\n");
}

- (void) updatePoint:(CGPoint)point
{
    point=[paintDraw transformPoint:point];
    if(lowerPoint.x>point.x)
        lowerPoint.x=point.x;
    if(lowerPoint.y>point.y)
        lowerPoint.y=point.y;
    if(upperPoint.x<point.x)
        upperPoint.x=point.x;
    if(upperPoint.y<point.y)
        upperPoint.y=point.y;
}

-(void)drawArc:(unsigned int const)segments x:(float)x y:(float)y r:(float)r
{
    int i;
    float const angle_step = 2*M_PI /segments;
    
    GLfloat *arc_vertices;
    arc_vertices = malloc(2*sizeof(GLfloat) * (segments+2));
    if (!arc_vertices) {
        return;
    }
    arc_vertices[0] = x;
    arc_vertices[1] = y;
    
    for(i=0; i<segments+1; i++) {
        arc_vertices[2 + 2*i    ] = x + r*cos(i*angle_step);
        arc_vertices[2 + 2*i + 1] = y + r*sin(i*angle_step);
    }
    //printf("%f %f %f\n",x,y,r);
    glVertexPointer(2, GL_FLOAT, 0, arc_vertices);
    glDrawArrays(GL_TRIANGLE_FAN, 0, segments+2);    
    free(arc_vertices);
}


-(void)drawSolidLine:(CGPoint)second third:(CGPoint)third
{
    GLfloat lineVertices[8],width=lineWidth*paintDraw.maxScale*paintDraw.scale; 
    CGPoint dir, tan;    
    //
    dir.x = third.x - second.x;
    dir.y = third.y - second.y;
    float len = sqrtf(dir.x*dir.x+dir.y*dir.y);
    if(len>0.00001f)
    {
        dir.x = dir.x/len;
        dir.y = dir.y/len;
        tan.x = -width*dir.y/2.0f;
        tan.y = width*dir.x/2.0f;
    }
    else {
        return;
    }
    lineVertices[0] = second.x + tan.x;//B
    lineVertices[1] = second.y + tan.y;
    lineVertices[2] = second.x-tan.x;
    lineVertices[3] = second.y-tan.y;
    lineVertices[4] = third.x+tan.x;//D
    lineVertices[5] = third.y+tan.y;
    lineVertices[6] = third.x-tan.x;
    lineVertices[7] = third.y-tan.y;
    glDisable(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);
    glVertexPointer(2, GL_FLOAT, 0, lineVertices);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self drawArc:width*M_PI x:second.x y:second.y r:width/2.0f];
    glDisable(GL_DEPTH_TEST);
}

@end
