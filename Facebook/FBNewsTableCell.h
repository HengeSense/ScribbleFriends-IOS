//
//  FBNewsTableCell.h
//  ScribbleFriends
//
//  Created by Tianhu Yang on 1/28/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface FBNewsTableCell: UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIImageView *headView;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *msgView;

@property (strong, nonatomic) IBOutlet UIImageView *picView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier height:(int)height;
@end
