//
//  TextPickerViewController.m
//  huadufu
//
//  Created by Tianhu Yang on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextPickerViewController.h"

@interface TextPickerViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>
{
    unsigned mode;
}
@property (strong, nonatomic) NSArray *fonts;
@property (strong, nonatomic) NSArray *styles;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolBar;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UITextField *selectTextField;

@end

@implementation TextPickerViewController
@synthesize fonts;
@synthesize styles;
@synthesize pickerView;
@synthesize textField;
@synthesize toolBar;
@synthesize toolbar;
@synthesize selectTextField;
@synthesize textPickerDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.fonts=[UIFont familyNames]; 
        styles=[UIFont fontNamesForFamilyName:[fonts objectAtIndex:0]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectTextField.inputView = pickerView;
    selectTextField.inputAccessoryView = toolbar;
    //[selectTextField resignFirstResponder];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setPickerView:nil];
    [self setTextField:nil];
    [self setToolBar:nil];
    [self setToolbar:nil];
    [self setSelectTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) setText:(NSString *)text font:(NSString*)font
{
    textField.text=text;
    textField.font=[UIFont fontWithName:font size:17.0f];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component==0) {
        styles=[UIFont fontNamesForFamilyName:[fonts objectAtIndex:row]];
        [aPickerView reloadComponent:1];
    }
	
}


#pragma mark -
#pragma mark UIPickerViewDataSource
- (UIView *)pickerView:(UIPickerView *)aPickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (view==nil) {        
        view=[[UILabel alloc] init];
        CGRect frame=view.frame;
        frame.size.width=(aPickerView.bounds.size.width-40.0f)/2;
        frame.size.height=40.0f;
        view.frame=frame;
    }
    UILabel *label=(UILabel *)view;
	// note: custom picker doesn't care about titles, it uses custom views
    if (component == 0)
    {
        label.text = [fonts objectAtIndex:row];
        label.font=[UIFont fontWithName:[[UIFont fontNamesForFamilyName:label.text] objectAtIndex:0] size:14.0f];
        
    }
    else
    {
        label.text = [styles objectAtIndex:row];
        label.font=[UIFont fontWithName:[[UIFont fontNamesForFamilyName:[fonts objectAtIndex:[aPickerView selectedRowInComponent:0]]] objectAtIndex:row] size:14.0f];
    }
    return label;
}


- (CGFloat)pickerView:(UIPickerView *)aPickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 0.0;
    
	if (component == 0)
		componentWidth = (aPickerView.bounds.size.width-40.0f)/2;	// first column size is wider to hold names
	else
		componentWidth = (aPickerView.bounds.size.width-40.0f)/2;	// second column is narrower to show numbers
    
	return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)aPickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger count=0;
    switch (component) {
        case 0:
            count=[fonts count];
            break;
        case 1:
            count=[[UIFont fontNamesForFamilyName:[fonts objectAtIndex:[aPickerView selectedRowInComponent:0]]] count];
            break;    
        default:
            break;
    }
	return count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}


- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];    
    return YES;
}

- (IBAction)textButtonTouch:(UIButton *)sender {
    textField.font=[UIFont fontWithName:sender.titleLabel.font.fontName size:17.0];
    return;
}

- (IBAction)buttonTouch:(UIButton *)sender {
    switch (sender.tag) {
        case 1://yes
            [textPickerDelegate pickedText:textField.text font:textField.font.fontName];            
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
- (IBAction)doneTouch:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:
            
            break;
        case 2:
            selectTextField.text=[styles objectAtIndex:[pickerView selectedRowInComponent:1]];
            textField.font=[UIFont fontWithName:selectTextField.text size:17.0];
            break;    
        default:
            break;
    }
    [selectTextField resignFirstResponder];
    
}

@end
