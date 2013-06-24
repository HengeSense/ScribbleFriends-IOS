//
//  FBNewsViewController.h
//  ScribbleFriends
//
//  Created by Tianhu Yang on 1/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBNewsDelegate.h"

@interface FBNewsViewController : UIViewController
@property(nonatomic,strong) id<FBNewsDelegate> fbNewsDelegate;
+ (FBNewsViewController*) defaultNewsViewController;
@end
