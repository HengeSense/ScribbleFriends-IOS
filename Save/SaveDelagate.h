//
//  SaveDelagate.h
//  huadufu
//
//  Created by Tianhu Yang on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SaveDelagate <NSObject>
-(NSString*) saveWith:(unsigned)width height:(unsigned)height;
@end
