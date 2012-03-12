//
//  NewCellView.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-3-12.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSBookShelfCell.h"

@interface MyCellView : UIView <GSBookShelfCell>

@property (nonatomic, strong) NSString *reuseIdentifier;

@end
