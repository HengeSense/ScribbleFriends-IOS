//
//  ILColorPickerExampleViewController.h
//  ILColorPickerExample
//
//  Created by Jon Gilkison on 9/1/11.
//  Copyright 2011 Interfacelab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILSaturationBrightnessPickerView.h"
#import "ILHuePickerView.h"
#import "ColorPickerDelegate.h"

@interface ILColorPickerController : UIViewController<ILSaturationBrightnessPickerViewDelegate> {        
    IBOutlet ILHuePickerView *huePicker;    
}
@property(strong,nonatomic) IBOutlet UIView *colorChip;
@property(strong,nonatomic) IBOutlet ILSaturationBrightnessPickerView *colorPicker;
@property(strong,nonatomic) id<ColorPickerDelegate> colorPickerDelegate;

@end
