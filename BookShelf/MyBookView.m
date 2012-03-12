//
//  NewBookView.m
//  BookShelf
//
//  Created by 鑫容 郭 on 12-3-12.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import "MyBookView.h"

@implementation MyBookView

@synthesize reuseIdentifier;
@synthesize selected= _selected;
@synthesize index = _index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _checkedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BookViewChecked.png"]];
        [_checkedImageView setHidden:YES];
        [self addSubview:_checkedImageView];
        
        [self addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
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
