//
//  ShapeViewController.h
//  huadufu
//
//  Created by Tianhu Yang on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShapePickerDelegate.h"

@interface ShapeViewController : UIViewController
@property(nonatomic,strong) id<ShapePickerDelegate> shapePickerDelegare;
- (void) setScale:(float)scale opacity:(float)opacity;
@end
