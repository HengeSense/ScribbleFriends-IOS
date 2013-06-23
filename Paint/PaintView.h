//
//  PaintView.h
//  GLPaint
//
//  Created by Tianhu Yang on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Brush.h"
#import "ImageView.h"
#import "TextView.h"
#import "PaintDraw.h"
#import "PaintTouch.h"
#import "SketchView.h"
#import "AbsorbView.h"
#import "UndoManager.h"
#import "ColorPickerDelegate.h"

@interface PaintView : UIView
{
}

@property(nonatomic,strong) PaintDraw *paintDraw;
@property(nonatomic,strong) Brush *brush;
@property(nonatomic,strong) PaintTouch *paintTouch;
@property(nonatomic,strong) TextView *textView;
@property(nonatomic,strong) ImageView *imageView;
@property(nonatomic,strong) SketchView *sketchView;
@property(nonatomic,strong) AbsorbView *absorbView;
@property(nonatomic,strong) UndoManager *undoManager;

- (void) switch:(int)mode;
- (void) operate:(unsigned)type;
- (void) clear:(UIImage *)image;
- (void) drawImage:(UIImage*)image;
@end
