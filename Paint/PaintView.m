//
//  PaintView.m
//  GLPaint
//
//  Created by Tianhu Yang on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaintView.h"
@interface PaintView()<ChangeDelegate>
{       
    int mode;
}

@end
@implementation PaintView

@synthesize paintDraw;
@synthesize brush;
@synthesize paintTouch;
@synthesize textView;
@synthesize imageView;
@synthesize sketchView;
@synthesize absorbView;
@synthesize undoManager;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}


- (void) drawRect:(CGRect)rect
{
    
}

- (id)initWithCoder:(NSCoder*)coder {	
    
    if ((self = [super initWithCoder:coder])) {        
        
        //self.contentScaleFactor = 1.0; 
        paintDraw=[[PaintDraw alloc] initWith:self];
        brush=[[Brush alloc] initWith:self];
        paintTouch=[[PaintTouch alloc] initWith:self];
        undoManager=[[UndoManager alloc] initWith:self];
        undoManager.changeDelegate=self;
        CGRect rect=CGRectMake(0, 0, 200, 200);
        textView=[[TextView alloc] initWithFrame:rect]; 
        textView.center=self.center;
        
        imageView=[[ImageView alloc] initWithFrame:rect];
        imageView.imageView.image=[UIImage imageNamed:@"test.png"];
        imageView.center=self.center;     
        
        absorbView=[[AbsorbView alloc] initWithFrame:rect];
        absorbView.center=self.center;
        
        rect=globalKit.sketchViewRect;
        rect.size.height=rect.size.width*self.bounds.size.height/
        self.bounds.size.width;
        rect.size.width+=2;
        rect.size.height+=2;
        sketchView=[[SketchView alloc] initWithFrame:rect];

        [self addSubview:textView];textView.hidden=true;
        [self addSubview:imageView];imageView.hidden=true;
        [self addSubview:sketchView];sketchView.hidden=true;
        [self addSubview:absorbView];absorbView.hidden=true;
	}
	
	return self;
}

-(void)layoutSubviews
{
    //[paintDraw resize];
}

// Releases resources when they are not longer needed.
- (void) dealloc
{	
	//[super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    textView.focus=NO;
    imageView.focus=NO;
    [paintTouch touchesBegan:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [paintTouch touchesMoved:touches withEvent:event];
    if (paintDraw.drawMode==DRAWMODEZOOM) {
        [sketchView update];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [paintTouch touchesEnded:touches withEvent:event];
}

- (void) clear:(UIImage *)image
{
    /*TextureData textureData=[paintDraw readImage];        
    [self.undoManager beforeDo:&textureData];
    free(textureData.data);*/
    //
    [paintDraw clear:image];  
    [paintDraw presentTexture];
    /*textureData=[paintDraw readImage];
    [self.undoManager afterDo:&textureData];
    free(textureData.data);*/
}

- (void) didChanged
{
    if(paintDraw.drawMode==DRAWMODEZOOM)
        [sketchView use];
}

- (void) drawImage:(UIImage*)image
{

    [paintDraw clear:image]; 
    [paintDraw presentTexture];    
}

- (void)switch:(int)aMode
{        
    switch (mode) {    
    case 1://pencil
        break;
    case 2://eraser
        break;
    case 3://zoom
        self.sketchView.hidden=YES;
        break;   
    default:
        break;
    }
if(aMode>-1)//none
{
    if(aMode!=0)//revert
    {
        mode=aMode; 
    }
    else {
        aMode=mode;
    }
    
    switch (mode) {
            
        case 1://pencil
            paintDraw.drawMode=DRAWMODEDRAW;
            self.brush.brushMode=BRUSH_PENCIL;
            break;
        case 2://eraser
            paintDraw.drawMode=DRAWMODEDRAW;
            self.brush.brushMode=BRUSH_ERASER;
            break;
        case 3://zoom
            self.sketchView.hidden=NO;
            paintDraw.drawMode=DRAWMODEZOOM;
            [sketchView use];
            break;
        case 6://absorb
            self.paintDraw.drawMode=DRAWMODEABSORB;
            [absorbView use];
            break;
        default:
            break;
    }
}
   
}

- (void) operate:(unsigned)type
{
    switch (type) {
        case 20://zoom out
            [paintDraw zoomIn:NO];
            [sketchView update];
            [paintDraw presentTexture];
            break;
        case 21://zoom in
            [paintDraw zoomIn:YES];
            [sketchView update];
            [paintDraw presentTexture];
            break; 
        case 23://clear
            
            break;
        default:
            break;
    }
}


@end
