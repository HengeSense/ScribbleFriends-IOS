//
//  SaveViewController.m
//  huadufu
//
//  Created by Tianhu Yang on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SaveViewController.h"
#import "GlobalKit.h"
#import "CheckBox.h"
static NSString *shareOption[2];
@interface SaveViewController ()<UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>
{
    unsigned width,height;
    int(*measure)[2] ;
    unsigned pickerMode;
}
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UITextField *selectTextField;

@property (strong, nonatomic) IBOutlet UITextField *shareTextField;

@property (strong, nonatomic) IBOutlet UITextField *widthTextField;
@property (strong, nonatomic) IBOutlet UITextField *heightTextField;
@property (strong, nonatomic) IBOutlet CheckBox *checkBox;
@property (strong, nonatomic) IBOutlet UIToolbar *numberToolbar;

@end

@implementation SaveViewController
@synthesize toolbar;
@synthesize pickerView;
@synthesize selectTextField;
@synthesize shareTextField;
@synthesize widthTextField;
@synthesize heightTextField;
@synthesize checkBox;
@synthesize numberToolbar;
@synthesize saveDelegate;
@synthesize saveMode;
@synthesize measure;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        saveMode=1u;
        shareOption[0]=NSLocalizedString(@"ShareToFacebook", nil);
        shareOption[1]=NSLocalizedString(@"SaveToPhone", nil);
    }
    return self;
}

- (id) initWith:(int (*)[2])m
{
    measure=m;
    return self;
}

- (void) setMeasure:(int (*)[])m
{
    measure=m;
    if (self.isViewLoaded) {
        [self updateFields];
    }

}


-(void) updateFields
{
    width=measure[0][0];
    height=measure[0][1];
    widthTextField.text=[NSString stringWithFormat:@"%d", width];
    heightTextField.text=[NSString stringWithFormat:@"%d",height];
    selectTextField.text=nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    selectTextField.inputView = pickerView;
    selectTextField.inputAccessoryView = toolbar;
    
    widthTextField.inputAccessoryView=numberToolbar;
    heightTextField.inputAccessoryView=numberToolbar;
    shareTextField.inputView = pickerView;
    shareTextField.inputAccessoryView = toolbar;
    shareTextField.text=shareOption[0];
    [self updateFields];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setToolbar:nil];
    [self setPickerView:nil];
    [self setSelectTextField:nil];
    [self setWidthTextField:nil];
    [self setHeightTextField:nil];
    [self setCheckBox:nil];
    [self setNumberToolbar:nil];
    [self setShareTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	
}


#pragma mark -
#pragma mark UIPickerViewDataSource
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *ret;
    switch (pickerMode) {
        case 1u://ratio
            ret=[NSString stringWithFormat:@"%d×%d",measure[row][0],measure[row][1]];
            break;
        case 2u: //share mode
            ret=shareOption[row];
            break;
        default:
            break;
    }
    return ret;
}

- (CGFloat)pickerView:(UIPickerView *)aPickerView widthForComponent:(NSInteger)component
{	    
	return aPickerView.bounds.size.width-40.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)aPickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger ret = 0;
    switch (pickerMode) {
        case 1://ratio
            ret=2;
            break;
        case 2://share mode 
            ret=2;
            break;
        default:
            break;
    }
	return ret;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (IBAction)doneButtonTouch:(UIBarButtonItem *)sender {
    unsigned selectedIndex;
    switch (sender.tag) {
        case 1:   
            [selectTextField resignFirstResponder];
            [shareTextField resignFirstResponder];
            break;
        case 2:
            [selectTextField resignFirstResponder];
            [shareTextField resignFirstResponder];
            switch (pickerMode) {
                case 1u:
                    selectedIndex=[pickerView selectedRowInComponent:0];
                    width=measure[selectedIndex][0];
                    height=measure[selectedIndex][1];
                    widthTextField.text=[NSString stringWithFormat:@"%d", width];
                    heightTextField.text=[NSString stringWithFormat:@"%d",height];
                    selectTextField.text=[NSString stringWithFormat:@"%d×%d",width,height];
                    break;
                case 2u: 
                    saveMode=[pickerView selectedRowInComponent:0];
                    shareTextField.text=shareOption[saveMode];
                    ++saveMode;
                    break;
                default:
                    break;
            }
            
            break; 
        case 3:  
            [widthTextField resignFirstResponder];
            [heightTextField resignFirstResponder];            
            break;
        case 4:
            
            break;
        default:
            break;
    }    
    
}

- (IBAction)buttonTouch:(UIButton *)sender {
    UIAlertView *alert;
    BOOL result=YES;
    NSString *message=@"";
    switch (sender.tag) {
        case 1://yes
            if (width==0u||width>measure[1][0]) {
                result=NO;
                message=[NSString stringWithFormat:@"%@%d.",NSLocalizedString(@"SaveWidthError", nil),
                         measure[1][0]+1u];
            }
            else if (height==0u||height>measure[1][1]) {
                result=NO;
                message=[NSString stringWithFormat:@"%@%d.",NSLocalizedString(@"SaveHeightError", nil),measure[1][1]+1u];
            }
            if (result) {
                if(self.parentViewController)
                {
                    [self.parentViewController dismissModalViewControllerAnimated:saveMode==3u];
                }
                else {
                    [self.presentingViewController dismissModalViewControllerAnimated:saveMode==3u];
                }
                [self.saveDelegate saveWith:width height:height];
                if (saveMode==2u) {                    
                    message=NSLocalizedString(@"SaveOK",nil);
                    alert =[[UIAlertView alloc] initWithTitle:
                            NSLocalizedString(@"Greate",nil)
                                                      message:message
                                                     delegate:self 
                                            cancelButtonTitle:NSLocalizedString(@"I know",nil) 
                                            otherButtonTitles:nil];
                    [alert show];
                }
                
            }
            else {
                alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"I know", nil) otherButtonTitles: nil];
                [alert show];
            }
            break;
        case 2://no
            if(self.parentViewController)
            {
                [self.parentViewController dismissModalViewControllerAnimated:saveMode==3u];
            }
            else {
                [self.presentingViewController dismissModalViewControllerAnimated:saveMode==3u];
            }
            break;
            
        default:
            break;
    }
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    pickerMode=textField.tag;
    [pickerView reloadAllComponents];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)textValueChanged:(UITextField *)sender {
    NSMutableString *ms=[NSMutableString stringWithString:sender.text];
    BOOL changed=NO;
    for (unsigned i=0; i<ms.length; ) {
        unsigned short ch=[ms characterAtIndex:i];
        if (ch<'0'||ch>'9') {
            [ms deleteCharactersInRange:NSMakeRange(i, 1)];
            changed=YES;
        }
        else {
            ++i;
        }
    }
    if (changed) {        
        sender.text=ms;
    } 
    if (sender.text.length>4) {
        sender.text=[sender.text substringToIndex:4];
    }
    switch (sender.tag) {
        case 1://width
            width=[sender.text intValue];
            if (checkBox.selected) {
                height=width*measure[1][1]/measure[1][0];
                heightTextField.text=[NSString stringWithFormat:@"%d",height];
            }                
            break;
        case 2://height
            height=[sender.text intValue];
            if (checkBox.selected)
            {
                width=height*measure[1][0]/measure[1][1];
                widthTextField.text=[NSString stringWithFormat:@"%d", width];
            }
            
            break;
        default:
            break;
    }    

}


@end
