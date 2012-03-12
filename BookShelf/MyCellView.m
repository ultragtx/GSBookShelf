//
//  NewCellView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-3-12.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "MyCellView.h"

@implementation MyCellView

@synthesize reuseIdentifier;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 125)];
        
        [imageView setImage:[UIImage imageNamed:@"BookShelfCell.png"]];
        [self addSubview:imageView];
        
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
