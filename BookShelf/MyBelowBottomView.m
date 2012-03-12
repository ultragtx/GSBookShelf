//
//  MyBelowBottomView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-3-12.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "MyBelowBottomView.h"
#import "MyCellView.h"

@implementation MyBelowBottomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        MyCellView *cell1 = [[MyCellView alloc] initWithFrame:CGRectMake(0, 0, 320, 125)];
        MyCellView *cell2 = [[MyCellView alloc] initWithFrame:CGRectMake(0, 125, 320, 125)];
        
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
