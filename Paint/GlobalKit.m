//
//  GlobalKit.m
//  GLPaint
//
//  Created by Tianhu Yang on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GlobalKit.h"

@interface GlobalKit()
{
    float initBackColorf[4];
}

@end
@implementation GlobalKit
@synthesize isiPhone;
@synthesize maxTetureSize;
@synthesize viewMarkWidth;
@synthesize sketchViewRect;
@synthesize initBackColor;
@synthesize maxScale;
@synthesize homedoc;
@synthesize libraryInfo;
@synthesize canvasSize;

- (float *) initBackColor
{
    return initBackColorf;
}
-(id) init
{
    isiPhone=[[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone; 
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    homedoc = [paths objectAtIndex:0];
    if (isiPhone) {
        viewMarkWidth=32;
        sketchViewRect.size.width=100;
        sketchViewRect.size.height=100;
        sketchViewRect.origin.x=200;
        sketchViewRect.origin.y=0;
        maxTetureSize.height=1024;
        maxTetureSize.width=1024;
        libraryInfo.x=0;
        libraryInfo.cols=4;
    }
    else {
        viewMarkWidth=42;
        sketchViewRect.size.width=200;
        sketchViewRect.size.height=200;
        sketchViewRect.origin.x=500;
        sketchViewRect.origin.y=0;
        maxTetureSize.height=2048;
        maxTetureSize.width=2048;
        libraryInfo.x=60;
        libraryInfo.cols=8;
    }
    initBackColorf[0]=1;
    initBackColorf[1]=1;
    initBackColorf[2]=1;
    initBackColorf[3]=1;
    return self;
}

- (void) showAbout
{
    NSString *title;
    NSString *message;
    NSString *cancel;
    NSString *yes;
    UIAlertView *alert;
    title=NSLocalizedString(@"About", nil);
    message=NSLocalizedString(@"Info", nil);
    cancel=NSLocalizedString(@"I know", nil);
    yes=NSLocalizedString(@"More Apps", nil);
    alert=[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:yes, nil];
    alert.tag=2;
    [alert show]; 
}

- (void) showError:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:msg
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];    

}

@end
