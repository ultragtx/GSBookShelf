//
//  BookViewContainerView.h
//  BookShelf
//
//  Created by 鑫容 郭 on 12-2-24.
//  Copyright (c) 2012年 FoOTOo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSBookShelfView;

@protocol GSBookShelfViewDelegate;
@protocol GSBookShelfViewDataSource;

@interface GSBookViewContainerView : UIView {
    GSBookShelfView __unsafe_unretained *_parentBookShelfView;    
    
    @private
    
    NSInteger _firstVisibleRow;
    NSInteger _lastVisibleRow;
    
    NSInteger _firstVisibleIndex;
    NSInteger _lastVisibleIndex;
    
    NSMutableArray *_visibleBookViews;
    NSMutableSet *_reuseableBookViews;
    
    CGFloat _bookViewWidth;
    CGFloat _bookViewHeight;
    CGFloat _bookViewSpacingWidth;
    
    // Drag and Drop
    BOOL _isDragViewPickedUp;
    UIView __unsafe_unretained *_dragView;
    
    
    
}

@property (nonatomic, unsafe_unretained) GSBookShelfView *parentBookShelfView;



- (void)layoutSubviewsWithVisibleRect:(CGRect)visibleRect;

@end
