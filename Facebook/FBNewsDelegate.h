//
//  FBNewsDelegate.h
//  ScribbleFriends
//
//  Created by Tianhu Yang on 1/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FBNewsDelegate <NSObject>
- (void) pickedPath:(NSString*)path;
@end
