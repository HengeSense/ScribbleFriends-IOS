//
//  FBNewsHandler.h
//  scribble
//
//  Created by Tianhu Yang on 1/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FBNewsHandlerDelegate <NSObject>

- (void) onLoadData:(NSArray*)data;

@end

@interface FBNewsHandler : NSObject

@property(nonatomic, weak) id<FBNewsHandlerDelegate> delegate;

- (void) requestNewsSession;

@end
