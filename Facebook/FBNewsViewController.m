//
//  FBNewsViewController.m
//  ScribbleFriends
//
//  Created by Tianhu Yang on 1/25/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FBNewsViewController.h"
#import "PullTableView.h"
#import "TouchButton.h"
#import "FBNewsTableCell.h"
#import "FBNewsHandler.h"

@interface FBNewsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIColor *selectedColor;
    FBNewsHandler *fbNewsHandler;
}
@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;
@end

@implementation FBNewsViewController
@synthesize pullTableView;
@synthesize fbNewsDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self=[super init];
    self=[self initWithNibName:@"FBNewsViewController" bundle:nil];
    selectedColor=[UIColor colorWithRed:170.f/255 green:170.f/255 blue:170.f/255 alpha:1.0f]; 
    fbNewsHandler=[[FBNewsHandler alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [fbNewsHandler requestNewsSession];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setPullTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dealloc
{
    fbNewsDelegate=nil;
}

#pragma mark - Refresh and load more methods

- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.
     
     */
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    self.pullTableView.pullTableIsLoadingMore = NO;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    FBNewsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIView *view;
    if(!cell) {
        /*cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        CGRect rect=cell.contentView.bounds;
        rect.origin.x=10;  
        rect.origin.y=10;
        rect.size.width-=2*rect.origin.x;
        rect.size.height=tableView.rowHeight-rect.origin.y;
        view=[[UIView alloc] initWithFrame:rect];
        view.backgroundColor=[UIColor whiteColor];
        view.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:view];
        
        UIImageView *headView=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
        UILabel *messageView=[UILabel alloc] initWithFrame:CGRectMake(60, 5, CGFloat width, CGFloat height)*/
        cell=[[FBNewsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier height:tableView.rowHeight];
        
    }
    view=cell.backView;
    NSIndexPath *path=[tableView indexPathForSelectedRow];
    if(path&&[path compare:indexPath]==NSOrderedSame){
        view.backgroundColor=selectedColor;
    }
    else {
        view.backgroundColor=[UIColor whiteColor];
    }

    //cell.textLabel.text = [NSString stringWithFormat:@"Row %i", indexPath.row];
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"PickPicture", nil);
}

/*- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view=[tableView cellForRowAtIndexPath:indexPath].contentView;
    view=[view.subviews objectAtIndex:0];
    view.backgroundColor=selectedColor;
    return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *view=[tableView cellForRowAtIndexPath:indexPath].contentView;
    view=[view.subviews objectAtIndex:0];
    view.backgroundColor=[UIColor whiteColor];
    return indexPath;
}*/


#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:3.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:3.0f];
}

#pragma mark - button touch

- (IBAction)buttonTouch:(TouchButton *)sender {
    switch (sender.tag) {
        case 1://yes  
            [fbNewsDelegate pickedPath:nil];
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



@end
