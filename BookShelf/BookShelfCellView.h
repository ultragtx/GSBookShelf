//
//  GSBookShelfCellView.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-23.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSBookShelfCell.h"

typedef enum {
    WOOD_PART_1,
    WOOD_PART_2
}WoodPart;

@interface BookShelfCellView : UIView <GSBookShelfCell> {
    UIImageView *_shelfImageView;
    UIImageView *_sideImageView_left;
    UIImageView *_sideImageView_right;
    UIImageView *_woodImageView;
}

@property (nonatomic, strong) NSString *reuseIdentifier;

- (id)initWithFrame:(CGRect)frame woodPart:(WoodPart)part;

@end
