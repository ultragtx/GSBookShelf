//
//  NewBookView.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-3-12.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSBookView.h"

@interface MyBookView : UIButton <GSBookView> {
    UIImageView *_checkedImageView;
}

@property (nonatomic, strong) NSString *reuseIdentifier;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) NSInteger index;

@end
