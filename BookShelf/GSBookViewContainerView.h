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

typedef struct BookViewPostion {
    NSInteger row;
    NSInteger col;
    NSInteger index;
}BookViewPostion;

@interface GSBookViewContainerView : UIView {
    GSBookShelfView __unsafe_unretained *_parentBookShelfView;    
    
    @private
    
    CGRect _visibleRect;
    
    NSInteger _firstVisibleRow;
    NSInteger _lastVisibleRow;
    
    //NSInteger _firstVisibleIndex;
    //NSInteger _lastVisibleIndex;
    
    NSMutableArray *_visibleBookViews;
    NSMutableDictionary *_reuseableBookViews;
    
    CGFloat _bookViewWidth;
    CGFloat _bookViewHeight;
    CGFloat _bookViewSpacingWidth;
    
    // Drag and Drop
    BOOL _isDragViewPickedUp;
    UIView *_dragView;
    BookViewPostion _pickUpPosition;
    CGRect _pickUpRect;
    BOOL _isDragViewRemovedFromVisibleBookViews;
    
    BOOL _isBooksMoving;
    
    // Scroll While Drag
    NSTimer *_scrollTimer;
    
    // Remove Book
    NSMutableIndexSet *_indexsOfBookViewToBeRemoved;
    NSMutableIndexSet *_indexsOfBookViewNotShown;
    NSMutableArray *_tempVisibleBookViewCollector;
    BOOL _isRemoving;
    
    
}

@property (nonatomic, unsafe_unretained) GSBookShelfView *parentBookShelfView;


- (void)layoutSubviewsWithVisibleRect:(CGRect)visibleRect;

- (UIView *)dequeueReusableBookViewWithIdentifier:(NSString *)identifier;

//- (void)removeBookViewAtIndexs:(NSIndexSet *)indexs removeCompletion:(void (^)(void))removeCompletion animate:(BOOL)animate;

- (void)removeBookViewsAtIndexs:(NSIndexSet *)indexs animate:(BOOL)animate;
- (void)addBookViewsAtIndexs:(NSIndexSet *)indexs animate:(BOOL)animate;

@end
