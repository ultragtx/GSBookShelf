//
//  GSBookView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-23.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "GSBookView.h"

@implementation GSBookView

@synthesize image = _image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setFrame:frame];
        [_button setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_button.imageView setContentMode:UIViewContentModeBottom];
        [self addSubview:_button];
    }
    return self;
}


- (void)setImage:(UIImage *)image {
    if ([_image isEqual:image]) {
        return;
    }
    _image = image;
    
    [_button setImage:_image forState:UIControlStateNormal];
}

@end
