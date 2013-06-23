//
//  DynamicArray.h
//  huadufu
//
//  Created by Tianhu Yang on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DynamicArray : NSObject
@property(nonatomic,assign,readonly) CGPoint *points;
@property(nonatomic,assign,readonly) unsigned length;
- (BOOL) addPoint:(CGPoint)point;
- (void) clear;
@end
