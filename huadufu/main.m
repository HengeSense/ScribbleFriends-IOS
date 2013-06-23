//
//  main.m
//  huadufu
//
//  Created by Tianhu Yang on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
GlobalKit *globalKit;
int main(int argc, char *argv[])
{
    globalKit=[[GlobalKit alloc] init];
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
