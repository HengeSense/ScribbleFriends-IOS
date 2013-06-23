//
//  TextPickerDelegate.h
//  huadufu
//
//  Created by Tianhu Yang on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TextPickerDelegate <NSObject>
- (void) pickedText:(NSString *)text font:(NSString *)font;
@end
