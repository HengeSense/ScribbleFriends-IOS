//
//  ImagePicker.m
//  huadufu
//
//  Created by Tianhu Yang on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImagePicker.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "LibraryDelegate.h"
#import "LibraryViewController.h"
#import "FBNewsViewController.h"

@interface ImagePicker() <LibraryDelegate,FBNewsDelegate>
{
    NSString *lastPath;
}
@property(nonatomic,strong) ViewController *viewController;
@property(nonatomic,strong) UIPopoverController *popover;
@end

@implementation ImagePicker
@synthesize viewController;
@synthesize imageMode,newMode,imageSubMode;
@synthesize popover;

-(id) initWith:(ViewController*)vc
{
    if(self)
    {
        self.viewController=vc;
    }
    return self;
}

- (void) beginPicking
{
    NSString *title,*message=nil,*cancel=NSLocalizedString(@"Cancel", nil);
    UIAlertView *alert;
    switch (imageMode) {
        case 1u://picke image            
            title=NSLocalizedString(@"PickImage", nil);
            alert=[[UIAlertView alloc] initWithTitle:
                   title
                                             message:message
                                            delegate:self 
                                   cancelButtonTitle:cancel
                                   otherButtonTitles:NSLocalizedString(@"Facebook", nil),
                   NSLocalizedString(@"Library", nil),
                   NSLocalizedString(@"Album", nil),
                   nil];
            alert.tag=1;
            break;
        case 2u://new            
            title=NSLocalizedString(@"NewOptions", nil);
            alert=[[UIAlertView alloc] initWithTitle:
                   title
                                             message:message
                                            delegate:self 
                                   cancelButtonTitle:cancel
                                   otherButtonTitles:NSLocalizedString(@"Facebook", nil),
                   NSLocalizedString(@"Color", nil),
                   NSLocalizedString(@"Album", nil),
                   nil];
            alert.tag=2;
            break;
            
        default:
            break;
    }   
    
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{  
    switch (alertView.tag) {
        case 1://image
            if (buttonIndex==3) {//Album
                [self startMediaBrowserFromViewController:self.viewController usingDelegate:self];
            }
            else if (buttonIndex==2) {//Library
                LibraryViewController *libraryViewController=[[LibraryViewController alloc] init];
                libraryViewController.libraryDelegate=self;
                [viewController presentModalViewController:libraryViewController animated:YES];
            }
            else if (buttonIndex==1){//Facebook
                FBNewsViewController *newsVC=[FBNewsViewController defaultNewsViewController];
                newsVC.fbNewsDelegate=self;
                [viewController presentModalViewController:newsVC animated:YES];
                //[self pickedImage:img];
            }            
            break;
        case 2:
            // new
            if (buttonIndex==3) {//Album
                [self startMediaBrowserFromViewController:self.viewController usingDelegate:self];
            }
            else if(buttonIndex==2){//Color
                newMode=NEWMODEBACKGROUND;
                viewController.colorMode=4u;
                [viewController presentModalViewController:viewController.ilcpc animated:YES];
            }
            else if (buttonIndex==1){//Facebook
                newMode=NEWMODEIMAGE;
                FBNewsViewController *newsVC=[FBNewsViewController defaultNewsViewController];
                newsVC.fbNewsDelegate=self;
                [viewController presentModalViewController:newsVC animated:YES];
            }
            break;
            
        default:
            break;
    }
    if (buttonIndex==0) {
        return;
    }
    
}

-(void) clear
{
    if (self.newMode==NEWMODEBACKGROUND) {
        [viewController.paintView clear:nil];
    }
    else {
        [viewController.paintView clear:[UIImage imageWithContentsOfFile:lastPath]];
    }
    
}

- (void) pickedPath:(NSString *)path
{
    lastPath=path;
    [self pickedImage:[UIImage imageWithContentsOfFile:path]];
}

- (void) pickedImage:(UIImage*)image
{
    switch (imageMode) {
        case 1u://pick image            
            if (imageSubMode==2u) {//switch
                viewController.toolBarView.hidden=YES;
                viewController.imageToolbarView.hidden=NO;
                viewController.alphaSlider.value=viewController.paintView.imageView.imageView.alpha;
                [viewController.paintView.imageView begin];
                [viewController switch:-1];
            }
            viewController.paintView.imageView.imageView.image=image;
            break;
        case 2u://new
            [viewController.paintView drawImage:image];
            break;    
        default:
            break;
    }
    
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    if (globalKit.isiPhone) {
        [controller presentModalViewController: mediaUI animated: YES];
    }
    else {
        self.popover=[[UIPopoverController alloc] initWithContentViewController:mediaUI];
        CGPoint point=viewController.paintView.center;
        CGRect rect=CGRectMake(point.x, point.y, 0, 0);
        [popover presentPopoverFromRect:rect inView:viewController.paintView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }    
    
    return YES;
}
/**** start picker protocol ****/
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (globalKit.isiPhone) {
        if (picker.parentViewController) {
            [picker.parentViewController dismissModalViewControllerAnimated: YES];
        }
        else {
            [picker.presentingViewController dismissModalViewControllerAnimated: YES];
        }        
    }
    else {
        [self.popover dismissPopoverAnimated:YES];
    }
    
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSString *imagePath;
    UIImage *uiimg;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        uiimg = (UIImage *) [info objectForKey:
                             UIImagePickerControllerEditedImage];
        if(!uiimg)
            uiimg = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
        if(uiimg){           
            uiimg=[viewController.paintView.paintDraw resizeImage:uiimg];
            if (uiimg) {
                if (imageMode==2u) {//new                
                    imagePath = [globalKit.homedoc stringByAppendingPathComponent:@"temp.jpg"];                
                    if(imagePath) { 
                        newMode=NEWMODEIMAGE;
                        lastPath=imagePath;
                        [UIImageJPEGRepresentation(uiimg, 1.0f)  writeToFile:imagePath atomically:NO];
                        [self pickedImage:[UIImage imageWithContentsOfFile:imagePath]];
                        //NSLog(@"%@",imagePath);
                    }                
                } 
                else if(imageMode==1u){//pick
                    [self pickedImage:uiimg];
                }
            }
            
            
        }
        // Do something with imageToUse
    }
    [self imagePickerControllerDidCancel:picker];
    
}
/**** end picker protocol ****/
@end
