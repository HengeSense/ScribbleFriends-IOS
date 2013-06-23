//
//  TextPickerViewController.h
//  huadufu
//
//  Created by Tianhu Yang on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextPickerDelegate.h"

@interface TextPickerViewController : UIViewController<UITextFieldDelegate>

@property(nonatomic,strong) id<TextPickerDelegate> textPickerDelegate;
- (void) setText:(NSString *)text font:(NSString*)font;
@end
