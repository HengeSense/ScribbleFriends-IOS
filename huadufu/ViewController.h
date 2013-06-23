//
//  ViewController.h
//  huadufu
//
//  Created by Tianhu Yang on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintView.h"
#import "ILColorPickerController.h"

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *toolBarView;
@property (strong, nonatomic) IBOutlet PaintView *paintView;
@property (strong, nonatomic) IBOutlet UIView *zoomButtonView;
@property (strong, nonatomic) IBOutlet UIView *imageToolbarView;
@property (nonatomic,assign) unsigned colorMode,alphaMode,textMode;
@property(nonatomic,strong) ILColorPickerController *ilcpc;
@property (strong, nonatomic) IBOutlet UISlider *alphaSlider;
- (void) switch:(int)aMode;
@end
