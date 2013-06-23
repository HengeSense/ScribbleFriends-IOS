//
//  ColorPickerDelegate.h
//  huadufu
//
//  Created by Tianhu Yang on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ColorPickerDelegate <NSObject>
- (void) pickedColor:(UIColor*)color;
@end
