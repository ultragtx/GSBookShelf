//
//  AboveTopView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-3-11.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "AboveTopView.h"

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

@implementation AboveTopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *woodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 139 * 2)];
        
        CGFloat scale = isRetina ? 2.0f : 1.0f;
        [woodImageView setImage:[UIImage imageWithCGImage:CGImageCreateWithImageInRect([[UIImage imageNamed:@"WoodTile-iPhone.png"] CGImage], CGRectMake(0, 0, 320 * scale, 139 * 2 * scale))]];
        [self addSubview:woodImageView];
        
        UIImageView *sideImageView_left1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 164)];
        [sideImageView_left1 setImage:[UIImage imageNamed:@"topshelf side shading-iPhone.png"]];
        
        UIImageView *sideImageView_left2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 139, 160, 139)];
        [sideImageView_left2 setImage:[UIImage imageNamed:@"SideShading-iPhone.png"]];
        
        [self addSubview:sideImageView_left1];
        //[self addSubview:sideImageView_left2];
        
        UIImageView *sideImageView_right1 = [[UIImageView alloc] initWithFrame:CGRectMake(160, 0, 160, 164)];
        [sideImageView_right1 setImage:[UIImage imageNamed:@"topshelf side shading-iPhone.png"]];
        [sideImageView_right1 setTransform:CGAffineTransformMakeScale(-1.0, 1.0)];
        
        UIImageView *sideImageView_right2 = [[UIImageView alloc] initWithFrame:CGRectMake(160, 139, 160, 139)];
        [sideImageView_right2 setImage:[UIImage imageNamed:@"SideShading-iPhone.png"]];
        [sideImageView_right2 setTransform:CGAffineTransformMakeScale(-1.0, 1.0)];
        
        [self addSubview:sideImageView_right1];
        //[self addSubview:sideImageView_right2];
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
