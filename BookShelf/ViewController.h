//
//  ViewController.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-22.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSBookShelfView.h"

@interface ViewController : UIViewController <GSBookShelfViewDelegate, GSBookShelfViewDataSource>{
    GSBookShelfView *_bookShelfView;
}

@end
