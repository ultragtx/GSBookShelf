//
//  GSBookShelfCellView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-23.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "BookShelfCellView.h"
#import <QuartzCore/QuartzCore.h>

#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

@implementation BookShelfCellView

@synthesize reuseIdentifier;

- (UIImage *)partOfImage:(UIImage *)image rect:(CGRect)rect {
    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.width));
    [image drawInRect:rect];
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (id)initWithFrame:(CGRect)frame woodPart:(WoodPart)part
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        //[self.layer setBorderWidth:2];
        //[self.layer setBorderColor:[[UIColor greenColor] CGColor]];
        
        // wood
        _woodImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 139)];
        
        CGFloat scale = isRetina ? 2.0f : 1.0f;
        [_woodImageView setImage:[UIImage imageWithCGImage:CGImageCreateWithImageInRect([[UIImage imageNamed:@"WoodTile-iPhone.png"] CGImage], CGRectMake(0, 139 * scale * part, 320 * scale, 139 * scale))]];
        [self addSubview:_woodImageView];
        
        _sideImageView_left = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 139)];
        [_sideImageView_left setImage:[UIImage imageNamed:@"SideShading-iPhone.png"]];
        
        [self addSubview:_sideImageView_left];
        
        _sideImageView_right = [[UIImageView alloc] initWithFrame:CGRectMake(160, 0, 160, 139)];
        [_sideImageView_right setImage:[UIImage imageNamed:@"SideShading-iPhone.png"]];
        [_sideImageView_right setTransform:CGAffineTransformMakeScale(-1.0, 1.0)];
        [self addSubview:_sideImageView_right];
        //[_sideImageView_right.layer setBorderWidth:1];
        //[_sideImageView_right.layer setBorderColor:[[UIColor redColor] CGColor]];
        
        
        _shelfImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 130 - 23, 320, 87)];
        [_shelfImageView setImage:[UIImage imageNamed:@"Shelf-iPhone.png"]];
        [self addSubview:_shelfImageView];
        
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
