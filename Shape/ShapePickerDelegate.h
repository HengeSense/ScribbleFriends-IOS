//
//  ShapePickerDelegate.h
//  huadufu
//
//  Created by Tianhu Yang on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ShapePickerDelegate <NSObject>
-(void) picked:(float)size opacity:(float)opacity;
@end
