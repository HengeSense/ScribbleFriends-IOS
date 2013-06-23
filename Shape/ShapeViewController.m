//
//  ShapeViewController.m
//  huadufu
//
//  Created by Tianhu Yang on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ShapeViewController.h"
#import "ShapeView.h"

@interface ShapeViewController ()
{
    float shapeSize,shapeOpacity;
}
@property (strong, nonatomic) IBOutlet UISlider *sizeSlider;
@property (strong, nonatomic) IBOutlet UISlider *opacitySlider;
@property (strong, nonatomic) IBOutlet ShapeView *shapeView;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *opacityLabel;

@end

@implementation ShapeViewController
@synthesize sizeSlider;
@synthesize opacitySlider;
@synthesize shapeView;
@synthesize sizeLabel;
@synthesize opacityLabel;
@synthesize shapePickerDelegare;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sizeSlider.value=self.shapeView.shapeSize=shapeSize;
    opacitySlider.value=self.shapeView.shapeOpacity=shapeOpacity;    
    sizeLabel.text=[NSString stringWithFormat:@"%.2f",sizeSlider.value];
    opacityLabel.text=[NSString stringWithFormat:@"%.2f",opacitySlider.value];    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setSizeSlider:nil];
    [self setOpacitySlider:nil];
    [self setShapeView:nil];
    [self setSizeLabel:nil];
    [self setOpacityLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) setScale:(float)scale opacity:(float)opacity
{
    self.shapeView.shapeSize=self.sizeSlider.value=shapeSize=scale;
    self.shapeView.shapeOpacity=self.opacitySlider.value=shapeOpacity=opacity;    
    self.sizeLabel.text=[NSString stringWithFormat:@"%.2f",scale];
    self.opacityLabel.text=[NSString stringWithFormat:@"%.2f",opacity];
    [shapeView setNeedsDisplay];
}

- (IBAction)sliderChange:(UISlider *)sender {
    switch (sender.tag) {
        case 1://size
            shapeView.shapeSize=sender.value;
            sizeLabel.text=[NSString stringWithFormat:@"%.2f",sender.value];
            [shapeView setNeedsDisplay];
            break;
        case 2://opacity
            shapeView.shapeOpacity=sender.value;
            opacityLabel.text=[NSString stringWithFormat:@"%.2f",sender.value];
            [shapeView setNeedsDisplay];
            break;
            
        default:
            break;
    }
}

- (IBAction)buttonTouch:(UIButton *)sender {
    switch (sender.tag) {
        case 1://yes
            [self.shapePickerDelegare picked:shapeView.shapeSize opacity:shapeView.shapeOpacity];
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
