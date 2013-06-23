//
//  UndoManager.m
//  GLPaint
//
//  Created by Tianhu Yang on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UndoManager.h"
#import "PaintView.h"
#define  MAX_UNDO_STEPS 21
static const NSString *names[]={@"before",@"after"};
@interface UndoManager()
{
    PaintView *paintView;
    TextureData textureDatas[2][MAX_UNDO_STEPS];
    signed step,start,end;
    NSFileManager *fileManager;
}
@property(nonatomic,strong) NSString *path;
@end

@implementation UndoManager
@synthesize path;
@synthesize undoManagerDelegate;
@synthesize changeDelegate;

- (id) initWith:(PaintView*)pv
{
    paintView=pv;
    fileManager=[NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [paths objectAtIndex:0];
    path=[NSString stringWithFormat:@"%@/%@",path,@"cache"];
    NSError *error;
    if (![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {        
        return nil;
    }
    [self reset];
    return self;
}

- (void) reset
{
    step=start=end=0;
}

- (void) clear
{
    [fileManager removeItemAtPath:path error:nil];
}
- (void)beforeDo:(TextureData *)textureData
{        
    [self do:textureData index:0];
}
- (void)do:(TextureData *)textureData index:(int)index
{
    if (!textureData->data) {
        return;
    }
    textureDatas[index][step]=*textureData;
    NSString *filePath=[NSString stringWithFormat:@"%@/%@%d",self.path,names[index],step];
    size_t length=textureData->width*textureData->height*4;
    FILE *file=fopen(filePath.UTF8String, "wb");
    if (file) {
        fwrite(textureData->data, length, 1, file);
        fclose(file);
    }
    if(index==1)
    {
        step=end=(step+1)%MAX_UNDO_STEPS;
        if (step==start) {
            start=(start+1)%MAX_UNDO_STEPS;
        }  
    
    }

}
- (void) afterDo:(TextureData *)textureData
{
    [self do:textureData index:1];
    [undoManagerDelegate canUndo:YES];
    [undoManagerDelegate canRedo:NO];
    [changeDelegate didChanged];
}
- (BOOL) redo
{
    BOOL hasNext=TRUE;
    if (step==end) {
        hasNext=FALSE;
    }
    else {        
        [self change:1];
        step=(step+1+MAX_UNDO_STEPS)%MAX_UNDO_STEPS;
        if (step==end) {
            hasNext=FALSE;
        }
        [undoManagerDelegate canUndo:YES];
    }
    [undoManagerDelegate canRedo:hasNext];    
    return hasNext;
}
- (BOOL) undo
{    
    BOOL hasPrevious=TRUE;
    if (step==start) {
        hasPrevious=FALSE;
    }
    else {
        step=(step+MAX_UNDO_STEPS-1)%MAX_UNDO_STEPS;
        if (step==start) {
            hasPrevious=FALSE;
        }
        [self change:0]; 
        [undoManagerDelegate canRedo:YES]; 
    }
    [undoManagerDelegate canUndo:hasPrevious];
    return hasPrevious;
}
- (void) change:(int)index
{
    PaintDraw *paintDraw=paintView.paintDraw;
    NSString *filePath=[NSString stringWithFormat:@"%@/%@%d",self.path,names[index],step];
    size_t length=textureDatas[index][step].width*textureDatas[index][step].height*4;
    FILE *file=fopen(filePath.UTF8String, "rb");
    if (file) {
        textureDatas[index][step].data=malloc(length);
        if (textureDatas[index][step].data) {
            fread(textureDatas[index][step].data, length, 1, file);
            [paintDraw writeImage:textureDatas[index]+step];
            free(textureDatas[index][step].data);
        }        
        fclose(file);
        [changeDelegate didChanged];
    }
}
@end
