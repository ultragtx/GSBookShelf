//
//  BelowBottomView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-3-11.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "BelowBottomView.h"

#import "BookShelfCellView.h"

@implementation BelowBottomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        BookShelfCellView *cell1 = [[BookShelfCellView alloc] initWithFrame:CGRectMake(0, 0, 320, 139) woodPart:WOOD_PART_1];
        
        BookShelfCellView *cell2 = [[BookShelfCellView alloc] initWithFrame:CGRectMake(0, 139, 320, 139) woodPart:WOOD_PART_2];
        
        [self addSubview:cell1];
        [self addSubview:cell2];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
