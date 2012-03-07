//
//  GSBookShelfCellView.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-23.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSBookShelfCell.h"

@interface BookShelfCellView : UIView <GSBookShelfCell>

@property (nonatomic, strong) NSString *reuseIdentifier;

@end
