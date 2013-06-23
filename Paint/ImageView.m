//
//  TextView.m
//  GLPaint
//
//  Created by Tianhu Yang on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageView.h"
#import "PaintDraw.h"
#import "PaintView.h"
#import "UndoManager.h"
static const int NONE=0;
static const int MOVE=1;
static const int ZOOM=2;
static const int ROTATE=3;

@interface ImageView()
{
    float markWidth;
    float fillColor[4];
    float borderColor[4];
    int action;
   // float propotion;
    BOOL isDrawing;
    CGPoint points[4];
    CGRect saveRect,imageFrame;
    unsigned imageMode;
}

- (void) draw;
@end

/*** Label start ***/
@interface InnerImageView : UIImageView
{
    ImageView *imageView;
}
@end
@implementation InnerImageView

- (id) initWith:(ImageView*)iv
{
    imageView=iv;
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [imageView draw];     
}

@end
/*** Label end***/

@implementation ImageView
@synthesize  imageView;
@synthesize propotioal;
@synthesize focus;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

-(void) setPropotioal:(BOOL)isPropotioal
{
    propotioal=isPropotioal;
    if (isPropotioal) {
        self.imageView.contentMode=UIViewContentModeScaleAspectFit;
    }
    else {
        self.imageView.contentMode=UIViewContentModeScaleToFill;
    }
}

- (void) initialize
{    
    self.backgroundColor=[UIColor clearColor];
    self.contentMode=UIViewContentModeRedraw;
    self.clipsToBounds=YES;
    CGRect rect=self.bounds;
    markWidth=globalKit.viewMarkWidth;
    rect.origin.x=rect.origin.y=markWidth;
    rect.size.width-=2*markWidth;
    rect.size.height-=2*markWidth;
    imageView=[[[InnerImageView alloc] initWithFrame:rect] initWith:self];
    imageView.backgroundColor=self.backgroundColor;    
    [self addSubview:imageView];
    self.propotioal=true;
    self.userInteractionEnabled=YES;
    fillColor[0]=1;
    fillColor[1]=1;
    fillColor[2]=1;
    fillColor[3]=1;
    
    borderColor[0]=0;
    borderColor[1]=0;
    borderColor[2]=1;
    borderColor[3]=1;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) draw
{
    if (isDrawing) {  
        PaintView *paintView=(PaintView *)self.superview;
        PaintDraw *paintDraw=paintView.paintDraw;
        TextureData textureData=[paintDraw readImage:saveRect];        
        [paintView.undoManager beforeDo:&textureData];
        free(textureData.data);
        //
        [paintDraw drawImage:imageView points:points];
        textureData=[paintDraw readImage:saveRect];
        [paintView.undoManager afterDo:&textureData];
        free(textureData.data);
        isDrawing=NO;
        [self setNeedsLayout];
        [paintDraw presentTexture];
    }
    
}

-(void) layoutSubviews
{
    if (!isDrawing) {
        imageFrame=self.bounds;
        imageFrame.size.width-=2*markWidth;
        imageFrame.size.height-=2*markWidth;        
        imageFrame.origin.x=imageFrame.origin.y=markWidth;
        imageView.frame=imageFrame;
    }
    
}

- (void) setFocus:(BOOL)aFocus
{
    focus=aFocus;
    [self setNeedsDisplay];
}

- (void) begin
{
    PaintView *paintView=(PaintView *)self.superview;
    PaintDraw *paintDraw=paintView.paintDraw;
    paintDraw.drawMode=DRAWMODEIMAGE;
    self.hidden=NO;
}

- (void) end
{  
    self.hidden=YES; 
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (!focus) {
        return;
    }
    unsigned width=16u;
    rect=self.bounds;
    rect.origin.x=rect.origin.y=width;
    rect.size.width-=width;
    rect.size.height-=width;
    width=markWidth-width;
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, .5);
    CGContextSetRGBStrokeColor(ctx, borderColor[0], borderColor[1], borderColor[2], borderColor[3]);
    CGContextSetRGBFillColor(ctx, fillColor[0], fillColor[1], fillColor[2], fillColor[3]);
    CGRect rects[]={CGRectMake(rect.origin.x, rect.origin.y, width, width),
        CGRectMake(rect.size.width-width, rect.size.height-width, width, width),
        CGRectMake(rect.size.width-width, rect.origin.y, width, width),
        CGRectMake(rect.origin.x, rect.size.height-width, width, width)
        
    };
    //rectangle
    CGContextAddRects(ctx, rects,2);
    CGContextFillPath(ctx);
    CGContextAddRects(ctx, rects,2);
    CGContextStrokePath(ctx);
    //circle
    CGContextAddEllipseInRect(ctx, rects[2]);
    CGContextAddEllipseInRect(ctx, rects[3]);
    CGContextFillPath(ctx);
    CGContextAddEllipseInRect(ctx, rects[2]);
    CGContextAddEllipseInRect(ctx, rects[3]);
    CGContextStrokePath(ctx);
    
    
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGRect rect=self.bounds;
    UITouch *touch=[[event touchesForView:self] anyObject];
    CGPoint first0=[touch previousLocationInView:self];
    CGPoint second0=[touch locationInView:self];
    CGPoint first=[self convertPoint:first0 toView:self.superview];
    CGPoint second=[self convertPoint:second0 toView:self.superview]; 
    CGPoint point=self.center;
    float first_sqrt;
    float second_sqrt;
    float sin_theta1;                    
    float sin_theta2;
    switch (action) {
        case MOVE:                       
            point.x+=second.x-first.x;
            point.y+=second.y-first.y;
            self.center=point;
            break;
        case ZOOM:
            if (first0.x>markWidth) {
                rect.size.width+=second0.x-first0.x;
                rect.size.height+=second0.y-first0.y;
            }
            else {
                rect.size.width-=second0.x-first0.x;
                rect.size.height-=second0.y-first0.y;
            }
            
            if (rect.size.width<=2*markWidth||rect.size.height<=2*markWidth) {
                break;
            }
            point.x=(second.x-first.x)/2;
            point.y=(second.y-first.y)/2;
            point.x+=self.center.x;
            point.y+=self.center.y;
            self.center=point;
            self.bounds=rect;
            break;        
        case ROTATE:            
            first_sqrt=sqrtf((point.x-first.x)*(point.x-first.x)+(point.y-first.y)*(point.y-first.y));
            second_sqrt=sqrtf((point.x-second.x)*(point.x-second.x)+(point.y-second.y)*(point.y-second.y));
            sin_theta1=(first.x-point.x)/first_sqrt;                    
            sin_theta2=(second.x-point.x)/second_sqrt;
            if (first.y-point.y<0) {
                sin_theta1=asinf(sin_theta1);
            }
            else {
                sin_theta1=acosf(sin_theta1);
                sin_theta1+=M_PI/2;
            }
            if (second.y-point.y<0) {
                sin_theta2=asinf(sin_theta2);
            }
            else {
                sin_theta2=acosf(sin_theta2);
                sin_theta2+=M_PI/2;
            }
            
            self.transform=CGAffineTransformConcat(self.transform, CGAffineTransformMakeRotation(sin_theta2-sin_theta1)) ;
            break;
        default:
            break;
    }

}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.focus=YES;
    UITouch *touch=[[event touchesForView:self] anyObject];
    CGPoint point=[touch locationInView:self];
    CGRect rect=self.bounds;
    rect.origin.x+=markWidth;
    rect.origin.y+=markWidth;
    rect.size.width-=2*markWidth;
    rect.size.height-=2*markWidth;
    action=NONE;
    if (CGRectContainsPoint(rect, point)) {
        action=MOVE;
    }
    else {
        //left up
        rect=self.bounds;
        rect.size.width=rect.size.height=markWidth;
        if (CGRectContainsPoint(rect, point)) {
            action=ZOOM;
        }
        else {
            //right bottom
            rect=self.bounds;
            rect.origin.x=rect.size.width-markWidth;
            rect.origin.y=rect.size.height-markWidth;
            rect.size.width=rect.size.height=markWidth;
            if (CGRectContainsPoint(rect, point)) {
                action=ZOOM;
            }
            else {
                //right up
                rect=self.bounds;
                rect.origin.x=rect.size.width-markWidth;
                rect.size.width=rect.size.height=markWidth;
                if (CGRectContainsPoint(rect, point)) {
                    action=ROTATE;
                }else {
                    //left bottom
                    rect=self.bounds;
                    rect.origin.y=rect.size.height-markWidth;
                    rect.size.width=rect.size.height=markWidth;
                    if (CGRectContainsPoint(rect, point)) {
                        action=ROTATE;
                    }
                }
            }
        }
    }
}
- (void) drawImage
{    
    //convert to paintView points
    
    PaintDraw *paintDraw=((PaintView *)self.superview).paintDraw;    
    isDrawing=YES;
    
    CGRect rect=imageFrame;
    saveRect=[self convertRect:rect toView:self.superview];
    if (saveRect.origin.x<0) {
        saveRect.origin.x=0;
    }
    if (saveRect.origin.y<0) {
        saveRect.origin.y=0;
    }
    if (saveRect.origin.x+saveRect.size.width>self.superview.bounds.size.width) {
        saveRect.size.width=self.superview.bounds.size.width-saveRect.origin.x;
    }
    if (saveRect.origin.y+saveRect.size.height>self.superview.bounds.size.height) {
        saveRect.size.height=self.superview.bounds.size.height-saveRect.origin.y;
    }            
    CGPoint point=rect.origin;
    CGSize nowSize=rect.size;
    rect.size=[paintDraw scaleSize:rect.size];
    CGSize size=[paintDraw logSize:rect.size];
    size.width=size.width/rect.size.width*nowSize.width+point.x;
    size.height=size.height/rect.size.height*nowSize.height+point.y;
    points[0]=[self convertPoint:point toView:self.superview];
    point.x=size.width;
    points[1]=[self convertPoint:point toView:self.superview];
    point=rect.origin;
    point.y=size.height;
    points[2]=[self convertPoint:point toView:self.superview];
    point.x=size.width;
    points[3]=[self convertPoint:point toView:self.superview];    
    rect.origin.x=rect.origin.y=0;
    imageView.bounds=rect;     
    [imageView setNeedsLayout];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
