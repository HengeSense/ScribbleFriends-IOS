//
//  ILColorPickerExampleViewController.m
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/1/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import "ILColorPickerController.h"

@implementation ILColorPickerController
@synthesize  colorPicker;
@synthesize colorPickerDelegate;
@synthesize colorChip;
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Build a random color to show off setting the color on the pickers
    
    UIColor *c=[UIColor colorWithRed:(arc4random()%100)/100.0f 
                               green:(arc4random()%100)/100.0f
                                blue:(arc4random()%100)/100.0f
                               alpha:1.0];
    
    colorChip.backgroundColor=c;
    colorPicker.color=c;
    huePicker.color=c;
}

#pragma mark - ILSaturationBrightnessPickerDelegate implementation

-(void)colorPicked:(UIColor *)newColor forPicker:(ILSaturationBrightnessPickerView *)picker
{
    colorChip.backgroundColor=newColor;
}
- (IBAction)colorButtonTouch:(UIButton *)sender {
    colorChip.backgroundColor=sender.backgroundColor;
}
- (IBAction)buttonTouch:(UIButton*)sender {
    switch (sender.tag) {
        case 1://yes
            [colorPickerDelegate pickedColor:colorChip.backgroundColor];
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
