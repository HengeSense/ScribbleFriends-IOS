//
//  Text.m
//  GLPaint
//
//  Created by Tianhu Yang on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageKit.h"
#import "PaintView.h"
#import "PaintDraw.h"
#import <MobileCoreServices/UTCoreTypes.h>
static float const textureCoords[] = {
    0, 0,
    1, 0,
    0, 1,
    1, 1,
};
@interface ImageKit()
{
    PaintView *paintView;    
    
    
}
@end

@implementation ImageKit

- (id) initWith:(PaintView *)pv
{
    paintView=pv;
  // [self drawImage:[UIImage imageNamed:@"test.png"] rect:CGRectMake(0, 0, 5120, 7680)];
  //  [self drawText:@"Chinese" rect:CGRectMake(200, 400, 512*4, 512)];
    return self;
}

- (void) drawImage:(UIImage*)image rect:(CGRect) rect
{
    float width=pow(2.00, ceil(log(image.size.width) / log(2.00)));    
    float height=pow(2.00, ceil(log(image.size.height) / log(2.00)));
    width=width>globalKit.maxTetureSize.width?globalKit.maxTetureSize.width:width;
    height=height>globalKit.maxTetureSize.height?globalKit.maxTetureSize.height:height;
    CGContextRef ctx = CGBitmapContextCreate(nil, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (ctx) {
        CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), image.CGImage);
        GLuint texture;
       // [paintView switchToTexture:YES];
        glEnable(GL_TEXTURE_2D);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, CGBitmapContextGetData(ctx));
        CGContextRelease(ctx);
        GLfloat vertices[] = {
            rect.origin.x, rect.origin.y,
            rect.size.width+rect.origin.x, rect.origin.y,
            rect.origin.x,  rect.origin.y+rect.size.height,
            rect.size.width+rect.origin.x,  rect.origin.y+rect.size.height,
        };
        glVertexPointer(2, GL_FLOAT, 0, vertices);
        glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);        
        GLfloat color[4];
        glGetFloatv(GL_CURRENT_COLOR,color);
        glColor4f(1.0, 1.0, 1.0, 1.0);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);   
        
        glColor4f(color[0], color[1], color[2], color[3]);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        glDeleteTextures(1, &texture);
    }
}


- (void) drawText:(NSString *)text rect:(CGRect)rect
{
    float width=pow(2.00, ceil(log(rect.size.width) / log(2.00)));    
    float height=pow(2.00, ceil(log(rect.size.height) / log(2.00)));
    width=width>2048?2048:width;
    height=height>2048?2048:height;
    float fontsize=height;
    CGContextRef ctx = CGBitmapContextCreate(nil, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    if (ctx) {
        CGContextSetRGBFillColor( ctx, 0.8f, 0.8f, 0.8f, 1.0f);
        CGContextFillRect(ctx, CGRectMake(0.0f, 0.0f, width, height));        
        //CGContextSelectFont(ctx, "Helvetica Bold", fontsize, kCGEncodingMacRoman);
        NSString *fontName= @"Helvetica-Bold";
        CGFontRef font=CGFontCreateWithFontName((__bridge CFStringRef)fontName);
        CGContextSetFont(ctx, font);
        CGContextSetFontSize(ctx, fontsize);
        CGFontRelease(font);
        CGContextSetTextDrawingMode(ctx, kCGTextFill);
        //CGContextSetTextMatrix(ctx, CGAffineTransformMake(-1, 0, 0, 1, 1, 1));
        CGContextSetRGBStrokeColor( ctx, 1.0f, 1.0f, 0.0f, 1.0f);
        CGContextSetRGBFillColor( ctx, 1.0f, 0.0f, 0.0f, 1.0f);
        CGContextShowTextAtPoint( ctx, 0, .125f*height, text.UTF8String, text.length);        
        GLuint texture;
        //[PaintDraw switchToTexture:YES];
        glEnable(GL_TEXTURE_2D);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, CGBitmapContextGetData(ctx));
        CGContextRelease(ctx);
        GLfloat vertices[] = {
            rect.origin.x, rect.origin.y,
            rect.size.width+rect.origin.x, rect.origin.y,
            rect.origin.x,  rect.origin.y+rect.size.height,
            rect.size.width+rect.origin.x,  rect.origin.y+rect.size.height,
        };
        glVertexPointer(2, GL_FLOAT, 0, vertices);
        glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);        
        GLfloat color[4];
        glGetFloatv(GL_CURRENT_COLOR,color);
        glColor4f(1.0, 1.0, 1.0, 1.0);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);   
        
        glColor4f(color[0], color[1], color[2], color[3]);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        glDeleteTextures(1, &texture);
    }

}


@end
