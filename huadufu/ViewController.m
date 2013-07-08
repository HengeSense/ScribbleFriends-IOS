//
//  ViewController.m
//  huadufu
//
//  Created by Tianhu Yang on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "MoveButton.h"
#import "ILSaturationBrightnessPickerView.h"
#import "TextPickerViewController.h"
#import "CheckBox.h"
#import "ImagePicker.h"
#import "ShapeViewController.h"
#import "SaveViewController.h"
#import "ZoomButton.h"

@interface ViewController ()<TextPickerDelegate,ColorPickerDelegate,ShapePickerDelegate,SaveDelagate,UndoManagerDeletate,PaintDelegate,UIAlertViewDelegate>
{
    int mode;
}

@property(nonatomic,strong) TextPickerViewController *tpvc;
@property(nonatomic,strong) ShapeViewController *svc;
@property(nonatomic,strong) SaveViewController *saveViewController;

@property (strong, nonatomic) IBOutlet UIView *textToolbarView;
@property (strong, nonatomic) IBOutlet UIButton *textForegroundButton;
@property (strong, nonatomic) IBOutlet UIButton *textBackgroundButton;
@property (strong, nonatomic) IBOutlet CheckBox *textSelectedButton;
@property (nonatomic,strong) ImagePicker *imagePicker;
@property (strong, nonatomic) IBOutlet CheckBox *imagePropotionalButton;
@property (strong, nonatomic) IBOutlet UIButton *undoButton;
@property (strong, nonatomic) IBOutlet UIButton *redoButton;

@property (strong, nonatomic) IBOutlet UIImageView *undoButtonImage;
@property (strong, nonatomic) IBOutlet UIImageView *redoButtonImage;
@property (strong, nonatomic) IBOutlet ZoomButton *zoomOutButton;
@property (strong, nonatomic) IBOutlet ZoomButton *zoomInButton;
@property (strong, nonatomic) IBOutlet MoveButton *firstSelectedButton;


@end

@implementation ViewController
@synthesize toolBarView;
@synthesize paintView;
@synthesize zoomButtonView;
@synthesize ilcpc;
@synthesize tpvc;
@synthesize svc;
@synthesize textToolbarView;
@synthesize textForegroundButton;
@synthesize textBackgroundButton;
@synthesize textSelectedButton;
@synthesize imagePicker;
@synthesize imagePropotionalButton;
@synthesize undoButton;
@synthesize redoButton;
@synthesize undoButtonImage;
@synthesize redoButtonImage;
@synthesize zoomOutButton;
@synthesize zoomInButton;
@synthesize firstSelectedButton;
@synthesize alphaSlider;
@synthesize imageToolbarView;
@synthesize saveViewController;
@synthesize colorMode,alphaMode,textMode;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.imagePicker=[[ImagePicker alloc] initWith:self];
        mode=1u;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    textForegroundButton.layer.cornerRadius=2.0f;
    textForegroundButton.layer.borderWidth=2.0f;
    textForegroundButton.layer.borderColor=[UIColor grayColor].CGColor;
    textBackgroundButton.layer.cornerRadius=2.0f;
    textBackgroundButton.layer.borderWidth=2.0f;
    textBackgroundButton.layer.borderColor=[UIColor grayColor].CGColor;
    //
    imagePropotionalButton.selected=YES;
    
    self.firstSelectedButton.selected=YES;
}

- (void) initUI
{
    [self.paintView bringSubviewToFront:alphaSlider];
    self.paintView.undoManager.undoManagerDelegate=self;
    self.paintView.paintDraw.paintDelegate=self;
    
    CGRect frame=self.toolBarView.frame;
    frame.origin.x=0;
    frame.origin.y=self.view.bounds.size.height-frame.size.height;
    self.toolBarView.frame=frame;
    [self.view addSubview:self.toolBarView];
    
    frame=self.textToolbarView.frame;
    frame.origin.x=self.view.center.x-frame.size.width/2.0f;
    frame.origin.y=self.view.bounds.size.height-frame.size.height;
    self.textToolbarView.frame=frame;
    [self.view addSubview:self.textToolbarView];
    
    frame=self.imageToolbarView.frame;
    frame.origin.x=self.view.center.x-frame.size.width/2.0f;
    frame.origin.y=self.view.bounds.size.height-frame.size.height;
    self.imageToolbarView.frame=frame;
    [self.view addSubview:self.imageToolbarView];
}

- (void) viewDidLayoutSubviews
{
    [paintView initUI];
    [self initUI];
    
}

- (void)viewDidUnload
{
    [self setToolBarView:nil];
    [self setPaintView:nil];
    [self setZoomButtonView:nil];
    [self setTextToolbarView:nil];
    [self setTextForegroundButton:nil];
    [self setTextBackgroundButton:nil];
    [self setTextSelectedButton:nil];
    [self setImageToolbarView:nil];
    [self setImagePropotionalButton:nil];
    [self setAlphaSlider:nil];
    [self setUndoButton:nil];
    [self setRedoButton:nil];
    [self setUndoButtonImage:nil];
    [self setRedoButtonImage:nil];
    [self setZoomOutButton:nil];
    [self setZoomInButton:nil];
    [self setFirstSelectedButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation==UIInterfaceOrientationPortrait;
}
-(TextPickerViewController*)tpvc
{
    if (tpvc) {
        return tpvc;
    }
    else {
         tpvc=[[TextPickerViewController alloc] initWithNibName:@"TextPickerViewController" bundle:nil];
        tpvc.textPickerDelegate=self;
        return tpvc;
    }
}
-(ILColorPickerController*)ilcpc
{
    if (ilcpc) {
        return ilcpc;
    }
    else {
        ilcpc=[[ILColorPickerController alloc] initWithNibName:@"ILColorPickerController" bundle:nil];
        ilcpc.colorPickerDelegate=self;
        return ilcpc;
    }
}

-(SaveViewController*)saveViewController
{
    CGSize size;
    if (saveViewController) {
        return saveViewController;
    }
    else {
        size=paintView.bounds.size;
        saveViewController=[[SaveViewController alloc] initWithNibName:@"SaveViewController" bundle:nil];
        saveViewController.saveDelegate=self;
        return saveViewController;
    }
}


-(NSString*) saveWith:(unsigned)width height:(unsigned)height
{
    UIImage *image=[paintView.paintDraw snapshot:CGSizeMake(width, height)];
    switch (self.saveViewController.saveMode) {
        case 1://Facebook
            //self.qqViewController.image=image;
           // [self presentModalViewController:self.qqViewController animated:YES];
            break;
        case 2://phone            
            UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil);
            break;
        default:
            break;
    }
    
    return nil;
}
- (void) pickedColor:(UIColor*)color
{
    float comp[4];
    switch (colorMode) {
        case 1u://color
            paintView.brush.brushColor=color;
            break;
        case 2u://text foreground color
            textForegroundButton.backgroundColor=paintView.textView.label.textColor=color;
            break;
        case 3u://text background color
            textBackgroundButton.backgroundColor=color;
            if (textSelectedButton.selected) {
                paintView.textView.label.backgroundColor=color;
            }
            
            break;
        case 4u://new background color            
            memcpy(comp, CGColorGetComponents(color.CGColor), 3*sizeof(float));
            paintView.paintDraw.backColor=comp;
            [paintView clear:nil];
            break;
        default:
            break;
    }
   
}
-(ShapeViewController*)svc
{
    if (svc) {
        return svc;
    }
    else {
        svc=[[ShapeViewController alloc] initWithNibName:@"ShapeViewController" bundle:nil];
        svc.shapePickerDelegare=self;
        return svc;
    }
}
-(void) picked:(float)size opacity:(float)opacity
{
    paintView.brush.brushScale=size;
    paintView.brush.opacity=opacity;
}
- (void) pickedText:(NSString*)text font:(NSString *)font
{
    if (textMode==1u) {
        [paintView.textView begin];
        [self switch:-1];
        //
        self.toolBarView.hidden=YES;
        self.textToolbarView.hidden=NO; 
        textForegroundButton.backgroundColor=paintView.textView.label.textColor;
        textBackgroundButton.backgroundColor=paintView.textView.label.backgroundColor;
    } 
    [paintView.textView setText:text font:font];  
     
       
}

- (void) canUndo:(BOOL)yes
{
    undoButtonImage.highlighted=yes;
}
-(void) canRedo:(BOOL)yes
{
    redoButtonImage.highlighted=yes;
}
- (void) canZoomIn:(BOOL)can
{
    zoomInButton.canUnhighlighted=can;
}
-(void) canZoomOut:(BOOL)can
{
    zoomOutButton.canUnhighlighted=can;
}

- (void) switch:(int)aMode
{
   switch(mode)
   {
      case 3: 
           self.zoomButtonView.hidden=YES;  
           break;
   }
   if(aMode>-1)//none
   {
       if(aMode!=0)//revert
       {
          mode=aMode; 
       }
       else {
           aMode=mode;
       }
    
       switch(mode)
       {
           case 3://zoom
               self.zoomButtonView.hidden=NO;
               break; 
       }
   }  
   
   [paintView switch:aMode];
}

// change mode
- (IBAction)switchButtonTouch:(MoveButton *)sender {
    if(sender.isMoved||sender.tag==mode)
        return;
    sender.selected=YES;
    [self switch:sender.tag];
}
// interrupted operation
- (IBAction)operateButtonTouch:(MoveButton*)sender { 
    if(sender.isMoved)
        return;
    [paintView operate:sender.tag];
    switch (sender.tag) {
        case 22://color  
            colorMode=1;
            self.ilcpc.colorPicker.color=paintView.brush.brushColor;
            [self presentModalViewController:self.ilcpc animated:YES];
            break;
        case 23: //clear 
            [imagePicker clear];
            break;
        case 24://size
            [self.svc setScale:paintView.brush.brushScale opacity:paintView.brush.opacity];
            [self presentModalViewController:self.svc animated:YES];
            break;
        case 25://backward
            [self.paintView.undoManager undo];
            break;
        case 26://forward
            [self.paintView.undoManager redo];
            break;
        case 27://share
            self.saveViewController.measure=[paintView.paintDraw getMeasure];
            [self presentModalViewController:self.saveViewController animated:YES];           
            break;
        case 28://new
            imagePicker.imageMode=2u;
            [imagePicker beginPicking];
            break;
        case 29://text 
            alphaMode=1u;
            textMode=1u;
            [self presentModalViewController:self.tpvc animated:YES];           
            break;
        case 30://image
            imagePicker.imageMode=1u;
            imagePicker.imageSubMode=2u;//switch
            alphaMode=2u;
            [imagePicker beginPicking];           
            break;
        case 31://about
            [globalKit showAbout];
            break;
        case 32://points
            //[grade display];
            break;
        default:
            break;
    }
}

- (IBAction)textButtonTouch:(UIButton *)sender { 
    switch (sender.tag) {
        case 1://text
            
            break;
        case 2://text
            textMode=2u;
            [self.tpvc setText:paintView.textView.label.text font:paintView.textView.label.font.fontName];
            [self presentModalViewController:self.tpvc animated:YES];
            break;
        case 3://foreground
            colorMode=2;
            self.ilcpc.colorChip.backgroundColor=paintView.textView.label.textColor;
            
            [self presentModalViewController:self.ilcpc animated:YES];
            break;
        case 4://background
            colorMode=3;
            self.ilcpc.colorChip.backgroundColor=paintView.textView.label.backgroundColor;            
            [self presentModalViewController:self.ilcpc animated:YES];
            break;
        case 5://whether have background
            if (sender.selected) {
                paintView.textView.label.backgroundColor=textBackgroundButton.backgroundColor;
            }
            else {
                paintView.textView.label.backgroundColor=[UIColor clearColor];
            }
            break;
        case 6://yes
            [paintView.textView drawImage];
        case 7://no
            [paintView.textView end];
            [self switch:0];
            self.toolBarView.hidden=NO;
            self.textToolbarView.hidden=YES;
            self.alphaSlider.hidden=YES;
            break;
        case 8://alpha
            self.alphaSlider.hidden=!self.alphaSlider.hidden;
            break;
        default:
            break;
    }
}

- (IBAction)zoomButtonTouch:(UIButton *)sender {
    [paintView operate:sender.tag];
    switch (sender.tag) {
        case 20://zoom out
            
            break;
        case 21://zoom in
            
            break;
            
        default:
            break;
    }
}


- (IBAction)imageButtonTouch:(UIButton *)sender { 
    switch (sender.tag) {
        case 2://image
            imagePicker.imageMode=1u;
            imagePicker.imageSubMode=1u;//non switch
            [imagePicker beginPicking];
            break;
        case 3:// whether is propotional
            paintView.imageView.propotioal=sender.selected;
            break;
        case 4://yes
            [paintView.imageView drawImage];            
        case 5://no
            [paintView.imageView end];
            [self switch:0];
            self.imageToolbarView.hidden=YES;
            self.toolBarView.hidden=NO;
            self.alphaSlider.hidden=YES;
            break;
        case 6://alphaSlider
            self.alphaSlider.hidden=!self.alphaSlider.hidden;
            break;
        default:
            break;
    }
}

- (IBAction)alphaSliderValueChanged:(UISlider *)sender {
    switch (alphaMode) {
        case 1u://text picker
            paintView.textView.label.alpha=sender.value;
            break;//image picker
        case 2u:
            paintView.imageView.imageView.alpha=sender.value;
            break;            
        default:
            break;
    }
    
}


@end
