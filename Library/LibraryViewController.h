//
//  LibraryViewController.h
//  huadufu
//
//  Created by Tianhu Yang on 1/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LibraryDelegate.h"

@interface LibraryViewController : UIViewController
@property(strong,nonatomic)  id<LibraryDelegate> libraryDelegate;
@end
