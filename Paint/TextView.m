//
//  TextView.m
//  GLPaint
//
//  Created by Tianhu Yang on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextView.h"
#import "PaintDraw.h"
#import "PaintView.h"
#import "UndoManager.h"
static const int NONE=0;
static const int MOVE=1;
static const int ZOOM=2;
static const int ROTATE=3;

@interface TextView()
{
    float markWidth;
    float fillColor[4];
    float borderColor[4];
    int action;
    BOOL isDrawing;
    CGPoint points[4];  
    CGRect saveRect,labelFrame;
}

- (void) draw;
@end

/*** Label start ***/
@interface Label : UILabel
@property(nonatomic,strong) TextView *textView;
@end
@implementation Label
@synthesize textView;
-(id) initWith:(TextView*)tv
{
    self.textView=tv;
    self.contentMode=UIViewContentModeRedraw;
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.font=[UIFont fontWithName:self.font.fontName size:self.bounds.size.height*.8f];
    [textView draw];       
}

- (void) drawRect:(CGRect)area
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    
    [super drawRect:area];
    // We have to turn it back off since it's not saved in graphic state.
    CGContextSetAllowsAntialiasing(context, false);
    CGContextRestoreGState(context);
}

@end
/*** Label end***/



@implementation TextView
@synthesize  label;
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

- (void) initialize
{   
    
    self.backgroundColor=[UIColor clearColor];
    self.contentMode=UIViewContentModeRedraw;
    //self.clipsToBounds=YES;
    focus=YES;
    CGRect rect=self.bounds;
    markWidth=globalKit.viewMarkWidth;
    rect.origin.x=rect.origin.y=markWidth;
    rect.size.width-=2*markWidth;
    rect.size.height-=2*markWidth;
    label=[[[Label alloc] initWithFrame:rect] initWith:self];
    label.backgroundColor=self.backgroundColor;
    label.lineBreakMode=UILineBreakModeCharacterWrap;
    label.textColor=[UIColor purpleColor];
    //label.text=@"中国人民";
    [self addSubview:label];
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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code  
    if (!focus) {
        return;
    }
    unsigned width=markWidth/2.0f;
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

- (void) begin
{    
    PaintView *paintView=(PaintView *)self.superview;
    PaintDraw *paintDraw=paintView.paintDraw;
    paintDraw.drawMode=DRAWMODETEXT;
    self.hidden=NO;
}

- (void) end
{  
    self.hidden=YES; 
}

- (void) setText:(NSString *)text font:(NSString*)fontName
{
    self.label.text=text;
    self.label.font=[UIFont fontWithName:fontName size:label.bounds.size.height*.8f];
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
        [paintDraw drawImage:label points:points];
        //[paintDraw presentTexture];
        textureData=[paintDraw readImage:saveRect];
        [paintView.undoManager afterDo:&textureData];
        free(textureData.data); 
        isDrawing=NO;
        [self setNeedsLayout];
        [paintDraw presentTexture];
    }
    
    
}

- (void) setFocus:(BOOL)aFocus
{
    focus=aFocus;
    [self setNeedsDisplay];
}

-(void) layoutSubviews
{
    if (!isDrawing) {
        labelFrame=self.bounds;
        labelFrame.size.width-=2*markWidth;
        labelFrame.size.height-=2*markWidth; 
        labelFrame.origin.x=labelFrame.origin.y=markWidth;
        label.frame=labelFrame;
    }    
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
            
            self.transform=CGAffineTransformConcat(self.transform, CGAffineTransformMakeRotation(sin_theta2-sin_theta1));
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

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void) drawImage
{   
    isDrawing=YES;
    PaintDraw *paintDraw=((PaintView *)self.superview).paintDraw;    
    
    CGRect rect=labelFrame;
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
    label.bounds=rect;
    [label setNeedsLayout];
}

@end
