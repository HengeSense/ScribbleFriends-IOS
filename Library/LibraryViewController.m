//
//  LibraryViewController.m
//  huadufu
//
//  Created by Tianhu Yang on 1/24/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "LibraryViewController.h"
#import "TouchButton.h"
#import "UIGridView.h"
#import "UIGridViewDelegate.h"
#import "LibraryCell.h"

static const int count=14;
static char name[]="library_";

@interface LibraryViewController () <UIGridViewDelegate>
{
    int row,col;
}

@end

@implementation LibraryViewController

@synthesize libraryDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    self=[super init];
    self=[self initWithNibName:@"LibraryViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
    row=rowIndex;
    col=columnIndex;
}


- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex
{
    return 80;
}
- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex
{
    return 80;
}

- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid
{
    return globalKit.libraryInfo.cols;
}
- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid
{
    return count;
}

- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
    LibraryCell *cell = (LibraryCell *)[grid dequeueReusableCell];
	
	if (cell == nil) {
		cell = [[LibraryCell alloc] init];
	}
	
    [cell setRowIndex:rowIndex columIndex:columnIndex];
	return cell;
}
- (CGRect) gridView:(UIGridView *)grid frameForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
{
    return CGRectMake(5, 5, 70, 70);
}
- (NSString *) gridView:(UIGridView *)grid titleForHeaderInSection:(NSInteger)section;
{
    return nil;
}

- (IBAction)buttonTouch:(TouchButton *)sender {
    NSString *path;
    switch (sender.tag) {
        case 1://yes
            path=[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%s%d",name,row*globalKit.libraryInfo.cols+col] ofType:@"png"];
            [libraryDelegate pickedImage:[UIImage imageWithContentsOfFile:path]] ;            
        case 2://no
            if(self.parentViewController)
            {
                [self.parentViewController dismissModalViewControllerAnimated:YES];
            }
            else {
                [self.presentingViewController dismissModalViewControllerAnimated:YES];
            }
            break;
            
        default:
            break;
    }
}


- (void) dealloc
{
    self.libraryDelegate=nil;
}


@end
