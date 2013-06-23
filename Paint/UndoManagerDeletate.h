//
//  UndoManagerDeletate.h
//  huadufu
//
//  Created by Tianhu Yang on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UndoManagerDeletate <NSObject>
- (void)canUndo:(BOOL)yes;
- (void)canRedo:(BOOL)yes;
@end
