//
//  SaveViewController.h
//  huadufu
//
//  Created by Tianhu Yang on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveDelagate.h"

@interface SaveViewController : UIViewController
@property(nonatomic,strong) id<SaveDelagate> saveDelegate;
@property(nonatomic) int(*measure)[];
@property(nonatomic,assign) unsigned saveMode;
@end
