//
//  GlobalKit.h
//  GLPaint
//
//  Created by Tianhu Yang on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

struct LibraryInfo{
    float x;
    int cols;
};

@interface GlobalKit : NSObject
@property(nonatomic,assign) BOOL isiPhone;
@property(nonatomic,assign) CGSize maxTetureSize;
@property(nonatomic,assign) float viewMarkWidth;
@property(nonatomic,assign) CGRect sketchViewRect;
@property(nonatomic,assign,readonly) float *initBackColor;
@property(nonatomic,assign,readonly) float maxScale;
@property(nonatomic,strong,readonly) NSString *homedoc; 
@property(nonatomic,assign,readonly) struct LibraryInfo libraryInfo;
- (void) showAbout;
- (void) showError:(NSString *)msg;
@end
