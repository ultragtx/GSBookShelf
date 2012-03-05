//
//  GSBookView.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-23.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSBookView.h"

@interface BookView : UIView <GSBookView>{
    
    UIImage *_image;
    @private 
    UIButton *_button;
}

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSString *reuseIdentifier;

@end
