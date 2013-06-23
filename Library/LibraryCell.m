//
//  LibraryCell.m
//  huadufu
//
//  Created by Tianhu Yang on 1/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "LibraryCell.h"

static char name[]="icon_library_";

@interface LibraryCell()
{
    UIImageView *imageView;
}

@end

@implementation LibraryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}



-(id) init
{
    if (self=[super init]) {
        [self setUp];
    };
    return  self;
}
         
- (void) setUp
{    
    imageView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 60, 60)];
    [self addSubview:imageView];      
}

- (void) setRowIndex:(int)rowIndex columIndex:(int) columnIndex
{
    NSString *path=[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s%d",name,rowIndex*globalKit.libraryInfo.cols+columnIndex] ofType:@"png"];
    [imageView setImage:[UIImage imageWithContentsOfFile:path]];
    return;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
