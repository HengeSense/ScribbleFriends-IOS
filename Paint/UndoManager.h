//
//  UndoManager.h
//  GLPaint
//
//  Created by Tianhu Yang on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintDraw.h"
#import "UndoManagerDeletate.h"
#import "ChangeDelegate.h"

@class PaintView;
@interface UndoManager : NSObject
@property(nonatomic,strong) id<UndoManagerDeletate> undoManagerDelegate;
@property(nonatomic,strong) id<ChangeDelegate> changeDelegate;
- (id) initWith:(PaintView*)pv;
- (void) beforeDo:(TextureData *)textureData;
- (void) afterDo:(TextureData *)textureData;
- (BOOL) redo;
- (BOOL) undo;
@end

