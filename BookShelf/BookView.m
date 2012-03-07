//
//  GSBookView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-23.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "BookView.h"

@implementation BookView

@synthesize image = _image;
@synthesize button = _button;
@synthesize reuseIdentifier;
@synthesize selected = _selected;
@synthesize index = _index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blueColor]];
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setFrame:frame];
        [_button setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_button.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_button];
        
        _checkedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BookViewChecked.png"]];
        [_checkedImageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_checkedImageView setHidden:YES];
        [_button addSubview:_checkedImageView];
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

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (_selected) {
        [_checkedImageView setHidden:NO];
    }
    else {
        [_checkedImageView setHidden:YES];
    }
}

- (void)buttonClicked:(id)sender {
    [self setSelected:_selected ? NO : YES];
}

@end
