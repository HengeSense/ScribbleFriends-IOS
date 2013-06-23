//
//  ImagePicker.h
//  huadufu
//
//  Created by Tianhu Yang on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

#define NEWMODEBACKGROUND 0
#define NEWMODEIMAGE 1

@interface ImagePicker : NSObject<UIAlertViewDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate>
@property(nonatomic,assign) unsigned imageMode,newMode,imageSubMode;
-(id) initWith:(ViewController*)vc;
-(void) beginPicking;
-(void) clear;
- (void) pickedImage:(UIImage*)image;
@end
