//
//  PaintDelegate.h
//  huadufu
//
//  Created by Tianhu Yang on 8/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PaintDelegate <NSObject>
- (void) canZoomIn:(BOOL)can;
- (void) canZoomOut:(BOOL)can;
@end
