//
//  DynamicArray.m
//  huadufu
//
//  Created by Tianhu Yang on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DynamicArray.h"
#define MAXSIZE 1024U*1024U
@interface DynamicArray()
{
    unsigned size;
}
@end
@implementation DynamicArray
@synthesize points;
@synthesize length;
- (id)init
{
    [self clear];
    return self;
}
- (void) clear
{
    length=0U;
    if (size==64U) {
        return;
    }
    if (points) {
        free(points);
    }
    size=64U;
    points=malloc(size*sizeof(CGPoint));
    if (!points) {
        size=0u;
    }
    
}
- (BOOL) addPoint:(CGPoint)point
{
    CGPoint *pp;
    unsigned resize;
    if (length>=size) {
        resize=size<<1;
        if (MAXSIZE<resize) {
            return NO;
        }
        pp=realloc(points, resize*sizeof(CGPoint));
        if (!pp) {
            return NO;
        }
        size=resize;
        points=pp;
    }
    points[length]=point;
    ++length;
    return YES;
}
@end
